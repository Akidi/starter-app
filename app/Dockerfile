# syntax=docker/dockerfile:1.6

ARG NODE_VERSION=20
ARG PNPM_VERSION=10.17.1

# Build stage using Debian/Ubuntu base for better compatibility
FROM node:${NODE_VERSION}-slim AS build-base
ARG PNPM_VERSION
ENV PNPM_HOME="/pnpm" \
    PATH="$PNPM_HOME:$PATH"
RUN corepack enable \
  && corepack prepare pnpm@${PNPM_VERSION} --activate \
  && apt-get update \
  && apt-get -y upgrade \
  && rm -rf /var/lib/apt/lists/*

# Dependencies stage
FROM build-base AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml svelte.config.js ./
RUN --mount=type=cache,id=pnpm-store-deps,target=/pnpm/store \
    pnpm install --frozen-lockfile


# Build stage
FROM build-base AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN pnpm exec svelte-kit sync && pnpm build

# Base runtime stage
FROM node:${NODE_VERSION}-alpine AS runtime-base
ARG PNPM_VERSION
ENV PNPM_HOME="/pnpm" \
    PATH="$PNPM_HOME:$PATH"
RUN corepack enable \
  && corepack prepare pnpm@${PNPM_VERSION} --activate
WORKDIR /app

# Install system dependencies for Alpine including postgresql-client
RUN apk add --no-cache bash curl postgresql-client

# Copy package files for runtime dependencies
COPY package.json pnpm-lock.yaml ./

# Install only production dependencies
RUN --mount=type=cache,id=pnpm-store-runtime,target=/pnpm/store \
    pnpm install --frozen-lockfile --prod --prefer-offline --ignore-scripts

# Copy built application and generated files
COPY --from=build /app/build ./build
COPY --from=build /app/drizzle ./drizzle

# Copy necessary files for migrations and runtime
COPY drizzle.config.ts tsconfig.json ./
COPY src ./src

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Development stage - includes dev tools and hot reload
FROM runtime-base AS development
# Install all dependencies (including dev)
RUN --mount=type=cache,id=pnpm-store-dev,target=/pnpm/store \
    pnpm install --frozen-lockfile --prefer-offline

# Add development tools
RUN apk add --no-cache git vim

# Set development environment
ENV NODE_ENV=development
ENV VITE_DEV=true

# Expose additional ports for dev tools
EXPOSE 3000 5173 24678

# Development command with hot reload
CMD ["pnpm", "dev", "--host"]

# Staging stage - production-like but with debugging tools
FROM runtime-base AS staging
# Add debugging and monitoring tools
RUN apk add --no-cache htop netcat-openbsd tcpdump strace

# Set staging environment
ENV NODE_ENV=staging
ENV DEBUG=true
ENV LOG_LEVEL=debug

# Enable detailed logging
ENV VERBOSE_LOGGING=true

EXPOSE 3000

# Use a staging-specific entrypoint that includes health checks
COPY docker-entrypoint-staging.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-staging.sh

CMD ["/usr/local/bin/docker-entrypoint-staging.sh"]

# Production stage - minimal and secure
FROM runtime-base AS production
# Set production environment
ENV NODE_ENV=production
ENV PORT=3000
ENV DEBUG=false

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs \
  && adduser -S sveltekit -u 1001

# Change ownership of app files
RUN chown -R sveltekit:nodejs /app
USER sveltekit

EXPOSE 3000


CMD ["/usr/local/bin/docker-entrypoint.sh"]
