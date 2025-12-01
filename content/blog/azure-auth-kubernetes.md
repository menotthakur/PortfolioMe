---
title: "Azure Authentication in Kubernetes: A Troubleshooting Guide"
date: 2024-10-28
description: "How to fix DefaultAzureCredential authentication failures in Kubernetes pods - 5 solutions from quick fixes to production-ready setups."
tags: ["azure", "kubernetes", "devops", "authentication"]
---

Django migrations were failing in our Kubernetes cluster. The error looked innocent enough:

```python
azure.identity._exceptions.ClientAuthenticationError: 
DefaultAzureCredential failed to retrieve a token from the included credentials.
```

But this single error was blocking all database migrations, meaning **no deployments**.

## The Problem

Our Django app used Azure Blob Storage for file uploads. During migration, Django initializes all storage backends - including Azure. But the pod had no credentials.

### Understanding DefaultAzureCredential

Azure's `DefaultAzureCredential` tries authentication methods in this order:

```
1. Environment Variables (AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, etc.)
   ↓ Failed
2. Managed Identity (if running on Azure)
   ↓ Failed
3. Azure CLI (if installed and logged in)
   ↓ Failed
4. Azure PowerShell
   ↓ Failed
5. Interactive Browser
   ↓ Failed (no browser in container)
```

**All failed.** The pod had zero Azure credentials.

## The Investigation

First, I checked what environment variables were set:

```bash
kubectl exec -it backend-django-xyz -- env | grep AZURE

# Output:
AZURE_TENANT_ID=1bb287c4-8e33-476f-bf7b-a5e274c5b0e6
AZURE_CLIENT_ID=155e997f-5471-4fab-b75c-280a807716da
AZURE_STORAGE_ACCOUNT_NAME=solyticspocgcstorage
# AZURE_CLIENT_SECRET is MISSING!
```

Missing: `AZURE_CLIENT_SECRET` - the most important one.

## Solution 1: Quick Fix with Environment Variables

The fastest fix for development:

```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: backend
        env:
        - name: AZURE_CLIENT_SECRET
          value: "your-secret-here"  # DON'T DO THIS IN PROD
```

**But this is insecure** - secrets visible in deployment YAML.

## Solution 2: Use Kubernetes Secrets (Better)

Create a secret:

```bash
kubectl create secret generic azure-credentials \
  --from-literal=AZURE_CLIENT_SECRET='your-secret-here' \
  --from-literal=AZURE_TENANT_ID='1bb287c4-8e33-476f-bf7b-a5e274c5b0e6' \
  --from-literal=AZURE_CLIENT_ID='155e997f-5471-4fab-b75c-280a807716da' \
  -n production
```

Reference in deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: backend
        envFrom:
        - secretRef:
            name: azure-credentials
```

Better, but secrets are still base64-encoded (not encrypted).

## Solution 3: Azure Key Vault with CSI Driver (Production)

This is what we implemented at Solytics:

### Step 1: Install Azure Key Vault CSI Driver

```bash
helm repo add csi-secrets-store-provider-azure \
  https://azure.github.io/secrets-store-csi-driver-provider-azure/charts

helm install csi-secrets-store-provider-azure/csi-secrets-store-provider-azure \
  --namespace kube-system
```

### Step 2: Create SecretProviderClass

```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-credentials
spec:
  provider: azure
  parameters:
    keyvaultName: "solytics-keyvault"
    tenantId: "1bb287c4-8e33-476f-bf7b-a5e274c5b0e6"
    objects: |
      array:
        - |
          objectName: "azure-client-secret"
          objectType: "secret"
```

### Step 3: Mount in Pod

```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: backend
        volumeMounts:
        - name: azure-secrets
          mountPath: "/mnt/secrets"
          readOnly: true
        env:
        - name: AZURE_CLIENT_SECRET
          valueFrom:
            secretKeyRef:
              name: azure-credentials
              key: azure-client-secret
      volumes:
      - name: azure-secrets
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: "azure-credentials"
```

**Benefits:**
- Secrets stored in Azure Key Vault (encrypted)
- Automatic rotation
- Audit logs
- No secrets in Git

## Solution 4: Managed Identity (Azure AKS Only)

If you're running on Azure AKS, use Managed Identity (no secrets needed!):

### Enable in AKS

```bash
az aks update \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --enable-managed-identity
```

### Create Identity and Assign Permissions

```bash
# Create managed identity
az identity create \
  --name backend-identity \
  --resource-group myResourceGroup

# Assign Storage Blob Data Contributor role
az role assignment create \
  --assignee <identity-client-id> \
  --role "Storage Blob Data Contributor" \
  --scope /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<storage-account>
```

### Use in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    aadpodidbinding: backend-identity
spec:
  containers:
  - name: backend
    # No env vars needed - Managed Identity just works!
```

Python code automatically uses Managed Identity:

