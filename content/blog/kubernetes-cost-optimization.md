---
title: "Kubernetes Cost Optimization: How I Saved 81% CPU and 68% Memory"
date: 2024-11-15
description: "A data-driven approach to analyzing Kubernetes resource usage and identifying $10K+ in annual cloud cost savings by right-sizing workloads."
tags: ["kubernetes", "cost-optimization", "devops", "cloud"]
---

During my time at Solytics Partners, I was asked to analyze our Kubernetes cluster resource usage. The CFO wanted to know: **"Are we wasting money on over-provisioned infrastructure?"**

Spoiler: We were. By a lot.

## The Investigation

I was given access to our pre-production cluster and asked to conduct a comprehensive resource utilization analysis. The goal: identify optimization opportunities without risking service stability.

### The Methodology

I wrote a script to collect resource metrics across all namespaces:

```bash
# For each pod in the cluster
for pod in $(kubectl get pods -A -o name); do
  # Get resource requests/limits
  kubectl get $pod -o jsonpath='{.spec.containers[*].resources}'
  
  # Get actual usage from metrics-server
  kubectl top pod $pod
done
```

The data went into CSV files for analysis. After 2 weeks of collection, the results were shocking.

## The Findings

### Frontend Services: 0% Utilization 🔴

| Service | Allocated CPU | Used CPU | Allocated Memory | Used Memory | Efficiency |
|---------|---------------|----------|------------------|-------------|------------|
| frontend | 3 cores | 0.002 cores | 6 GiB | 8 MiB | **0%** |
| admin-panel-frontend | 3 cores | 0.003 cores | 6 GiB | 12 MiB | **0%** |

**Total waste**: 6 CPU cores, 12 GiB memory doing almost nothing.

These were static file servers. They didn't need enterprise-grade resources.

### JupyterHub: 98% Over-Provisioned 🔴

| Service | Allocated | Used | Efficiency |
|---------|-----------|------|------------|
| jupyterhub-jupyter | 7 cores, 13 GiB | 0.1 cores, 256 MiB | **2%** |

The JupyterHub service was allocated like it would handle 100 concurrent users. Actual usage? 2-3 users per day.

### RabbitMQ: 140% CPU Usage 🚨

While most services were over-provisioned, I found the opposite problem:

| Service | Allocated | Used | Status |
|---------|-----------|------|--------|
| rabbitmq-1 | 0.25 cores | **0.35 cores** | Throttled |
| rabbitmq-0 | 0.25 cores | **0.35 cores** | Throttled |

RabbitMQ was CPU-starved, causing message queue delays.

### ELK Stack: 95% Waste

| Service | Allocated CPU | Used CPU | Waste |
|---------|---------------|----------|-------|
| elasticsearch | 6 cores | 0.2 cores | 96% |
| logstash | 4 cores | 0.1 cores | 97% |
| kibana | 4 cores | 0.05 cores | 98% |

**14 CPU cores and 30 GiB memory** for a logging stack serving a small team.

## The Recommendations

### High Impact: Frontend Services

```yaml
# Before
resources:
  requests:
    cpu: 3
    memory: 6Gi
  limits:
    cpu: 3
    memory: 6Gi

# After
resources:
  requests:
    cpu: 100m  # 0.1 cores
    memory: 256Mi
  limits:
    cpu: 200m
    memory: 512Mi
```

**Savings**: 5.8 CPU cores, 11.5 GiB memory per service

### Critical Fix: RabbitMQ (Under-provisioned)

```yaml
# Before (CPU throttled!)
resources:
  requests:
    cpu: 250m
    memory: 512Mi

# After
resources:
  requests:
    cpu: 400m
    memory: 512Mi
```

This fixed message processing delays.

### Total Cluster Savings

