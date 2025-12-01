# Kubernetes Manifests for Portfolio Site

This directory contains production-ready Kubernetes manifests for deploying the portfolio site.

## Structure

```
k8s/
├── base/                    # Base manifests (shared)
│   ├── kustomization.yaml   # Kustomize config
│   ├── namespace.yaml       # Namespace definition
│   ├── deployment.yaml      # Deployment with security contexts
│   ├── service.yaml         # ClusterIP service
│   ├── ingress.yaml         # Ingress with TLS
│   ├── hpa.yaml             # Horizontal Pod Autoscaler
│   ├── networkpolicy.yaml   # Network security policy
│   └── pdb.yaml             # Pod Disruption Budget
└── overlays/                # Environment-specific overlays
    ├── dev/                 # Development environment
    ├── prod/                # Production environment
    └── local/               # Local testing (Minikube/Kind)
```

## Usage

### Local Testing with Minikube

```bash
# Start Minikube
minikube start

# Build the Docker image in Minikube's Docker daemon
eval $(minikube docker-env)
docker build -t methakur-portfolio:local .

# Apply the local overlay
kubectl apply -k k8s/overlays/local

# Get the Minikube IP and add to /etc/hosts
echo "$(minikube ip) portfolio.local" | sudo tee -a /etc/hosts

# Enable ingress addon
minikube addons enable ingress

# Access the site
curl http://portfolio.local
```

### Local Testing with Kind

```bash
# Create Kind cluster
kind create cluster --name portfolio

# Build and load the image
docker build -t methakur-portfolio:local .
kind load docker-image methakur-portfolio:local --name portfolio

# Apply the local overlay
kubectl apply -k k8s/overlays/local

# Port forward to access
kubectl port-forward -n portfolio-local svc/local-portfolio 8080:80
```

### Development Environment

```bash
# Apply dev overlay
kubectl apply -k k8s/overlays/dev

# Check deployment status
kubectl -n portfolio-dev get pods,svc,ingress
```

### Production Deployment

```bash
# Apply production overlay
kubectl apply -k k8s/overlays/prod

# Monitor rollout
kubectl -n portfolio rollout status deployment/portfolio
```

## Features

### Security
- Non-root container user
- Security contexts with dropped capabilities
- Network policies for traffic control
- Read-only root filesystem considerations

### High Availability
- Multiple replicas with anti-affinity
- Pod Disruption Budget
- Horizontal Pod Autoscaler
- Rolling update strategy

### Observability
- Health check endpoints (`/health`)
- Prometheus annotations for scraping
- Structured logging via Nginx

## Prerequisites

- Kubernetes 1.25+
- Nginx Ingress Controller
- cert-manager (for TLS in production)
- Metrics Server (for HPA)

## Customization

To customize for your environment:

1. Update the image reference in the overlay's `kustomization.yaml`
2. Modify ingress hosts for your domain
3. Adjust resource limits based on your needs
4. Configure TLS secrets or cert-manager issuer

