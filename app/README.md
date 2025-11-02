# Starter App

A modern full-stack SvelteKit application with PostgreSQL, Redis, and comprehensive authentication.

[![CI](https://github.com/Akidi/htpb/actions/workflows/ci.yml/badge.svg)](https://github.com/Akidi/htpb/actions/workflows/ci.yml)

## Tech Stack

- **Frontend**: SvelteKit 2 + TypeScript 5 + Tailwind CSS
- **Backend**: Node.js 20 with SvelteKit server-side rendering
- **Database**: PostgreSQL 16 with Drizzle ORM
- **Cache**: Redis 7 with ACL support
- **Authentication**: Custom session-based auth (Lucia-inspired)
- **Testing**: Vitest (unit) + Playwright (E2E)
- **UI Components**: Storybook with a11y checks
- **Container**: Docker + Docker Compose

## Quick Start

### Prerequisites

- Node.js 20+
- pnpm 10.12.1+
- Docker + Docker Compose
- PowerShell 7.2+ (for bootstrap script)

### Setup

The easiest way to get started is using the bootstrap script from the project root:

```bash
# From project root directory
cd ..
pwsh setup/bootstrap.ps1 -Environment dev -AppName "myapp"

# Then return to app directory
cd app
pnpm dev
```

This automatically:
- Generates secure secrets
- Creates `.env.dev` file with database credentials
- Starts Docker containers (PostgreSQL + Redis)
- Runs database migrations
- Seeds test data

**App runs at**: http://localhost:5173

### Manual Setup (without bootstrap)

If you prefer manual setup:

```bash
# 1. Install dependencies
pnpm install

# 2. Create .env file (copy from .env.example in project root)
cp ../.env.example ../.env.dev

# 3. Start Docker containers manually
docker compose up -d

# 4. Run migrations
pnpm db:migrate

# 5. Seed database (optional)
pnpm db:seed

# 6. Start dev server
pnpm dev
```

## Project Structure

```
app/
├── src/
│   ├── routes/                    # SvelteKit pages & API endpoints
│   │   ├── +page.svelte           # Homepage
│   │   ├── health/+server.ts      # Health check API
│   │   └── demo/lucia/            # Authentication demo pages
│   │       ├── +page.svelte       # Protected dashboard
│   │       ├── login/             # Login & registration
│   │       └── logout/            # Logout endpoint
│   │
│   ├── lib/
│   │   ├── components/ui/         # Reusable UI components
│   │   │   ├── Modal.svelte
│   │   │   ├── TextInput.svelte
│   │   │   ├── Checkbox.svelte
│   │   │   └── Toast.svelte
│   │   │
│   │   ├── server/                # Server-only code
│   │   │   ├── db/                # Database layer
│   │   │   │   ├── schema.ts      # Drizzle ORM schema definitions
│   │   │   │   ├── index.ts       # DB connection factory
│   │   │   │   ├── seed.ts        # Test data seeding
│   │   │   │   └── auth/          # Authentication schema
│   │   │   │       ├── users.ts
│   │   │   │       ├── sessions.ts
│   │   │   │       └── roles.ts
│   │   │   │
│   │   │   ├── auth.ts            # Session management
│   │   │   └── logger.ts          # Structured logging utility
│   │   │
│   │   ├── stores/                # Svelte stores (client state)
│   │   └── utils/                 # Shared utilities
│   │
│   ├── hooks.server.ts            # Server hooks (auth, i18n)
│   └── app.html                   # HTML template
│
├── static/                        # Static assets
├── tests/                         # Unit tests
├── e2e/                           # Playwright E2E tests
├── drizzle/                       # Generated migrations
├── .storybook/                    # Storybook configuration
└── stories/                       # Component stories
```

## Development

### Available Scripts

```bash
# Development
pnpm dev                 # Start dev server with HMR
pnpm db:studio           # Open Drizzle Studio (database GUI)
pnpm storybook           # Launch Storybook for component development

# Database
pnpm db:generate         # Generate migration from schema changes
pnpm db:migrate          # Apply pending migrations
pnpm db:push             # Push schema changes (dev only, no migrations)
pnpm db:seed             # Seed database with test data

# Code Quality
pnpm format              # Auto-format with Prettier
pnpm format:check        # Check formatting
pnpm lint                # Lint with ESLint
pnpm check               # Type check with svelte-check
pnpm check:watch         # Type check in watch mode

# Testing
pnpm test                # Run all tests
pnpm test:unit           # Run unit tests (Vitest)
pnpm test:unit --watch   # Run unit tests in watch mode
pnpm test:e2e            # Run E2E tests (Playwright)
pnpm test:e2e --headed   # Run E2E tests with browser visible

# Build
pnpm build               # Production build
pnpm preview             # Preview production build
pnpm build-storybook     # Build static Storybook site
```

### Development Tools

| Tool | URL | Purpose |
|------|-----|---------|
| **App** | http://localhost:5173 | Main application |
| **Drizzle Studio** | `pnpm db:studio` → http://localhost:3001 | Database GUI for browsing/editing data |
| **Storybook** | `pnpm storybook` → http://localhost:6006 | Component development & documentation |
| **Health Check** | http://localhost:5173/health | API health endpoint |

## Database

### Architecture

The app uses **separate read and write connections** for optimal performance:

| Connection | User | Purpose | Pool Size |
|------------|------|---------|-----------|
| **Admin** | `archon` | Migrations, schema changes | Default |
| **Write** | `tinkerer` | Application writes | 10 |
| **Read** | `lorekeeper` | Application reads (queries) | 20 |

### Database Roles

PostgreSQL has 6 specialized roles (all created by bootstrap):

1. **archon** - Full admin access
2. **tinkerer** - Read/write application data (used by app)
3. **lorekeeper** - Read-only access (used for queries)
4. **runesmith** - Development access
5. **stoneguard** - Backup operations only
6. **seer** - Security auditing (read-only + audit logs)

### Schema Management

The project uses **Drizzle ORM** for type-safe database operations.

**Make schema changes:**

1. Edit `src/lib/server/db/schema.ts` or `src/lib/server/db/auth/*.ts`
2. Generate migration: `pnpm db:generate`
3. Apply migration: `pnpm db:migrate`

**Quick iteration (dev only, no migration history)**:

```bash
pnpm db:push
```

### Database GUI

```bash
pnpm db:studio
```

Opens Drizzle Studio at http://localhost:3001 for:
- Browsing tables
- Editing data inline
- Running queries
- Viewing relationships

### Test Data

Default test users (seeded with `pnpm db:seed`):

| Email | Password | Role |
|-------|----------|------|
| `admin@bp.local` | See `src/lib/server/db/seed.ts` | admin |
| `developer@bp.local` | See `src/lib/server/db/seed.ts` | user |

**Test login at**: http://localhost:5173/demo/lucia/login

## Authentication

The app uses **session-based authentication** (not JWT):

- Sessions stored in PostgreSQL (`auth.session` table)
- Session cookies are `httpOnly` (not accessible via JavaScript)
- `sameSite: 'lax'` prevents CSRF attacks
- `secure: true` in production (HTTPS-only)
- 30-day session duration with 15-day renewal window

**Auth Flow**:

1. User submits login form
2. Password verified with Argon2 (19456 memoryCost, 2 timeCost)
3. Session token generated (cryptographically secure)
4. Session stored in database
5. Session cookie set with token
6. On subsequent requests, session validated via `hooks.server.ts`

**Protected Routes**:

See `/demo/lucia/+page.svelte` for example protected page.

## Testing

### Unit Tests (Vitest)

```bash
# Run once
pnpm test:unit

# Watch mode (recommended for development)
pnpm test:unit --watch

# With coverage
pnpm test:unit --coverage
```

**Writing Tests**:

```typescript
// src/lib/utils/math.test.ts
import { describe, it, expect } from 'vitest';
import { calculateTotal } from './math';

describe('calculateTotal', () => {
  it('sums item prices', () => {
    const items = [{ price: 10 }, { price: 20 }];
    expect(calculateTotal(items)).toBe(30);
  });
});
```

### E2E Tests (Playwright)

```bash
# Build first (required)
pnpm build

# Run tests
pnpm test:e2e

# Run with browser visible
pnpm test:e2e --headed

# Debug mode
pnpm test:e2e --debug
```

**Writing E2E Tests**:

```typescript
// e2e/login.spec.ts
import { test, expect } from '@playwright/test';

test('user can log in', async ({ page }) => {
  await page.goto('/demo/lucia/login');
  await page.fill('input[name="email"]', 'admin@bp.local');
  await page.fill('input[name="password"]', 'password');
  await page.click('button[type="submit"]');
  await expect(page).toHaveURL(/lucia/);
});
```

## Debugging

### VSCode Debug Configurations

Press **F5** in VSCode and select:

- **Debug SvelteKit (Chrome)** - Debug frontend in Chrome
- **Debug Server-Side** - Debug backend Node.js code
- **Debug Vitest Tests** - Debug unit tests
- **Debug Playwright Tests** - Debug E2E tests
- **Full Stack Debug** - Debug both frontend and backend simultaneously

### Logging

The app uses structured logging via `src/lib/server/logger.ts`:

```typescript
import { logger } from '$lib/server/logger';

// Info log
logger.info('User logged in', { userId, email });

// Error log with context
logger.error('Database query failed', error, { query, params });

// Debug log (only shown when DEBUG=true in .env)
logger.debug('Processing request', { path, method });

// Warning
logger.warn('Rate limit approaching', { userId, requestCount });
```

**Enable debug logs**:

```bash
# Add to .env.dev
DEBUG=true
LOG_LEVEL=debug
```

## Building for Production

```bash
# Production build
pnpm build

# Preview production build locally
pnpm preview

# Build output is in: build/
```

The production build:
- Uses Node adapter (`@sveltejs/adapter-node`)
- Optimizes and minifies assets
- Generates server-side code for SSR
- Type-checks all code

## Deployment

See the main project [DEPLOYMENT.md](../docs/DEPLOYMENT.md) for comprehensive deployment guide.

**Quick production deployment**:

```bash
# From project root
pwsh setup/bootstrap.ps1 -Environment prod -AppName "myapp"
docker compose -f docker-compose.prod.yml up -d
```

## Storybook

Component development with accessibility checks:

```bash
pnpm storybook
```

**Access**: http://localhost:6006

**Available Stories**:
- `Modal` - Dialog component with backdrop
- `TextInput` - Form input with validation
- `Checkbox` - Accessible checkbox component
- `Toggle` - Switch/toggle component
- `Toast` - Notification toast

## Environment Variables

See `../.env.example` for complete list of required variables.

**Key Variables**:

| Variable | Purpose | Example |
|----------|---------|---------|
| `DATABASE_URL` | Admin database connection | `postgres://archon:pass@db:5432/myapp` |
| `WRITE_DATABASE_URL` | Write connection (tinkerer) | `postgres://tinkerer:pass@db:5432/myapp` |
| `READ_DATABASE_URL` | Read connection (lorekeeper) | `postgres://lorekeeper:pass@db:5432/myapp` |
| `REDIS_URL` | Redis connection | `redis://tinkerer:pass@redis:6379` |
| `ORIGIN` | Application URL | `http://localhost:5173` |
| `NODE_ENV` | Environment mode | `development` or `production` |
| `DEBUG` | Enable debug logs | `true` or `false` |

## Troubleshooting

### Port Already in Use

```bash
# Find process using port 5173
lsof -ti:5173

# Kill process
kill -9 $(lsof -ti:5173)
```

### Database Connection Failed

```bash
# Check database is running
docker compose ps db

# View database logs
docker compose logs db

# Restart database
docker compose restart db
```

### Hot Reload Not Working

```bash
# Hard refresh browser
Ctrl+Shift+R (Windows/Linux)
Cmd+Shift+R (Mac)

# Restart dev server
# Ctrl+C to stop, then:
pnpm dev
```

### Build Errors

```bash
# Clear build cache
rm -rf .svelte-kit build

# Reinstall dependencies
rm -rf node_modules pnpm-lock.yaml
pnpm install

# Rebuild
pnpm build
```

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for development workflow, code style, and PR process.

## Documentation

- **Development Guide**: [docs/DEVELOPMENT.md](../docs/DEVELOPMENT.md)
- **Architecture**: [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md)
- **Deployment**: [docs/DEPLOYMENT.md](../docs/DEPLOYMENT.md)
- **NPM Setup**: [docs/NPM-SETUP.md](../docs/NPM-SETUP.md)

## License

See [LICENSE](../LICENSE) file in project root.
