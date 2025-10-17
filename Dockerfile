# Simple production image for pre-built Avatar Creator
FROM node:22-alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Create app directory
WORKDIR /app

# Copy pre-built application
COPY examples/avatar-preview-app/build ./

# Install a simple HTTP server globally
RUN npm install -g serve@14

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Start the application
CMD ["serve", "-s", ".", "-l", "3000"]
