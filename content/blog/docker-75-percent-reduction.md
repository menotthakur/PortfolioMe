---
title: "Docker Image Optimization: The 75% Reduction Story"
date: 2024-11-20
description: "How I reduced a production Docker image from 3.1GB to 1.2GB without breaking anything - lessons from over-optimization and finding the right balance."
tags: ["docker", "devops", "optimization", "production"]
---

When I joined Solytics Partners as a DevOps Intern, one of my first tasks was optimizing our Docker images. Our Nimbus Console service was running a **3.1GB Docker image**, and it was slowing down deployments significantly.

I managed to reduce it by **60-75%**, but not without learning some hard lessons about over-optimization.

## The Problem

Our production image was massive:

```dockerfile
FROM python:3.10  # Base image alone: ~900MB
RUN apt-get install openjdk-11-jdk  # Java: +200MB
RUN playwright install  # All browsers: +1GB
RUN Rscript install_r.sh  # R environment: +500MB
# ... 100+ Python packages: +500MB
```

**Total: 3.1GB**

This meant:
- **8-10 minute deployment times**
- **High storage costs** on container registries
- **Slow CI/CD pipelines**
- **Network bandwidth waste**

## My Initial Approach: Maximum Optimization

As a fresh DevOps intern eager to prove myself, I went all-in on optimization. I created a complex multi-stage Dockerfile:

```dockerfile
# Build stage with ALL dev dependencies
FROM python:3.10-slim AS builder
WORKDIR /build
RUN apt-get update && apt-get install -y \
    build-essential gcc g++ gfortran \
    libxml2-dev libxmlsec1-dev pkg-config \
    # ... 20+ build dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Runtime stage - copy only needed files
FROM python:3.10-slim
COPY --from=builder /install /usr/local
RUN playwright install chromium  # Only Chromium, not all browsers
# ... complex virtual env setup
```

**Result: 600MB (80% reduction!)**

I was thrilled. I showed it to my team lead.

## The Reality Check

My lead asked me one question: **"Did you test it in staging?"**

I hadn't. When I did, we found:

### Issues with Maximum Optimization:

1. **Typo propagation**: I fixed `PYTHONUBUFFERED` → `PYTHONUNBUFFERED`, but turns out the app depended on the typo
2. **Java version mismatch**: Generic system JDK behaved differently than OpenJDK 11.0.20
3. **Playwright failures**: Some tests needed Firefox, not just Chromium
4. **R package issues**: Complex copying between stages broke some R dependencies

Each fix took hours of debugging. The 80% size reduction wasn't worth the production risk.

## The Better Solution: Minimal Optimization

My lead suggested: **"What if you just change the base image?"**

```dockerfile
# Original
FROM python:3.10  # 900MB

# Optimized
FROM python:3.10-slim  # 150MB
```

That single change saved **750MB (25%)**.

Then I added a few more low-risk optimizations:

```dockerfile
FROM python:3.10-slim

# Use --no-install-recommends to skip unnecessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl zip unzip bash jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Combine commands to reduce layers
RUN pip install --no-cache-dir -r requirements.txt \
    && pip cache purge
```

**Result: 1.2GB (60% reduction)**

## The Numbers

| Approach | Size | Time to Build | Risk | My Recommendation |
|----------|------|---------------|------|-------------------|
| Original | 3.1GB | 8 min | Low | ❌ Too large |
| Minimal Optimization | 1.2GB | 6 min | **Low** | ✅ **Best** |
| Maximum Optimization | 600MB | 10 min | High | ⚠️ Over-engineered |

## Why Minimal Won

The minimal approach gave us:
- **60% size reduction** (good enough!)
- **Zero breaking changes** (production-safe)
- **Easy to understand** (maintainable)
- **Quick to implement** (no complex testing)

The additional 20% from maximum optimization wasn't worth:
- Days of debugging
- Complex multi-stage logic
- Higher risk of subtle bugs
- Harder for team to maintain

## Key Lessons Learned

### 1. Don't Over-Optimize

As my lead said: *"Perfect is the enemy of good."*

60% reduction with zero risk beats 80% reduction with production incidents.

### 2. Low-Hanging Fruit First

These simple changes give massive returns:
- Switch to `slim` or `alpine` base images
- Add `--no-cache-dir` to pip
- Use `--no-install-recommends` for apt
- Clean up caches (`rm -rf /var/lib/apt/lists/*`)

### 3. Measure Risk vs Reward

Every optimization has a cost:
- Time to implement
- Testing complexity
- Production risk
- Maintenance burden

Only optimize if the benefit outweighs all costs.

### 4. Test in Staging First

No matter how confident you are, test everything in a staging environment that mirrors production.

## The Tools I Used

### 1. Dive - Analyze Image Layers
```bash
dive methakur-portfolio:test
```
Shows which layers are largest.

### 2. docker image history
```bash
docker image history methakur-portfolio:test
```
See size of each layer.

### 3. docker-slim (Careful!)
```bash
docker-slim build --http-probe methakur-portfolio:test
```
Automatic minification - but thoroughly test output!

## What I'd Do Differently

If I started over today:

1. ✅ Start with `python:3.10-slim` immediately
2. ✅ Profile the image with `dive` before optimizing
3. ✅ Make small changes, test each one
4. ✅ Document why each dependency is needed
5. ✅ Set up automated size checks in CI

## Real-World Impact

After deploying the minimal optimization:
- **Deployment time**: 8 min → 3 min (62% faster)
- **Storage saved**: ~500GB across all environments
- **CI/CD faster**: Faster image pulls in GitHub Actions
- **Team happy**: No production incidents

## Conclusion

Docker optimization is important, but **production stability is more important**.

The best optimization is one that:
- ✅ Works in production
- ✅ Your team can maintain
- ✅ Doesn't require PhD-level Docker knowledge

Start with the simple wins. Only go deeper if you really need to.

**60% reduction > 0% reduction every time.**

