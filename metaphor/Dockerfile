FROM --platform=$BUILDPLATFORM imbios/bun-node:1.2.0-20-alpine AS base

ARG DEBIAN_FRONTEND=noninteractive

FROM base AS deps

WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

# Build the app
FROM deps AS builder
WORKDIR /app
COPY . .

RUN bun run build

RUN ls -la

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
# Uncomment the following line in case you want to disable telemetry during runtime.
# ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1002 bunjs
RUN adduser --system --uid 1002 nextjs

COPY --from=builder --chown=nextjs:bunjs /app/public ./public
COPY --from=builder --chown=nextjs:bunjs /app/.next/standalone .
COPY --from=builder --chown=nextjs:bunjs /app/.next/static ./.next/static

EXPOSE 8080

USER nextjs

ENV PORT=8080

CMD ["node", "server.js"]
