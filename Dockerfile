# Multi-stage build for RexCreator Avatar Application
FROM node:22-alpine AS builder

# Install curl for health checks
RUN apk add --no-cache curl git

# Set working directory
WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./
COPY turbo.json ./
COPY tsconfig.json ./
COPY eslint.config.mjs ./
COPY .prettierrc.json ./

# Install dependencies
RUN npm ci

# Copy workspace packages and build utilities
COPY packages/ ./packages/
COPY examples/ ./examples/
COPY build-utils/ ./build-utils/

# Build the application
RUN npm run build

# Production stage
FROM node:22-alpine AS production

# Install curl for health checks
RUN apk add --no-cache curl

# Create app directory
WORKDIR /app

# Copy built application from builder stage
COPY --from=builder /app/examples/avatar-preview-app/build ./

# Install a simple HTTP server globally
RUN npm install -g serve@14

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Start the application
CMD ["serve", "-s", ".", "-l", "3000"]
