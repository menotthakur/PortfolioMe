# Portfolio Helm Chart

A Helm chart for deploying Munish Thakur's portfolio website on Kubernetes.

## Prerequisites

- Kubernetes 1.25+
- Helm 3.0+
- Nginx Ingress Controller (for ingress)
- cert-manager (for TLS certificates)

## Installation

### Add the repository (if published)

```bash
helm repo add portfolio https://menotthakur.github.io/portfolio
helm repo update
```

### Install from local chart

```bash
# From the repository root
helm install portfolio ./charts/portfolio

# With custom values
helm install portfolio ./charts/portfolio -f custom-values.yaml

# In a specific namespace
helm install portfolio ./charts/portfolio -n portfolio --create-namespace
```

## Configuration

The following table lists the configurable parameters and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `2` |
| `image.repository` | Image repository | `ghcr.io/menotthakur/portfolio` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.hosts` | Ingress hosts | `[methakur.info]` |
| `resources.limits.cpu` | CPU limit | `100m` |
| `resources.limits.memory` | Memory limit | `128Mi` |
| `autoscaling.enabled` | Enable HPA | `true` |
| `autoscaling.minReplicas` | Minimum replicas | `2` |
| `autoscaling.maxReplicas` | Maximum replicas | `10` |

## Usage Examples

### Development deployment

```bash
helm install portfolio-dev ./charts/portfolio \
  --set replicaCount=1 \
  --set autoscaling.enabled=false \
  --set ingress.hosts[0].host=dev.methakur.info
```

### Production deployment with custom resources

```bash
helm install portfolio ./charts/portfolio \
  --set resources.limits.cpu=200m \
  --set resources.limits.memory=256Mi \
  --set autoscaling.minReplicas=3
```

### Upgrade

```bash
helm upgrade portfolio ./charts/portfolio
```

### Uninstall

```bash
helm uninstall portfolio
```

## Maintainers

| Name | Email |
|------|-------|
| Munish Thakur | thakurmunish2806@gmail.com |

## License

MIT

