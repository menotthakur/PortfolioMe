---
title: "Debugging OOMKilled Pods in Production: A Step-by-Step Guide"
date: 2024-11-10
description: "What to do when your Kubernetes pods keep getting OOMKilled, how to diagnose memory issues, and when to increase resources vs optimize code."
tags: ["kubernetes", "debugging", "devops", "troubleshooting"]
---

It's Monday morning, and Slack is blowing up. The backend service is down. Again.

I SSH into the node and run `kubectl get pods`:

```bash
NAME                        READY   STATUS      RESTARTS   AGE
backend-django-7d8f9c-abcd  0/1     OOMKilled   5          10m
```

If you've worked with Kubernetes, you've seen this. **OOMKilled** means your pod tried to use more memory than allowed and got terminated by the kernel.

Here's how I debug it.

## What is OOMKilled?

**OOMKilled = Out Of Memory Killed**

It happens when a container exceeds its memory limit. The Linux kernel's OOM (Out Of Memory) killer terminates the process to protect the node.

### Why It Happens

```yaml
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: app
      resources:
        limits:
          memory: "512Mi"  # ← If container uses more, it dies
        requests:
          memory: "256Mi"
```

If your app tries to allocate more than 512Mi, Kubernetes kills it.

## Step 1: Confirm OOMKilled

```bash
# Check pod status
kubectl get pods -n production

# Look for STATUS: OOMKilled, CrashLoopBackOff, or high RESTARTS
```

## Step 2: Describe the Pod

This is where the investigation begins:

```bash
kubectl describe pod backend-django-7d8f9c-abcd -n production
```

Look for these sections:

### Containers Section
```yaml
Containers:
  app:
    Limits:
      memory: 512Mi  # ← Your memory ceiling
    Requests:
      memory: 256Mi
    State: Waiting
      Reason: CrashLoopBackOff
    Last State: Terminated
      Reason: OOMKilled  # ← Confirmation
      Exit Code: 137     # ← OOMKilled exit code
```

### Events Section
```
Events:
  Warning  BackOff  Back-off restarting failed container
  Warning  Failed   Error: OOMKilled
```

**Exit Code 137** always means OOMKilled (128 + 9, where 9 is SIGKILL).

## Step 3: Check Actual Memory Usage

### Option A: kubectl top (if metrics-server is running)
```bash
kubectl top pod backend-django-7d8f9c-abcd -n production
```

But wait - the pod is crashed. You can't get metrics from a dead pod.

### Option B: Check Previous Instance Logs

```bash
# Get logs from the crashed container
kubectl logs backend-django-7d8f9c-abcd -n production --previous
```

Look for memory-related errors:
- `java.lang.OutOfMemoryError`
- `MemoryError` in Python
- `FATAL: out of memory` in Postgres

### Option C: Check Prometheus/Grafana

Query historical memory usage before the crash:

```promql
container_memory_working_set_bytes{pod="backend-django-7d8f9c-abcd"}
```

## Step 4: Analyze the Root Cause

### Scenario 1: Memory Leak

If memory usage steadily increases over time, it's likely a memory leak in your application.

**Solution**: Fix the code, not the limits.

### Scenario 2: Traffic Spike

If memory spikes correlate with traffic, your app is under-resourced for peak load.

**Solution**: Increase resources OR add autoscaling.

### Scenario 3: Limits Too Low

If your app consistently uses near its limit during normal operation, limits are just too low.

**Solution**: Increase memory limits.

## Step 5: The Fix

### Quick Fix: Increase Memory Limits

```yaml
# Before
resources:
  limits:
    memory: "512Mi"
  requests:
    memory: "256Mi"

# After
resources:
  limits:
    memory: "1Gi"      # Doubled
  requests:
    memory: "512Mi"    # Also increase request
```

**Apply the change:**
```bash
kubectl apply -f deployment.yaml
kubectl rollout status deployment/backend-django
```

### Long-term Fix: Optimize the Application

Sometimes the app is inefficient:

**Common issues:**
- Loading entire datasets into memory
- Not using database pagination
- Memory-intensive operations without cleanup
- Cache without eviction policy

## My Real Production Case

At Solytics, our `modelestimation` service was getting OOMKilled:

```bash
$ kubectl top pod modelestimation-6f8d9c-xyz
NAME                          CPU    MEMORY
modelestimation-6f8d9c-xyz    200m   6.2Gi/4Gi
```

**Memory usage: 6.2 GiB**  
**Memory limit: 4 GiB**

### The Investigation

```bash
# Check logs
kubectl logs modelestimation-6f8d9c-xyz --previous

# Found this:
Loading full training dataset into memory... (5GB)
Building model...
OOMKilled
```

### The Fix

Option A: Increase memory to 7 GiB  
Option B: Optimize code to load data in batches

We did **Option A first** (get service back up), then **Option B** (proper fix).

```yaml
# Immediate fix
resources:
  limits:
    memory: "7Gi"
  requests:
    memory: "4Gi"
```

Then the dev team optimized data loading:

```python
# Before
df = pd.read_csv("large_dataset.csv")  # Loads all 5GB

# After
for chunk in pd.read_csv("large_dataset.csv", chunksize=10000):
    process(chunk)  # Process in 10K row chunks
```

Final memory usage: **2.5 GiB** (back under 4 GiB limit).

## Common Mistakes

### Mistake 1: Only Increasing Limits

If it's a memory leak, increasing limits just delays the inevitable.

### Mistake 2: Setting Limits = Requests

```yaml
# Bad practice
resources:
  requests:
    memory: "4Gi"
  limits:
    memory: "4Gi"  # Same as request
```

This prevents efficient bin-packing. Better:

```yaml
resources:
  requests:
    memory: "2Gi"   # What it normally uses
  limits:
    memory: "4Gi"   # Allow bursts up to 4Gi
```

### Mistake 3: No Limits At All

```yaml
resources:
  requests:
    memory: "1Gi"
  # No limits
```

One pod can consume all node memory and crash everything else.

## Prevention: Set Up Alerts

Don't wait for OOMKilled. Monitor memory usage:

### Prometheus Alert

```yaml
- alert: HighMemoryUsage
  expr: |
    container_memory_working_set_bytes / 
    container_spec_memory_limit_bytes > 0.8
  for: 5m
  annotations:
    summary: "Pod {{ $labels.pod }} using >80% memory"
```

### kubectl Events

```bash
# Watch for memory events
kubectl get events -n production --watch | grep -i memory
```

## Debugging Checklist

When you see OOMKilled:

- [ ] Run `kubectl describe pod <pod-name>`
- [ ] Check Exit Code (137 = OOMKilled)
- [ ] Review memory limits in pod spec
- [ ] Check logs: `kubectl logs <pod> --previous`
- [ ] Query Prometheus for historical memory usage
- [ ] Identify if it's a leak, spike, or under-provisioning
- [ ] Apply appropriate fix (increase limit OR optimize code)
- [ ] Monitor for 24-48 hours
- [ ] Set up alerts to prevent recurrence

## The Decision Tree

```
Pod OOMKilled?
    ↓
Is memory usage growing steadily?
    ├─ Yes → Memory leak → Fix code
    └─ No  → Continue
         ↓
Is it only during traffic spikes?
    ├─ Yes → Under-provisioned → Increase limits + HPA
    └─ No  → Continue
         ↓
Is it consistently near limit?
    ├─ Yes → Limits too low → Increase by 50-100%
    └─ No  → Investigate specific cause
```

## Tools for Memory Profiling

### For Python Apps
```bash
# Install memory-profiler
pip install memory-profiler

# Profile your function
@profile
def my_function():
    # Your code
```

### For JVM Apps
```bash
# Enable JVM memory dumps
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/tmp/heapdump.hprof
```

### For Node.js
```bash
# Check heap size
node --max-old-space-size=4096 app.js
```

## Conclusion

OOMKilled errors are common in Kubernetes. The key is:

1. **Diagnose properly** - Don't just blindly increase resources
2. **Understand the pattern** - Leak, spike, or under-provisioned?
3. **Fix the root cause** - Code optimization often better than bigger limits
4. **Monitor proactively** - Catch issues before they become incidents

**Pro tip**: If you're getting OOMKilled on startup, check your application's initialization phase. Loading large datasets or caches on startup is a common culprit.

Remember: **The goal isn't to eliminate restarts, it's to eliminate the root cause.**