| Resource | Allocated | Actually Needed | Waste | Savings |
|----------|-----------|-----------------|-------|---------|
| **CPU** | 73.6 cores | 13.9 cores | 59.7 cores | **81%** |
| **Memory** | 201.25 GiB | 63.65 GiB | 137.6 GiB | **68%** |

## The Implementation Strategy

I didn't change everything at once. That's a recipe for disaster.

### Phase 1: Quick Wins (Week 1)
✅ Increase RabbitMQ CPU (critical)  
✅ Reduce frontend services by 90%  
✅ Reduce nginx/pgbouncer (infrastructure)

### Phase 2: Low-Risk (Week 2-3)
✅ Reduce JupyterHub services by 85%  
✅ Optimize ELK stack

### Phase 3: Careful (Week 4)
✅ Right-size backend Django services  
✅ Monitor and adjust

### Phase 4: Monitor (Ongoing)
✅ Set up Prometheus alerts at 80% of new limits  
✅ Weekly resource usage reviews

## Tools I Used

### 1. kubectl top
```bash
# Real-time resource usage
kubectl top pods -n production --sort-by=memory
kubectl top nodes
```

### 2. Prometheus Queries
```promql
# CPU usage over time
rate(container_cpu_usage_seconds_total[5m])

# Memory usage
container_memory_working_set_bytes
```

### 3. Metrics Server
```bash
# Ensure metrics-server is installed
kubectl get deployment metrics-server -n kube-system
```

### 4. Excel/CSV Analysis
Exported data to CSV, created pivot tables, identified patterns.

## Real-World Impact

### Cost Savings
- **Cluster size reduction**: 20 nodes → 12 nodes
- **Annual savings**: ~$12,000/year
- **Image pull time**: Faster with smaller resource contention

### Performance Improvements
- **RabbitMQ throughput**: +40% (after CPU increase)
- **No service degradation**: All SLAs maintained
- **Faster deployments**: Less resource scheduling time

### Operational Benefits
- **Better monitoring**: Set proper alert thresholds
- **Faster autoscaling**: HPA works better with accurate baselines
- **Improved planning**: Data-driven capacity planning

## Lessons Learned

### 1. Most Services Are Over-Provisioned

Default to **measuring first**, not guessing. Engineers typically over-allocate "to be safe."

### 2. Static Content Needs Minimal Resources

If it's just serving files (frontend, nginx), start with:
- CPU: 100m
- Memory: 128Mi

Scale up if needed.

### 3. Some Services Need MORE Resources

Don't assume everything is over-provisioned. Always check actual usage.

### 4. Gradual Rollout Is Key

Never change production resources all at once. Do it in phases with monitoring.

### 5. Document Everything

I created a spreadsheet showing:
- Current allocation
- Actual usage (P50, P95, P99)
- Recommendation
- Justification
- Risk level

This made stakeholder buy-in easy.

## The Process I Follow Now

```
1. Collect data (2 weeks minimum)
   ↓
2. Analyze usage patterns (identify outliers)
   ↓
3. Calculate recommendations (with buffer)
   ↓
4. Get stakeholder approval
   ↓
5. Implement in phases
   ↓
6. Monitor closely (alert if >80% of new limits)
   ↓
7. Document results
```

## Red Flags to Watch For

❌ **Service using 0-5% of resources** → Massively over-provisioned  
❌ **Service using 90-100%** → Under-provisioned, needs more  
❌ **Wide variance** → Unpredictable, needs investigation  
✅ **Service using 40-70%** → Well-sized  

## Conclusion

Cloud cost optimization isn't about starving services of resources. It's about:

1. **Measuring actual usage**
2. **Right-sizing allocations**
3. **Monitoring continuously**
4. **Adjusting based on data**

Our cluster went from wasteful to efficient, and services ran **better** (RabbitMQ throughput improved 40%).

**The best part?** No service outages, no performance degradation, just a leaner, faster infrastructure.

**Key takeaway**: If you haven't analyzed your K8s resource usage in the last 6 months, you're probably wasting money.

