# Munish Thakur - Portfolio & Blog

A Hugo-powered portfolio website with complete DevOps infrastructure as proof-of-work.

**Live Site:** [https://methakur.info](https://methakur.info)

## Features

- **Hugo Static Site Generator** - Fast, Go-based SSG with markdown blog support
- **GitHub Pages Deployment** - Free, reliable hosting with custom domain
- **Docker Support** - Multi-stage Dockerfile with production-grade Nginx
- **Kubernetes Manifests** - Production-ready K8s configs with Kustomize
- **Helm Chart** - Templated, reusable deployment package
- **CI/CD Pipeline** - GitHub Actions for automated builds and deployments

## Quick Start

### Prerequisites

- [Hugo](https://gohugo.io/installation/) (v0.139.0+)
- [Docker](https://docs.docker.com/get-docker/) (optional)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (optional)
- [Helm](https://helm.sh/docs/intro/install/) (optional)

### Local Development

```bash
# Clone the repository
git clone https://github.com/menotthakur/portfolio.git
cd portfolio

# Run Hugo dev server
hugo server --buildDrafts

# Open http://localhost:1313
```

### Using Docker

```bash
# Development server with live reload
docker-compose --profile dev up hugo-dev

# Production build
docker-compose up --build

# Open http://localhost:8080
```

## Project Structure

```
.
├── .github/workflows/      # CI/CD pipelines
│   └── deploy.yml          # Hugo build + GitHub Pages deploy
├── content/                # Markdown content
│   ├── _index.md           # Homepage
│   └── blog/               # Blog posts
├── layouts/                # Hugo templates
│   ├── _default/           # Base templates
│   ├── blog/               # Blog templates
│   └── index.html          # Homepage template
├── static/                 # Static assets
│   ├── assets/             # JS, CSS, favicon
│   └── images/             # Images
├── k8s/                    # Kubernetes manifests
│   ├── base/               # Base resources
│   └── overlays/           # Environment overlays (dev/prod/local)
├── charts/                 # Helm charts
│   └── portfolio/          # Main Helm chart
├── Dockerfile              # Multi-stage Docker build
├── docker-compose.yml      # Local development
├── nginx.conf              # Nginx configuration
└── hugo.toml               # Hugo configuration
```

## Deployment Options

### 1. GitHub Pages (Production)

Automatically deployed on push to `main` branch via GitHub Actions.

```bash
# Push to main branch
git push origin main
# GitHub Actions will build and deploy automatically
```

### 2. Docker

```bash
# Build image
docker build -t methakur-portfolio:latest .

# Run container
docker run -p 8080:8080 methakur-portfolio:latest
```

### 3. Kubernetes (Local - Minikube)

```bash
# Start Minikube
minikube start

# Build image in Minikube
eval $(minikube docker-env)
docker build -t methakur-portfolio:local .

# Deploy with Kustomize
kubectl apply -k k8s/overlays/local

# Enable ingress
minikube addons enable ingress

# Access
echo "$(minikube ip) portfolio.local" | sudo tee -a /etc/hosts
curl http://portfolio.local
```

### 4. Helm

```bash
# Install
helm install portfolio ./charts/portfolio

# With custom values
helm install portfolio ./charts/portfolio \
  --set replicaCount=3 \
  --set ingress.hosts[0].host=mysite.com
```

## Writing Blog Posts

Create a new markdown file in `content/blog/`:

```bash
hugo new blog/my-new-post.md
```

Or manually create:

```markdown
---
title: "My New Post"
date: 2024-12-01
description: "A description of my post"
tags: ["devops", "kubernetes"]
---

Your content here...
```

## DevOps Artifacts

This repository serves as proof-of-work for DevOps skills:

| Component | Purpose |
|-----------|---------|
| `Dockerfile` | Multi-stage build, non-root user, security hardening |
| `nginx.conf` | Production Nginx with gzip, caching, security headers |
| `k8s/base/` | Deployment, Service, Ingress, HPA, NetworkPolicy, PDB |
| `k8s/overlays/` | Kustomize overlays for dev/prod/local environments |
| `charts/portfolio/` | Fully templated Helm chart |
| `.github/workflows/` | CI/CD with Hugo build, Docker build, GitHub Pages deploy |

## DNS Configuration

For custom domain (methakur.info), configure these DNS records:

| Type | Name | Value |
|------|------|-------|
| A | @ | 185.199.108.153 |
| A | @ | 185.199.109.153 |
| A | @ | 185.199.110.153 |
| A | @ | 185.199.111.153 |
| CNAME | www | menotthakur.github.io |

## Tech Stack

- **SSG:** Hugo
- **Hosting:** GitHub Pages
- **Container:** Docker + Nginx
- **Orchestration:** Kubernetes
- **Package Manager:** Helm
- **CI/CD:** GitHub Actions
- **DNS:** Custom domain

## Author

**Munish Thakur** - DevOps Engineer

- Website: [methakur.info](https://methakur.info)
- LinkedIn: [munish--thakur](https://www.linkedin.com/in/munish--thakur/)
- GitHub: [menotthakur](https://github.com/menotthakur)
- Email: thakurmunish2806@gmail.com

## License

MIT License - feel free to use this as a template for your own portfolio!
