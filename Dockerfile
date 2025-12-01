# Multi-stage Dockerfile for Hugo portfolio site
# Demonstrates production-grade container practices:
# - Multi-stage builds for minimal image size
# - Non-root user for security
# - Optimized Nginx configuration
# - Health checks

# =============================================================================
# Stage 1: Build the Hugo site
# =============================================================================
FROM hugomods/hugo:exts-0.139.0 AS builder

# Set working directory
WORKDIR /src

# Copy source files
COPY . .

# Build the site with optimizations
RUN hugo --gc --minify

# =============================================================================
# Stage 2: Production server with Nginx
# =============================================================================
FROM nginx:1.25-alpine AS production

# Labels for container metadata
LABEL maintainer="Munish Thakur <thakurmunish2806@gmail.com>"
LABEL description="Portfolio website for Munish Thakur - DevOps Engineer"
LABEL version="1.0.0"

# Create non-root user for security
RUN addgroup -g 1001 -S nginx-user && \
    adduser -u 1001 -S nginx-user -G nginx-user

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built site from builder stage
COPY --from=builder /src/public /usr/share/nginx/html

# Set proper ownership
RUN chown -R nginx-user:nginx-user /usr/share/nginx/html && \
    chown -R nginx-user:nginx-user /var/cache/nginx && \
    chown -R nginx-user:nginx-user /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginx-user:nginx-user /var/run/nginx.pid

# Switch to non-root user
USER nginx-user

# Expose port (non-privileged)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

