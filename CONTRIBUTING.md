# Contributing to Starter App

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Development Workflow](#development-workflow)
- [Code Style](#code-style)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [Branch Strategy](#branch-strategy)
- [Commit Messages](#commit-messages)

---

## Getting Started

### Prerequisites

Before you begin, ensure you have:

- **Node.js** 20+ (LTS version)
- **pnpm** 10.12.1+ (package manager)
- **Docker** 24.0+ and **Docker Compose** 2.20+
- **PowerShell** 7.2+ (for bootstrap scripts)
- **Git** 2.40+

### Initial Setup

1. **Fork and Clone**:
   ```bash
   git clone https://github.com/yourusername/starter-app.git
   cd starter-app
   ```

2. **Run Bootstrap**:
   ```bash
   pwsh setup/bootstrap.ps1 -Environment dev -AppName "myapp"
   ```

   This automatically:
   - Generates secure secrets
   - Creates `.env.dev` file
   - Starts Docker containers (PostgreSQL, Redis, App)
   - Runs database migrations
   - Seeds test data

3. **Verify Setup**:
   ```bash
   # Check containers are running
   docker compose ps

   # App should be at http://localhost:5173
   curl http://localhost:5173/health
   ```

4. **Install VSCode Extensions** (if using VSCode):
   - Open the project in VSCode
   - You'll see a prompt to install recommended extensions - click "Install All"

---

## Development Setup

### Environment Files

- **Never commit `.env.*` files** (they're gitignored)
- Use `.env.example` as a reference for required variables
- Bootstrap script generates `.env.dev` automatically

### Database

- **GUI Tool**: Run `pnpm db:studio` to open Drizzle Studio at http://localhost:3001
- **Migrations**: Auto-run on `pnpm dev` via `predev` hook
- **Seeding**: Default test users are created in development
  - `admin@bp.local` (admin role)
  - `developer@bp.local` (user role)

### Available Scripts

```bash
# Development
pnpm dev              # Start dev server (auto-runs migrations)
pnpm db:studio        # Open database GUI

# Testing
pnpm test:unit        # Run unit tests with Vitest
pnpm test:e2e         # Run E2E tests with Playwright
pnpm test             # Run all tests

# Code Quality
pnpm lint             # Run ESLint + Prettier check
pnpm format           # Auto-format code
pnpm check            # Type check with svelte-check

# Database
pnpm db:generate      # Generate migration from schema changes
pnpm db:migrate       # Apply migrations
pnpm db:seed          # Reseed database with test data

# Build
pnpm build            # Production build
pnpm preview          # Preview production build

# Components
pnpm storybook        # Launch Storybook on port 6006
```

---

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

- Write code following the [code style guidelines](#code-style)
- Add/update tests as needed
- Update documentation if you're changing behavior

### 3. Test Your Changes

```bash
# Run all checks locally before committing
pnpm lint              # Must pass
pnpm check             # Must pass
pnpm test              # Must pass
pnpm build             # Must succeed
```

### 4. Commit Your Changes

Follow our [commit message conventions](#commit-messages).

```bash
git add .
git commit -m "feat: add user profile page"
```

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

---

## Code Style

### General Guidelines

- **TypeScript**: Use strict mode (already configured)
- **Formatting**: Prettier handles this automatically on save (if VSCode configured)
- **Linting**: ESLint enforces code quality rules
- **Imports**: Sort imports (auto-formatted by Prettier)

### TypeScript

```typescript
// ✅ Good: Explicit types for function parameters
export function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// ❌ Bad: Implicit any
export function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

### Svelte Components

```svelte
<!-- ✅ Good: Type-safe props -->
<script lang="ts">
  interface Props {
    title: string;
    count?: number;
  }

  let { title, count = 0 }: Props = $props();
</script>

<!-- ❌ Bad: Untyped props -->
<script>
  export let title;
  export let count = 0;
</script>
```

### Naming Conventions

- **Files**: `kebab-case` for files (e.g., `user-profile.ts`)
- **Components**: `PascalCase` for components (e.g., `UserProfile.svelte`)
- **Functions**: `camelCase` (e.g., `getUserData`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `API_ENDPOINT`)
- **Types/Interfaces**: `PascalCase` (e.g., `UserProfile`)

### Comments

- **Prefer self-documenting code** over comments
- **Use JSDoc** for public APIs and complex functions
- **Explain why, not what** - code should be readable enough to understand what

```typescript
// ✅ Good: Explains WHY
// Use read-only connection for reports to reduce load on primary DB
const users = await readDb.select().from(usersTable);

// ❌ Bad: Explains WHAT (obvious from code)
// Get users from database
const users = await readDb.select().from(usersTable);
```

### No Debug Statements

```typescript
// ❌ Never commit debug statements
console.log('[DEBUG] User data:', user);
console.log('TODO: Remove this');

// ✅ Use proper logging if needed
logger.debug('Processing user authentication', { userId: user.id });
```

---

## Testing Requirements

### Unit Tests (Required for New Features)

- **Location**: Co-located with source files (e.g., `user.test.ts` next to `user.ts`)
- **Framework**: Vitest
- **Coverage**: Aim for >80% on new code

```typescript
// Example: src/lib/utils/math.test.ts
import { describe, it, expect } from 'vitest';
import { calculateTotal } from './math';

describe('calculateTotal', () => {
  it('calculates sum of item prices', () => {
    const items = [{ price: 10 }, { price: 20 }];
    expect(calculateTotal(items)).toBe(30);
  });

  it('returns 0 for empty array', () => {
    expect(calculateTotal([])).toBe(0);
  });
});
```

### E2E Tests (Required for Critical Flows)

- **Location**: `app/e2e/` directory
- **Framework**: Playwright
- **When Required**: User-facing features (login, registration, critical workflows)

```typescript
// Example: e2e/login.spec.ts
import { test, expect } from '@playwright/test';

test('user can log in', async ({ page }) => {
  await page.goto('/demo/lucia/login');
  await page.fill('input[name="email"]', 'admin@bp.local');
  await page.fill('input[name="password"]', 'password');
  await page.click('button[type="submit"]');

  await expect(page).toHaveURL('/dashboard');
});
```

### Running Tests

```bash
# Unit tests (watch mode for development)
pnpm test:unit --watch

# E2E tests (requires built app)
pnpm build
pnpm test:e2e

# All tests
pnpm test
```

---

## Pull Request Process

### Before Submitting

1. ✅ **All tests pass**: `pnpm test`
2. ✅ **Linting passes**: `pnpm lint`
3. ✅ **Type checking passes**: `pnpm check`
4. ✅ **Build succeeds**: `pnpm build`
5. ✅ **Changes are documented** (if needed)

### PR Title Format

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
feat: add user profile page
fix: resolve login redirect issue
docs: update deployment guide
chore: upgrade dependencies
refactor: simplify auth logic
test: add unit tests for user service
```

### PR Description Template

```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] E2E tests added/updated (if applicable)
- [ ] Manually tested

## Screenshots (if UI changes)
[Add screenshots here]

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated (if needed)
- [ ] No console.log statements
```

### Review Process

1. **Automated Checks**: CI runs lint, typecheck, tests, and build
2. **Code Review**: At least one approval required
3. **Testing**: Reviewer should test locally if significant changes
4. **Merge**: Squash and merge (keeps history clean)

---

## Branch Strategy

```
main (stable, production-ready)
  └─ feature/user-authentication
  └─ fix/login-bug
  └─ docs/deployment-guide
  └─ chore/upgrade-deps
```

### Branch Naming

- **Features**: `feature/description` (e.g., `feature/user-profile`)
- **Bug Fixes**: `fix/description` (e.g., `fix/login-redirect`)
- **Documentation**: `docs/description` (e.g., `docs/api-guide`)
- **Chores**: `chore/description` (e.g., `chore/update-deps`)
- **Refactoring**: `refactor/description` (e.g., `refactor/auth-service`)

### Protection Rules

- **main**: Protected branch
  - Requires PR reviews
  - Status checks must pass (CI)
  - No force pushes
  - No direct commits

---

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, no logic change)
- **refactor**: Code refactoring
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **chore**: Maintenance tasks (dependencies, build config)
- **ci**: CI/CD changes

### Examples

```bash
# Simple commit
feat: add user profile page

# Commit with body
fix: resolve login redirect after password reset

Users were being redirected to home page instead of dashboard
after password reset. This fixes the redirect logic to match
the expected flow.

# Commit with breaking change
feat!: migrate to SvelteKit 2

BREAKING CHANGE: Requires Node 20+, updates Svelte to v5
```

### Commit Message Rules

- ✅ Use imperative mood ("add feature" not "added feature")
- ✅ First line under 72 characters
- ✅ Reference issue numbers when applicable (#123)
- ✅ Be descriptive but concise
- ❌ Don't use generic messages ("fix bug", "update code")

---

## Code Review Guidelines

### As a Contributor

- **Respond to feedback** constructively
- **Make requested changes** or explain why you disagree
- **Keep PRs focused** - one feature/fix per PR
- **Be patient** - reviews take time

### As a Reviewer

- **Be respectful** and constructive
- **Test changes** locally when possible
- **Check for**:
  - Code quality and readability
  - Test coverage
  - Documentation updates
  - Performance implications
  - Security considerations
- **Approve quickly** if changes are good
- **Request changes** if issues found, with clear explanations

---

## Questions or Issues?

- **Development Questions**: See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)
- **Architecture Questions**: See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- **Deployment Questions**: See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)
- **Bug Reports**: Open a GitHub issue
- **Feature Requests**: Open a GitHub issue with "Feature Request" label

---

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).

---

Thank you for contributing! 🎉