```python
from azure.identity import DefaultAzureCredential
credential = DefaultAzureCredential()  # Automatically finds Managed Identity
```

## Solution 5: Azure CLI in Container (Dev/Debug Only)

For local development or debugging:

```dockerfile
FROM python:3.10-slim

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Login (interactive)
RUN az login
```

Then in the container:

```bash
az login
python manage.py migrate  # Now works with Azure CLI credentials
```

**Not recommended for production** - requires interactive login.

## What I Implemented at Solytics

We used a hybrid approach:

### Development: K8s Secrets
- Quick to set up
- Easy to debug
- Acceptable for non-prod

### Production: Azure Key Vault CSI Driver
- Secrets in Key Vault
- Automatic rotation
- Full audit trail
- Compliant with security policies

### CI/CD: Service Principal
- Environment variables in GitHub Actions
- Limited scope (only CI/CD pipeline access)
- Separate from production credentials

## Common Pitfalls

### 1. Client Secret Not Base64 Encoded

```bash
# Wrong - encoding the secret
kubectl create secret generic azure-creds \
  --from-literal=AZURE_CLIENT_SECRET=$(echo -n 'secret' | base64)

# Right - Kubernetes does encoding automatically
kubectl create secret generic azure-creds \
  --from-literal=AZURE_CLIENT_SECRET='secret'
```

### 2. Missing Tenant ID

`DefaultAzureCredential` needs ALL three:
- AZURE_TENANT_ID
- AZURE_CLIENT_ID
- AZURE_CLIENT_SECRET

Missing any one → authentication fails.

### 3. Permissions Not Granted

Even with valid credentials, you need proper RBAC:

```bash
# Check role assignments
az role assignment list \
  --assignee <client-id> \
  --output table
```

### 4. Wrong Subscription Context

```python
# Specify subscription explicitly
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient

credential = DefaultAzureCredential()
blob_client = BlobServiceClient(
    account_url="https://account.blob.core.windows.net",
    credential=credential,
    subscription_id="your-subscription-id"  # ← Explicit
)
```

## Debugging Commands

### 1. Test Authentication in Pod

```bash
kubectl exec -it backend-django-xyz -- python3 -c "
from azure.identity import DefaultAzureCredential
try:
    credential = DefaultAzureCredential()
    token = credential.get_token('https://storage.azure.com/.default')
    print('✅ Authentication successful')
except Exception as e:
    print(f'❌ Authentication failed: {e}')
"
```

### 2. Check Azure CLI

```bash
kubectl exec -it backend-django-xyz -- az account show
```

### 3. Verify Environment Variables

```bash
kubectl exec -it backend-django-xyz -- env | grep AZURE | sort
```

### 4. Check Managed Identity

```bash
# From inside the pod
curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://storage.azure.com/' -H Metadata:true
```

## The Decision Matrix

| Method | Security | Setup Time | Rotation | Cost | Production Ready |
|--------|----------|------------|----------|------|------------------|
| Env Vars | ❌ Low | ⚡ 5 min | Manual | Free | ❌ No |
| K8s Secrets | ⚠️ Medium | ⚡ 10 min | Manual | Free | ⚠️ Dev only |
| Key Vault CSI | ✅ High | 🕐 1 hour | Auto | $$ | ✅ Yes |
| Managed Identity | ✅ High | 🕐 30 min | Auto | Free | ✅ Yes |
| Azure CLI | ❌ Low | ⚡ 5 min | Manual | Free | ❌ No |

## What I Learned

### 1. DefaultAzureCredential is Not Magic

It's a convenience wrapper that tries multiple methods. You need to set up at least ONE method properly.

### 2. Start Simple, Upgrade Later

- Dev: Environment variables
- Staging: K8s Secrets
- Production: Key Vault or Managed Identity

Don't over-engineer on day one.

### 3. Document Which Method You're Using

Add this to your deployment YAML:

```yaml
metadata:
  annotations:
    azure-auth-method: "key-vault-csi"
    azure-keyvault-name: "solytics-keyvault"
```

Future you will thank past you.

### 4. Test in a Scratch Pod First

Before modifying production:

```bash
kubectl run -it --rm debug --image=mcr.microsoft.com/azure-cli \
  --env AZURE_CLIENT_SECRET=xxx \
  --env AZURE_TENANT_ID=xxx \
  --env AZURE_CLIENT_ID=xxx \
  -- bash

# Then test inside:
az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
```

## Conclusion

Azure authentication in Kubernetes isn't plug-and-play. You need to explicitly configure one of the credential methods.

**For Production**: Use Managed Identity (if on Azure AKS) or Key Vault CSI Driver (if on any K8s).

**For Development**: K8s Secrets are fine - just don't commit them to Git.

**The key insight**: `DefaultAzureCredential` is a chain of authentication attempts. If all attempts fail, you get that cryptic error. Make sure at least ONE attempt succeeds.

And always test authentication **before** it breaks your migrations in production. 😅

