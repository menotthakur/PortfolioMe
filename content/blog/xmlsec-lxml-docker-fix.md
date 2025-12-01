---
title: "Fixing XMLSec/LXML Version Mismatch: When Installation Order Matters"
date: 2024-11-05
description: "A deep dive into resolving xmlsec.Error: lxml & xmlsec libxml2 library version mismatch in Docker - and why the order of pip install matters more than you think."
tags: ["docker", "python", "debugging", "dependencies"]
---

Sometimes the most frustrating bugs are the ones with cryptic error messages. This was one of them.

```python
>>> from onelogin.saml2.auth import OneLogin_Saml2_Auth
xmlsec.Error: (100, 'lxml & xmlsec libxml2 library version mismatch')
```

The application container was crashing on startup, and all I had was this error message.

## The Problem

Our Django application needed SAML authentication, which required `python3-saml`. This package depends on both `lxml` and `xmlsec`, which both depend on the system library `libxml2`.

The error meant: **`lxml` and `xmlsec` were compiled against different versions of `libxml2`**.

## Why This Happens

### The Binary Wheel Problem

When you run `pip install lxml`, pip can either:
1. **Download a pre-built binary wheel** (compiled by someone else)
2. **Compile from source** (using your system's libxml2)

If one package uses a binary wheel and the other compiles from source, they'll link to different `libxml2` versions.

```bash
# lxml might be compiled against libxml2 2.9.10
# xmlsec might be compiled against libxml2 2.9.14
# Result: Version mismatch error
```

## The Original Dockerfile (Broken)

```dockerfile
FROM python:3.10

# Install application dependencies first
RUN pip install git+https://github.com/some/package.git
RUN pip install python3-saml

# Install system libraries AFTER pip (wrong order!)
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libxmlsec1-dev \
    libxmlsec1-openssl

# Try to fix it (too late!)
RUN pip install --force-reinstall --no-binary lxml lxml
```

### Why This Fails

1. `pip install python3-saml` installs `lxml` and `xmlsec` as **binary wheels**
2. **Then** we install the system dev libraries
3. Trying to reinstall just `lxml` from source doesn't help - `xmlsec` is still the binary version

## The Fix: Order Matters

```dockerfile
FROM python:3.10

# Step 1: Install system dependencies FIRST
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libxmlsec1-dev \
    libxmlsec1-openssl \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Step 2: Compile lxml from source
RUN pip install --no-binary lxml lxml

# Step 3: Compile xmlsec from source  
RUN pip install --no-binary xmlsec xmlsec

# Step 4: NOW install packages that depend on them
RUN pip install python3-saml

# Step 5: Install other application dependencies
RUN pip install -r requirements.txt
```

### Key Changes

1. ✅ System libraries installed **before** any Python packages
2. ✅ Both `lxml` and `xmlsec` compiled from source with `--no-binary`
3. ✅ Explicit installation order matters

## The Multi-Stage Optimization

Once it worked, I optimized it with a multi-stage build:

```dockerfile
# ==============================
# Stage 1: Build dependencies
# ==============================
FROM python:3.10-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libxml2-dev \
    libxmlsec1-dev \
    libxmlsec1-openssl \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Compile lxml and xmlsec from source
RUN pip install --no-cache-dir --no-binary lxml lxml
RUN pip install --no-cache-dir --no-binary xmlsec xmlsec

# Install python3-saml and other deps
RUN pip install --no-cache-dir python3-saml
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ==============================
# Stage 2: Runtime
# ==============================
FROM python:3.10-slim

# Install only runtime libraries (not dev packages)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxml2 \
    libxmlsec1-openssl \
    && rm -rf /var/lib/apt/lists/*

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application
COPY . /app
WORKDIR /app

CMD ["python", "manage.py", "runserver"]
```

**Result**: Image size reduced from 1.2GB → 800MB, and the import works perfectly.

## Debugging Tips

### 1. Check Library Versions

```python
import lxml
import xmlsec

print(f"lxml version: {lxml.__version__}")
print(f"xmlsec version: {xmlsec.__version__}")

# Check which libxml2 they're using
import lxml.etree as et
print(f"lxml libxml2: {et.LIBXML_VERSION}")
```

### 2. Force Rebuild from Source

```bash
pip install --force-reinstall --no-binary :all: lxml xmlsec
```

The `:all:` tells pip to compile everything from source.

### 3. Use Build Isolation

```bash
pip install --no-build-isolation lxml xmlsec
```

Sometimes build isolation causes issues.

## Similar Issues You Might Face

This "version mismatch" pattern happens with other C-extension Python packages:

| Package Pair | Common Library | Error |
|--------------|----------------|-------|
| `lxml` + `xmlsec` | `libxml2` | Version mismatch |
| `psycopg2` + `psycopg2-binary` | `libpq` | Conflicts |
| `numpy` + `pandas` | BLAS libraries | Import errors |
| `PIL` + `Pillow` | Image libraries | Conflicts |

**Solution is always the same:**
1. Install system dev libraries first
2. Compile packages from source
3. Maintain consistent versions

## What I Learned

### 1. Installation Order is Critical

In Docker, the order of `RUN` commands matters more than most people realize.

### 2. Binary Wheels Are Convenient But Risky

Pre-built wheels save build time but can cause version conflicts. For critical dependencies, compile from source.

### 3. Multi-Stage Builds Solve Two Problems

- Build stage: All dev dependencies for compilation
- Runtime stage: Only minimal runtime libraries
- Result: Smaller images + clean dependencies

### 4. Document the "Why"

I added comments explaining the order:

```dockerfile
# CRITICAL: Install system libs FIRST
# This ensures lxml and xmlsec compile against same libxml2
RUN apt-get install libxml2-dev libxmlsec1-dev

# CRITICAL: Compile both from source for version compatibility
RUN pip install --no-binary lxml lxml
RUN pip install --no-binary xmlsec xmlsec
```

Future me (and teammates) will thank past me.

## The Checklist

When facing Python C-extension issues in Docker:

- [ ] Install system dev libraries **before** pip packages
- [ ] Use `--no-binary` for packages with C extensions
- [ ] Compile dependent packages in the right order
- [ ] Check library versions with `-c "import pkg; print(pkg.__version__)"`
- [ ] Test the import in a fresh container
- [ ] Consider multi-stage build for production

## Tools That Help

### 1. Check What's Inside a Package

```bash
pip show lxml
# Location: /usr/local/lib/python3.10/site-packages
# Files: ... .so files (compiled C extensions)
```

### 2. ldd - Check Library Dependencies

```bash
ldd /usr/local/lib/python3.10/site-packages/lxml/*.so
# Shows which libxml2 it's linked against
```

### 3. Docker Build Cache

```bash
# Rebuild without cache to ensure clean slate
docker build --no-cache -t app:test .
```

## Conclusion

Dependency management in Docker is more nuanced than `pip install -r requirements.txt`.

When packages have C extensions:
1. **System libraries first**
2. **Compile from source for consistency**
3. **Test thoroughly**

This took me 6 hours to debug the first time. By documenting it here, hopefully I can save you those 6 hours.

**Remember**: The error message might be cryptic, but the solution is simple - **respect the order**.

