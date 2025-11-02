# Development Guide

This guide covers everything you need to know for daily development work on the starter-app.

## Table of Contents

- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Development Tools](#development-tools)
- [Common Tasks](#common-tasks)
- [Database Management](#database-management)
- [Testing](#testing)
- [Debugging](#debugging)
- [Troubleshooting](#troubleshooting)
- [Performance](#performance)
- [Security](#security)

---

## Quick Start

### First Time Setup

```bash
# 1. Clone the repository
git clone <repo-url>
cd starter-app

# 2. Run bootstrap (automatic setup)
pwsh setup/bootstrap.ps1 -Environment dev -AppName "myapp"

# 3. Verify services are running
docker compose ps

# 4. Access the application
# App:        http://localhost:5173
# DB Studio:  pnpm db:studio → http://localhost:3001
# Storybook:  pnpm storybook → http://localhost:6006
```

### Daily Workflow

```bash
# Start development server (auto-runs migrations)
cd app
pnpm dev

# In separate terminals:
pnpm db:studio    # Database GUI
pnpm storybook    # Component development
pnpm test:unit --watch  # Continuous testing
```

---

## Project Structure

```
starter-app/
├── app/                           # Main application
│   ├── src/
│   │   ├── routes/                # SvelteKit pages & API routes
│   │   │   ├── +page.svelte       # Homepage
│   │   │   ├── health/+server.ts  # Health check endpoint
│   │   │   └── demo/lucia/        # Authentication demo pages
│   │   ├── lib/
│   │   │   ├── components/        # Reusable UI components
│   │   │   │   └── ui/            # Base UI components (Storybook)
│   │   │   ├── server/            # Server-only code
│   │   │   │   ├── db/            # Database layer
│   │   │   │   │   ├── schema.ts  # Drizzle ORM schema
│   │   │   │   │   ├── index.ts   # DB/Redis connections
│   │   │   │   │   └── seed.ts    # Test data seeding
│   │   │   │   └── auth.ts        # Authentication logic
│   │   │   ├── stores/            # Svelte stores (state management)
│   │   │   └── utils/             # Shared utilities
│   │   ├── hooks.server.ts        # Server hooks (auth, i18n)
│   │   └── app.html               # HTML template
│   ├── static/                    # Static assets
│   ├── tests/                     # Test files
│   ├── package.json               # Dependencies & scripts
│   ├── vite.config.ts             # Vite configuration
│   ├── svelte.config.js           # SvelteKit configuration
│   ├── drizzle.config.ts          # Drizzle ORM configuration
│   └── Dockerfile                 # Multi-stage Docker build
│
├── setup/
│   └── bootstrap.ps1              # Main setup script
│
├── scripts/
│   ├── modules/                   # PowerShell modules
│   ├── backup.ps1                 # Database/Redis backup
│   ├── restore.ps1                # Restore from backup
│   └── validate-production.ps1    # Production readiness checks
│
├── templates/                     # Configuration templates
│   ├── .env.template
│   ├── docker-compose.template.yml
│   ├── init.template.sql
│   ├── redis.conf.template
│   └── redis.acl.template
│
├── docs/                          # Documentation
│   ├── DEVELOPMENT.md             # This file
│   ├── DEPLOYMENT.md              # Production deployment
│   ├── ARCHITECTURE.md            # System design
│   └── NPM-SETUP.md               # Nginx Proxy Manager setup
│
├── .vscode/                       # VSCode configuration
│   ├── settings.json              # Editor settings
│   ├── extensions.json            # Recommended extensions
│   └── launch.json                # Debug configurations
│
└── CONTRIBUTING.md                # Contribution guidelines
```

---

## Development Tools

### Essential Tools

| Tool | Purpose | Access |
|------|---------|--------|
| **Vite Dev Server** | Hot reload development | http://localhost:5173 |
| **Drizzle Studio** | Database GUI | `pnpm db:studio` → http://localhost:3001 |
| **Storybook** | Component development | `pnpm storybook` → http://localhost:6006 |
| **Vitest** | Unit testing | `pnpm test:unit --watch` |
| **Playwright** | E2E testing | `pnpm test:e2e` |
| **Docker Compose** | Container orchestration | `docker compose logs -f` |

### VSCode Setup

If you're using VSCode, install the recommended extensions:

1. Open the project in VSCode
2. You'll see a notification to install recommended extensions
3. Click **"Install All"**

**Key Extensions**:
- `svelte.svelte-vscode` - Svelte language support
- `esbenp.prettier-vscode` - Auto-formatting
- `dbaeumer.vscode-eslint` - Linting
- `bradlc.vscode-tailwindcss` - Tailwind IntelliSense
- `ms-playwright.playwright` - E2E testing
- `ms-azuretools.vscode-docker` - Docker support

**Debug Configurations** (press F5):
- **Debug SvelteKit (Chrome)** - Debug frontend in Chrome
- **Debug Server-Side** - Debug backend Node.js code
- **Debug Vitest Tests** - Debug unit tests
- **Debug Playwright Tests** - Debug E2E tests
- **Full Stack Debug** - Debug both frontend and backend

---

## Common Tasks

### Starting Development

```bash
cd app

# Start dev server (auto-runs migrations and opens browser)
pnpm dev

# Start dev server without opening browser
pnpm dev --open false

# Start with specific port
PORT=3000 pnpm dev
```

### Database Tasks

```bash
# Open database GUI
pnpm db:studio

# Generate migration from schema changes
pnpm db:generate

# Apply migrations
pnpm db:migrate

# Push schema changes directly (dev only, no migration files)
pnpm db:push

# Reseed database with test data
pnpm db:seed
```

### Code Quality

```bash
# Format code (auto-fix)
pnpm format

# Check formatting without fixing
pnpm format:check

# Lint code (auto-fix where possible)
pnpm lint

# Type check
pnpm check

# Type check in watch mode
pnpm check:watch

# Run all checks
pnpm format:check && pnpm lint && pnpm check
```

### Testing

```bash
# Unit tests (watch mode)
pnpm test:unit --watch

# Unit tests (run once)
pnpm test:unit

# E2E tests (requires built app)
pnpm build
pnpm test:e2e

# E2E tests (headed mode - see browser)
pnpm test:e2e --headed

# E2E tests (debug mode)
pnpm test:e2e --debug

# Run all tests
pnpm test
```

### Building

```bash
# Production build
pnpm build

# Preview production build
pnpm preview

# Build Storybook (static site)
pnpm build-storybook
```

### Component Development

```bash
# Launch Storybook
pnpm storybook

# Build Storybook for deployment
pnpm build-storybook

# Storybook will be at http://localhost:6006
```

---

## Database Management

### Connection Details

The app uses **separate read and write connections** for better performance:

| Connection | User | Purpose | Environment Variable |
|------------|------|---------|---------------------|
| **Admin** | `archon` | Full access (migrations, schema changes) | `DATABASE_URL` |
| **Write** | `tinkerer` | Application writes | `WRITE_DATABASE_URL` |
| **Read** | `lorekeeper` | Application reads (queries) | `READ_DATABASE_URL` |

### Database Roles

The PostgreSQL database has 6 specialized roles:

1. **archon** (admin) - Full database access
2. **tinkerer** (api) - Read/write app data
3. **lorekeeper** (read-only) - Reporting and analytics
4. **runesmith** (developer) - Development access
5. **stoneguard** (backup) - Backup operations only
6. **seer** (auditor) - Security auditing (read-only with audit logs)

### Schema Management with Drizzle

**Making Schema Changes:**

1. **Edit the schema**: `app/src/lib/server/db/schema.ts`
   ```typescript
   export const postsTable = pgTable('posts', {
     id: text('id').primaryKey(),
     title: text('title').notNull(),
     content: text('content'),
     createdAt: timestamp('created_at').defaultNow(),
   });
   ```

2. **Generate migration**:
   ```bash
   pnpm db:generate
   ```

3. **Review migration**: Check `app/drizzle/` directory

4. **Apply migration**:
   ```bash
   pnpm db:migrate
   ```

**Development Workflow (No Migration Files)**:

For rapid prototyping, use push mode (skips migration files):

```bash
pnpm db:push
```

⚠️ **Warning**: This is destructive and doesn't create migration history. Use only in development!

### Drizzle Studio (Database GUI)

```bash
pnpm db:studio
```

**Features**:
- Browse all tables
- Edit data inline
- Run queries
- View relationships
- Export data

**Access**: http://localhost:3001

### Test Data

Default test users (created by `pnpm db:seed`):

| Email | Role | Password |
|-------|------|----------|
| `admin@bp.local` | admin | (check `seed.ts`) |
| `developer@bp.local` | user | (check `seed.ts`) |

**Reseed Database**:
```bash
pnpm db:seed
```

### Database CLI Access

```bash
# Access PostgreSQL CLI
docker compose exec db psql -U archon myapp

# Run SQL file
docker compose exec -T db psql -U archon myapp < script.sql

# Dump database
docker compose exec db pg_dump -U archon myapp > backup.sql

# Restore database
docker compose exec -T db psql -U archon myapp < backup.sql
```

---

## Testing

### Unit Tests (Vitest)

**Location**: Co-located with source files (e.g., `utils.test.ts` next to `utils.ts`)

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

  it('handles empty array', () => {
    expect(calculateTotal([])).toBe(0);
  });
});
```

**Running Tests**:

```bash
# Watch mode (recommended for development)
pnpm test:unit --watch

# Run once
pnpm test:unit

# With coverage
pnpm test:unit --coverage

# Specific file
pnpm test:unit src/lib/utils/math.test.ts
```

### E2E Tests (Playwright)

**Location**: `app/e2e/` directory

**Writing Tests**:

```typescript
// e2e/login.spec.ts
import { test, expect } from '@playwright/test';

test('user can log in', async ({ page }) => {
  await page.goto('/demo/lucia/login');

  await page.fill('input[name="email"]', 'admin@bp.local');
  await page.fill('input[name="password"]', 'password');
  await page.click('button[type="submit"]');

  // Assert redirected to dashboard
  await expect(page).toHaveURL(/dashboard/);
});
```

**Running E2E Tests**:

```bash
# Build first (required)
pnpm build

# Run tests (headless)
pnpm test:e2e

# Run with browser visible
pnpm test:e2e --headed

# Debug mode (step through)
pnpm test:e2e --debug

# Specific test file
pnpm test:e2e e2e/login.spec.ts
```

### Test Databases

Tests use the same dev database. For isolation, consider:

```bash
# Option 1: Reseed before tests
pnpm db:seed && pnpm test

# Option 2: Use separate test environment
pwsh setup/bootstrap.ps1 -Environment test -AppName "myapp-test"
```

---

## Debugging

### Browser Debugging

**Chrome DevTools**:

1. Open http://localhost:5173
2. Press F12 to open DevTools
3. Set breakpoints in Sources tab
4. Inspect Network requests, Console logs

**VSCode Debug**:

1. Press F5 → Select "Debug SvelteKit (Chrome)"
2. Set breakpoints in `.svelte` files
3. Chrome will launch with debugger attached
4. Step through code, inspect variables

### Server-Side Debugging

**VSCode Debug**:

1. Press F5 → Select "Debug Server-Side"
2. Set breakpoints in `*.server.ts`, `+page.server.ts` files
3. Trigger the code path (navigate to page)
4. Debugger will pause at breakpoints

**Console Logging** (temporary debugging):

```typescript
// Good: Structured logging
console.log('User authentication', { userId, email, role });

// Bad: Generic logs
console.log(user);

// Remember to remove before committing!
```

### Database Debugging

**Drizzle Studio**:

1. `pnpm db:studio`
2. Browse tables, inspect data
3. Run queries directly

**Query Logging**:

Enable verbose logging in `drizzle.config.ts`:

```typescript
export default defineConfig({
  // ... other config
  verbose: true,  // Log all SQL queries
});
```

**PostgreSQL Logs**:

```bash
# View database logs
docker compose logs db -f

# Check slow queries
docker compose exec db psql -U archon myapp -c "SELECT * FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"
```

### Docker Container Debugging

```bash
# View all container logs
docker compose logs -f

# View specific service logs
docker compose logs app -f
docker compose logs db -f
docker compose logs redis -f

# Execute command in running container
docker compose exec app sh
docker compose exec db psql -U archon myapp
docker compose exec redis redis-cli

# Inspect container
docker inspect <container-name>

# Container stats
docker stats
```

---

## Troubleshooting

### Port Already in Use

**Problem**: `Error: Port 5173 is already in use`

**Solution**:
```bash
# Find process using port
lsof -ti:5173

# Kill process
kill -9 $(lsof -ti:5173)

# Or change port in .env.dev
echo "PORT=3000" >> .env.dev
```

### Database Connection Failed

**Problem**: `Error: Connection refused at postgres:5432`

**Solutions**:

1. **Check database is running**:
   ```bash
   docker compose ps db
   ```

2. **View database logs**:
   ```bash
   docker compose logs db
   ```

3. **Restart database**:
   ```bash
   docker compose restart db
   ```

4. **Verify connection string** in `.env.dev`

### Redis Connection Failed

**Problem**: `Error: ECONNREFUSED redis:6379`

**Solutions**:

1. **Check Redis is running**:
   ```bash
   docker compose ps redis
   ```

2. **Test connection**:
   ```bash
   docker compose exec redis redis-cli --user tinkerer -a <password> PING
   ```

3. **View logs**:
   ```bash
   docker compose logs redis
   ```

### Migration Failed

**Problem**: `Error: migration failed`

**Solutions**:

1. **Check migration files**: `app/drizzle/*.sql`

2. **Manual migration**:
   ```bash
   docker compose exec db psql -U archon myapp -f /path/to/migration.sql
   ```

3. **Reset database** (dev only):
   ```bash
   docker compose down -v
   pwsh setup/bootstrap.ps1 -Environment dev -AppName "myapp"
   ```

### Hot Reload Not Working

**Problem**: Changes not reflected in browser

**Solutions**:

1. **Hard refresh**: Ctrl+Shift+R (Chrome) or Cmd+Shift+R (Mac)

2. **Check HMR port**:
   ```bash
   # Should see port 24678 listening
   netstat -an | grep 24678
   ```

3. **Restart dev server**:
   ```bash
   # Ctrl+C to stop, then:
   pnpm dev
   ```

4. **Check file watchers** (Linux):
   ```bash
   # Increase watcher limit
   echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
   sudo sysctl -p
   ```

### Build Errors

**Problem**: `pnpm build` fails

**Common Causes**:

1. **Type errors**:
   ```bash
   pnpm check
   ```

2. **Lint errors**:
   ```bash
   pnpm lint
   ```

3. **Missing dependencies**:
   ```bash
   rm -rf node_modules pnpm-lock.yaml
   pnpm install
   ```

4. **Cache issues**:
   ```bash
   rm -rf .svelte-kit build
   pnpm build
   ```

---

## Performance

### Development Performance

**Slow Hot Reload**:

1. **Disable source maps** (faster rebuild):
   ```typescript
   // vite.config.ts
   export default defineConfig({
     build: {
       sourcemap: false  // Only for development
     }
   });
   ```

2. **Exclude large dependencies** from optimization:
   ```typescript
   // vite.config.ts
   export default defineConfig({
     optimizeDeps: {
       exclude: ['large-package']
     }
   });
   ```

### Database Performance

**Slow Queries**:

1. **Use read connection** for queries:
   ```typescript
   // ✅ Good: Use read DB
   const users = await getReadDb().select().from(usersTable);

   // ❌ Bad: Use write DB for reads
   const users = await getWriteDb().select().from(usersTable);
   ```

2. **Add indexes**:
   ```typescript
   // schema.ts
   export const usersTable = pgTable('users', {
     // ... columns
   }, (table) => ({
     emailIdx: index('email_idx').on(table.email),
   }));
   ```

3. **Use prepared statements** for repeated queries:
   ```typescript
   const getUserById = readDb
     .select()
     .from(usersTable)
     .where(eq(usersTable.id, placeholder('id')))
     .prepare('get_user_by_id');

   const user = await getUserById.execute({ id });
   ```

### Redis Caching

**Pattern**:

```typescript
import { redis } from '$lib/server/db';

async function getUser(id: string) {
  // Check cache first
  const cached = await redis.get(`user:${id}`);
  if (cached) return JSON.parse(cached);

  // Fetch from database
  const user = await readDb.select().from(usersTable).where(eq(usersTable.id, id));

  // Cache for 5 minutes
  await redis.setex(`user:${id}`, 300, JSON.stringify(user));

  return user;
}
```

---

## Security

### Environment Variables

- ✅ **Never commit `.env*` files** (already gitignored)
- ✅ **Use strong secrets** (bootstrap generates 32-64 char passwords)
- ✅ **Rotate secrets regularly** in production
- ❌ **Never hardcode secrets** in code

### Authentication

The app uses **session-based authentication** (not JWT):

- Sessions stored in PostgreSQL
- Session cookies are `httpOnly` (not accessible via JavaScript)
- `sameSite: 'lax'` prevents CSRF
- `secure: true` in production (HTTPS only)

**Test Login**:

```bash
# Visit: http://localhost:5173/demo/lucia/login
# Email: admin@bp.local
# Password: (check seed.ts)
```

### Input Validation

Always validate user input:

```typescript
// ✅ Good: Validate with Zod
import { z } from 'zod';

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

const result = schema.safeParse(formData);
if (!result.success) {
  return fail(400, { errors: result.error.flatten() });
}
```

### SQL Injection Prevention

Drizzle ORM prevents SQL injection by default:

```typescript
// ✅ Good: Parameterized query
const user = await readDb.select().from(usersTable).where(eq(usersTable.email, email));

// ❌ Bad: String concatenation (vulnerable!)
const user = await readDb.execute(sql`SELECT * FROM users WHERE email = '${email}'`);
```

---

## Resources

- **SvelteKit Docs**: https://kit.svelte.dev/docs
- **Drizzle ORM Docs**: https://orm.drizzle.team/docs
- **Vitest Docs**: https://vitest.dev/
- **Playwright Docs**: https://playwright.dev/
- **Tailwind CSS Docs**: https://tailwindcss.com/docs

---

## Getting Help

- **Development Issues**: Check this guide first
- **Architecture Questions**: See [ARCHITECTURE.md](ARCHITECTURE.md)
- **Deployment Issues**: See [DEPLOYMENT.md](DEPLOYMENT.md)
- **Contributing**: See [CONTRIBUTING.md](../CONTRIBUTING.md)
- **Bug Reports**: Open a GitHub issue

---

Happy coding! 🚀
