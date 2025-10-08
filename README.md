# htpb
> A modern SvelteKit application with automated CI/CD pipeline

## 🚀 Live Demo
Live demo: TBD

Everything you need to build a Svelte project, powered by [`sv`](https://github.com/sveltejs/cli).

## Creating a project

If you're seeing this, you've probably already done this step. Congrats!

```bash
# create a new project in the current directory
npx sv create

# create a new project in my-app
npx sv create my-app
```

## Development

Once you've created a project and installed dependencies with `pnpm install` (or `npm install` or `yarn`), start a development server:

```bash
pnpm run dev

# or start the server and open the app in a new browser tab
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

This project includes automated CI/CD with GitHub Actions:

- **Continuous Integration**: Runs tests, linting, and type checking on every push and PR
- **Continuous Deployment**: Automatically deploys to GitHub Pages on pushes to main branch
- **Code Quality**: Enforces formatting, linting, and type safety

<!-- Deployment target TBD for this repository. -->

> To deploy your app to other environments, you may need to install an [adapter](https://svelte.dev/docs/kit/adapters) for your target environment.

## Tech Stack

- **Framework**: SvelteKit
- **Language**: TypeScript
- **Package Manager**: pnpm
- **Testing**: Vitest + Playwright
- **CI/CD**: GitHub Actions
- **Deployment**: GitHub Pages
- **Code Quality**: ESLint + Prettier

[![CI](https://github.com/Akidi/htpb/actions/workflows/ci.yml/badge.svg)](https://github.com/Akidi/htpb/actions/workflows/ci.yml)
[![CI/CD](https://github.com/Akidi/htpb/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/Akidi/htpb/actions/workflows/ci-cd.yml)
[![Node.js](https://img.shields.io/badge/Node.js-20-green)](https://nodejs.org/)
[![SvelteKit](https://img.shields.io/badge/SvelteKit-Latest-orange)](https://kit.svelte.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-blue)](https://www.typescriptlang.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

See app-specific documentation: app/README.md
