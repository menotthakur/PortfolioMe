---
title: "Docker Image Optimization: Lessons from Production"
date: 2024-11-28
description: "Practical techniques to reduce Docker image size by 35% and build time by 75%, based on real-world experience."
tags: ["docker", "devops", "optimization", "containers"]
---

At Solytics Partners, I optimized Docker images and achieved a 35% size reduction and 75% faster build times. Here's what I learned.

## The Problem

Most Dockerfiles I inherited looked like this:

```dockerfile
FROM python:3.11
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
```

This creates images that are:
- **Huge**: 1GB+ for a simple Python app
- **Insecure**: Running as root
- **Slow to build**: No layer caching optimization

## The Solution: Multi-stage Builds

```dockerfile
# Build stage
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Production stage  
FROM python:3.11-slim
WORKDIR /app

# Create non-root user
RUN useradd --create-home --shell /bin/bash appuser
USER appuser

# Copy only what we need
COPY --from=builder /root/.local /home/appuser/.local
COPY --chown=appuser:appuser . .

ENV PATH=/home/appuser/.local/bin:$PATH
CMD ["python", "app.py"]
```

## Key Techniques

### 1. Use Slim/Alpine Base Images

| Base Image | Size |
|------------|------|
| python:3.11 | 1.01GB |
| python:3.11-slim | 131MB |
| python:3.11-alpine | 51MB |

### 2. Multi-stage Builds

Separate build dependencies from runtime:

```dockerfile
# Stage 1: Build with all tools
FROM golang:1.21 AS builder
# ... build your app

# Stage 2: Runtime with minimal dependencies
FROM gcr.io/distroless/base
COPY --from=builder /app/binary /app/binary
```

### 3. Order Layers for Caching

Put things that change least at the top:

```dockerfile
# 1. Base image (rarely changes)
FROM node:18-alpine

# 2. System dependencies (occasionally changes)
RUN apk add --no-cache git

# 3. Package files (changes with new dependencies)
COPY package*.json ./
RUN npm ci --only=production

# 4. Application code (changes frequently)
COPY . .
```

### 4. Use .dockerignore

```dockerignore
.git
node_modules
*.md
.env*
Dockerfile*
docker-compose*
```

### 5. Non-root User

Always run as non-root:

```dockerfile
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup
USER appuser
```

## Results

After applying these techniques across our Django microservices:

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Image Size | 1.2GB | 780MB | 35% smaller |
| Build Time | 8 min | 2 min | 75% faster |
| CVE Count | 142 | 23 | 84% fewer |

## Tools I Use

1. **dive**: Analyze image layers
   ```bash
   dive your-image:tag
   ```

2. **docker-slim**: Automatically minify images
   ```bash
   docker-slim build your-image:tag
   ```

3. **trivy**: Scan for vulnerabilities
   ```bash
   trivy image your-image:tag
   ```

## Conclusion

Docker optimization isn't just about smaller images—it's about:
- Faster CI/CD pipelines
- Reduced storage costs
- Better security posture
- Quicker deployments

Start with multi-stage builds and non-root users. These two changes alone will dramatically improve your containerized applications.

