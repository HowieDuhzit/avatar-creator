# Multi-stage build for RexCreator Avatar Application
FROM node:22-alpine AS builder

# Install Git LFS (needed for 3D assets)
RUN apk add --no-cache git git-lfs curl

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY turbo.json ./
COPY tsconfig.json ./
COPY eslint.config.mjs ./
COPY .prettierrc.json ./

# Copy workspace packages
COPY packages/ ./packages/
COPY examples/ ./examples/
COPY build-utils/ ./build-utils/

# Install dependencies
RUN npm ci --only=production

# Initialize Git LFS and pull assets
COPY .gitattributes ./
RUN git init . && \
    git lfs install && \
    git add . && \
    git commit -m "Initial commit" || true

# Build the application
RUN npm run build

# Production stage
FROM node:22-alpine AS production

# Install curl for health checks
RUN apk add --no-cache curl

# Create app directory
WORKDIR /app

# Copy built application from builder stage
COPY --from=builder /app/examples/avatar-preview-app/build ./public
COPY --from=builder /app/packages/avatar-creator/build ./lib

# Install a simple HTTP server
RUN npm install -g serve@14

# Create a start script
RUN echo '#!/bin/sh\nserve -s /app/public -l 3000' > /start.sh && \
    chmod +x /start.sh

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000 || exit 1

# Start the application
CMD ["/start.sh"]