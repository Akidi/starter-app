# Starter Template App
> A modern SvelteKit application with automated CI/CD pipeline

## Live Demo
Live demo: TBD

Everything you need to build a Svelte project, powered by [`sv`](https://github.com/sveltejs/cli).

## Quick Start

### Development (Simple Bootstrap)

```bash
# Install PowerShell 7.2+ (if not already installed)
# Linux: https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-linux
# macOS: brew install powershell

# Run bootstrap script
pwsh setup/bootstrap.ps1 -Environment dev -AppName "myapp"

# That's it! Your dev environment is running at http://localhost:5173
```

The bootstrap script automatically:
- Generates secure secrets
- Creates environment-specific configuration files
- Starts Docker containers (PostgreSQL, Redis, App)
- Runs database migrations and seeds test data

### Production Deployment

```bash
# On your production server
pwsh setup/bootstrap.ps1 -Environment prod -AppName "myapp"

# Follow the interactive prompts for production-specific setup
# See docs/DEPLOYMENT.md for complete deployment guide
```

**Deployment Guides**:
- **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** - Complete production deployment guide
- **[docs/NPM-SETUP.md](docs/NPM-SETUP.md)** - Quick setup for Nginx Proxy Manager (recommended for Docker)

**Includes**:
- Server prerequisites and automated setup
- SSL/HTTPS with Caddy, Nginx, or Nginx Proxy Manager
- Docker network isolation (production has no exposed ports)
- Backup and restore procedures
- Monitoring and troubleshooting

## Development

### Manual Setup (Without Bootstrap)

If you prefer manual setup:

```bash
# Install dependencies
pnpm install

# Start dev server
pnpm run dev

# or open in browser
pnpm run dev -- --open
```

## Building

To create a production version of your app:

```bash
pnpm run build
```

You can preview the production build with `pnpm run preview`.

## Testing

Run the test suite:

```bash
# Unit tests
pnpm run test:unit

# Integration tests with Playwright
pnpm run test:integration

# All tests
pnpm run test
```

## Code Quality

Format and lint your code:

```bash
# Check formatting
pnpm run format:check

# Fix formatting
pnpm run format

# Run linter
pnpm run lint

# Type checking
pnpm run check
```

## Deployment

### Production Deployment

Deploy to your own server with a single command:

```bash
pwsh setup/bootstrap.ps1 -Environment prod -AppName "myapp"
```

**Complete deployment guide**: [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

The guide covers:
- Server setup and prerequisites
- Automated bootstrap process
- Reverse proxy configuration (Caddy/Nginx)
- SSL certificate setup
- Production validation
- Backup and restore procedures
- Monitoring and maintenance

### CI/CD

This project includes automated CI/CD with GitHub Actions:

- **Continuous Integration**: Runs tests, linting, and type checking on every push and PR
- **Code Quality**: Enforces formatting, linting, and type safety
- **Build Verification**: Ensures production builds succeed

> To deploy your app to other environments, you may need to install an [adapter](https://svelte.dev/docs/kit/adapters) for your target environment.

## Tech Stack

### Frontend & Application
- **Framework**: SvelteKit 2
- **Language**: TypeScript 5
- **UI**: TailwindCSS + Storybook
- **Package Manager**: pnpm

### Backend & Infrastructure
- **Database**: PostgreSQL 16 with Drizzle ORM
- **Cache**: Redis 7 with ACL
- **Authentication**: Custom session-based auth (Lucia-inspired)
- **Container**: Docker + Docker Compose

### Development & Quality
- **Testing**: Vitest + Playwright
- **CI/CD**: GitHub Actions
- **Code Quality**: ESLint + Prettier
- **Automation**: PowerShell 7.2+ bootstrap scripts

[![CI](https://github.com/Akidi/htpb/actions/workflows/ci.yml/badge.svg)](https://github.com/Akidi/htpb/actions/workflows/ci.yml)
[![CI/CD](https://github.com/Akidi/htpb/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/Akidi/htpb/actions/workflows/ci-cd.yml)
[![Node.js](https://img.shields.io/badge/Node.js-20-green)](https://nodejs.org/)
[![SvelteKit](https://img.shields.io/badge/SvelteKit-Latest-orange)](https://kit.svelte.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-blue)](https://www.typescriptlang.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

See app-specific documentation: app/README.md
