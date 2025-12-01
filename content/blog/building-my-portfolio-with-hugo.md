---
title: "Building My Portfolio: From HTML to Hugo"
date: 2024-12-01
description: "How I converted a simple HTML portfolio into a Hugo-powered blog with Docker, Kubernetes, and GitHub Actions as proof-of-work."
tags: ["devops", "hugo", "docker", "kubernetes", "github-actions"]
---

When I decided to build my portfolio, I had a choice: keep it simple with plain HTML, or use it as an opportunity to demonstrate my DevOps skills. I chose the latter.

## Why Hugo?

Hugo is a static site generator written in Go. Here's why it made sense for a DevOps engineer:

1. **Speed**: Hugo builds are blazing fast (milliseconds, not minutes)
2. **No runtime dependencies**: The output is just HTML, CSS, and JS
3. **DevOps-friendly**: The Kubernetes documentation itself uses Hugo
4. **Markdown-based**: Write content in Markdown, focus on writing

## The Architecture

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────────┐
│  Markdown Files │────▶│  Hugo Build  │────▶│  Static Files   │
└─────────────────┘     └──────────────┘     └─────────────────┘
                                                      │
                              ┌───────────────────────┼───────────────────────┐
                              │                       │                       │
                              ▼                       ▼                       ▼
                     ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
                     │  GitHub Pages   │     │  Docker/Nginx   │     │  Kubernetes     │
                     │   (Production)  │     │   (Local Dev)   │     │  (Proof of Work)│
                     └─────────────────┘     └─────────────────┘     └─────────────────┘
```

## The DevOps Artifacts

This repository isn't just a portfolio—it's a showcase of DevOps practices:

### 1. Multi-stage Dockerfile

```dockerfile
# Build stage
FROM hugomods/hugo:latest AS builder
WORKDIR /src
COPY . .
RUN hugo --minify

# Production stage
FROM nginx:alpine
COPY --from=builder /src/public /usr/share/nginx/html
```

The image is optimized following best practices I learned at Solytics:
- Multi-stage builds for minimal image size
- Non-root user for security
- Alpine base for smaller footprint

### 2. Kubernetes Manifests

Production-ready manifests with:
- Resource limits and requests
- Liveness and readiness probes
- Security contexts
- Horizontal Pod Autoscaler

### 3. Helm Chart

A properly templated Helm chart that makes deployment configurable across environments.

### 4. GitHub Actions CI/CD

Automated pipeline that:
- Builds the Hugo site
- Deploys to GitHub Pages
- Optionally builds and pushes Docker images

## Why This Matters

Running Kubernetes for a static blog is overkill in production. But having these artifacts in my repository demonstrates:

1. I understand **containerization** beyond `docker run`
2. I can write **production-ready Kubernetes manifests**
3. I know **Helm** templating and packaging
4. I can set up **CI/CD pipelines**

The blog content matters more than the infrastructure, but the infrastructure proves I can walk the talk.

## What's Next?

I plan to add:
- ArgoCD GitOps configuration
- Prometheus monitoring setup
- More blog posts about real DevOps challenges

Stay tuned!

