#!/bin/bash
set -e

echo "🚀 Starting application..."

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Environment Variable Validation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "🔍 Validating environment variables..."

# Required environment variables
REQUIRED_VARS=(
    "NODE_ENV"
    "DATABASE_URL"
    "REDIS_URL"
    "ORIGIN"
    "APP_SECRET"
)

VALIDATION_FAILED=0

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ ERROR: Required environment variable $var is not set"
        VALIDATION_FAILED=1
    else
        echo "  ✓ $var is set"
    fi
done

# Production-specific validation
if [ "$NODE_ENV" = "production" ]; then
    echo "🔒 Production mode detected, performing additional validation..."

    # Check ORIGIN is not localhost in production
    if [[ "$ORIGIN" == *"localhost"* ]] || [[ "$ORIGIN" == *"127.0.0.1"* ]]; then
        echo "⚠️  WARNING: ORIGIN is set to localhost in production: $ORIGIN"
        echo "   This may cause issues with cookies and authentication!"
    fi

    # Check ORIGIN uses HTTPS
    if [[ "$ORIGIN" != https://* ]]; then
        echo "⚠️  WARNING: ORIGIN does not use HTTPS in production: $ORIGIN"
        echo "   Secure cookies will not work properly!"
    fi

    # Check APP_SECRET length
    APP_SECRET_LENGTH=${#APP_SECRET}
    if [ "$APP_SECRET_LENGTH" -lt 32 ]; then
        echo "❌ ERROR: APP_SECRET is too short ($APP_SECRET_LENGTH chars, minimum 32)"
        VALIDATION_FAILED=1
    fi
fi

# Exit if validation failed
if [ $VALIDATION_FAILED -eq 1 ]; then
    echo "❌ Environment validation failed! Fix the errors above and restart."
    exit 1
fi

echo "✅ Environment validation passed"

# Wait for database to be ready
echo "⏳ Waiting for database..."

# Function to check if database is ready
check_db() {
    if [ -n "$DATABASE_URL" ]; then
        # Extract host and port from DATABASE_URL
        # Format: postgres://user:pass@host:port/db
        DB_HOST=$(echo "$DATABASE_URL" | sed -n 's|.*@\([^:]*\):.*|\1|p')
        DB_PORT=$(echo "$DATABASE_URL" | sed -n 's|.*:\([0-9]*\)/.*|\1|p')
        
        # Default to common values if extraction fails
        DB_HOST=${DB_HOST:-"bp.db.dev"}
        DB_PORT=${DB_PORT:-"5432"}
    else
        # Fallback values
        DB_HOST="bp.db.dev"
        DB_PORT="5432"
    fi
    
    echo "Checking database at $DB_HOST:$DB_PORT"
    
    # Try to connect using timeout and /dev/tcp (built into bash)
    timeout 2 bash -c "</dev/tcp/$DB_HOST/$DB_PORT" 2>/dev/null
}

# Wait for database with timeout
MAX_ATTEMPTS=30
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if check_db; then
        echo "✅ Database is ready!"
        break
    else
        echo "Database not ready, waiting... (attempt $((ATTEMPT + 1))/$MAX_ATTEMPTS)"
        sleep 2
        ATTEMPT=$((ATTEMPT + 1))
    fi
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo "⚠️ Database check timed out after $MAX_ATTEMPTS attempts"
    echo "Proceeding anyway - database might be ready"
fi

# Run migrations
echo "🔄 Running database migrations..."
if [ -n "$DATABASE_URL" ]; then
    # Check if we have any migration files
    if [ -d "drizzle" ] && [ "$(ls -A drizzle/*.sql 2>/dev/null)" ]; then
        echo "📂 Found migration files, applying..."
        pnpm db:migrate || echo "⚠️ Migration failed - database might already be up to date"
    else
        echo "📭 No migration files found - database schema should be set up via init.sql"
    fi
    
    # Run seed (only in development)
    if [ "$NODE_ENV" != "production" ]; then
        echo "🌱 Running database seed..."
        pnpm db:seed || echo "ℹ️  Seed skipped (no seed script or data already exists)"
    fi
else
    echo "⚠️  DATABASE_URL not set, skipping migrations"
fi

# Start the application
echo "🎯 Starting SvelteKit application..."
exec node build