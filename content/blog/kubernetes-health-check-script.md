---
title: "Building a Production-Ready Kubernetes Health Check Script"
date: 2024-10-20
description: "How I built an automated K8s cluster monitoring script with health scoring, email alerts, and production patterns - all in Bash."
tags: ["kubernetes", "monitoring", "bash", "devops", "automation"]
---

"Can you write a script to monitor our K8s cluster health and send email alerts if something breaks?"

This was my task as a DevOps intern. Simple request, but I learned a lot about production monitoring patterns.

## The Requirements

1. **Check cluster health** - nodes, pods, services
2. **Monitor resource usage** - CPU, memory across nodes  
3. **Score the health** - 0-100 points system
4. **Email alerts** - When score drops below threshold
5. **No external dependencies** - Just bash and kubectl
6. **Production-ready** - Run via cron every 30 minutes

## The Architecture

```
┌─────────────┐
│   Cron Job  │
│  (*/30 * *) │
└──────┬──────┘
       │
       v
┌─────────────────────────────────────────┐
│  Health Check Script (latest.sh)        │
│                                         │
│  1. Check K8s Cluster Status           │
│  2. Check Resource Utilization         │
│  3. Check Platform Services            │
│  4. Check Network/DNS                  │
│  5. Calculate Health Score (0-100)     │
│  6. Send Email if Score < 70           │
└─────────────────────────────────────────┘
       │
       v
┌─────────────┐
│   msmtp     │ → Email to DevOps team
└─────────────┘
```

## The Implementation

### Part 1: Cluster Status Check

```bash
#!/bin/bash

check_cluster_status() {
  echo "=== KUBERNETES CLUSTER STATUS ==="
  
  # Check if all nodes are Ready
  NOT_READY_NODES=$(kubectl get nodes --no-headers | grep -v "Ready" | wc -l)
  
  if [ "$NOT_READY_NODES" -gt 0 ]; then
    echo "CRITICAL: $NOT_READY_NODES nodes not ready"
    HEALTH_SCORE=$((HEALTH_SCORE - 40))
  else
    echo "OK: All cluster nodes ready"
  fi
  
  # Check for failed pods
  FAILED_PODS=$(kubectl get pods -A --no-headers | \
    grep -E "Error|CrashLoopBackOff|ImagePullBackOff|OOMKilled" | wc -l)
  
  if [ "$FAILED_PODS" -gt 0 ]; then
    echo "CRITICAL: $FAILED_PODS pods in failed state"
    HEALTH_SCORE=$((HEALTH_SCORE - 30))
    
    # List the failed pods
    kubectl get pods -A | grep -E "Error|CrashLoop|ImagePull|OOMKilled"
  else
    echo "OK: No pods in failed state"
  fi
}
```

### Part 2: Resource Utilization

```bash
check_resource_utilization() {
  echo "=== CLUSTER RESOURCE UTILIZATION ==="
  
  # Check memory usage per node
  kubectl top nodes --no-headers | while read node cpu mem; do
    # Extract percentage from memory (e.g., "65%" → 65)
    mem_percent=$(echo $mem | sed 's/%//')
    
    if [ "$mem_percent" -gt 85 ]; then
      echo "CRITICAL: Node $node memory at $mem_percent%"
      HEALTH_SCORE=$((HEALTH_SCORE - 25))
    elif [ "$mem_percent" -gt 70 ]; then
      echo "WARNING: Node $node memory at $mem_percent%"
      HEALTH_SCORE=$((HEALTH_SCORE - 10))
    fi
  done
}
```

### Part 3: Platform Services

```bash
check_platform_services() {
  echo "=== PLATFORM SERVICES STATUS ==="
  
  # Check critical services
  SERVICES=("containerd" "kubelet")
  
  for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet $service; then
      echo "OK: $service service running"
    else
      echo "CRITICAL: $service service not running"
      HEALTH_SCORE=$((HEALTH_SCORE - 20))
    fi
  done
}
```

### Part 4: Health Scoring System

```bash
# Start with perfect score
HEALTH_SCORE=100

# Run all checks (they deduct points)
check_cluster_status
check_resource_utilization  
check_platform_services
check_network_connectivity
check_infrastructure_status

# Determine overall health
if [ "$HEALTH_SCORE" -ge 90 ]; then
  HEALTH_STATUS="HEALTHY"
  STATUS_COLOR="GREEN"
elif [ "$HEALTH_SCORE" -ge 70 ]; then
  HEALTH_STATUS="WARNING"  
  STATUS_COLOR="YELLOW"
else
  HEALTH_STATUS="CRITICAL"
  STATUS_COLOR="RED"
fi

echo "PLATFORM STATUS: $HEALTH_STATUS ($HEALTH_SCORE/100)"
```

### Part 5: Email Alerts

```bash
send_alert() {
  local subject=$1
  local body=$2
  
  # Only send if score is below threshold
  if [ "$HEALTH_SCORE" -lt 70 ]; then
    echo "$body" | msmtp \
      --from="no-reply.nsuno@solytics-partners.com" \
      --subject="$subject" \
      devops-team@solytics-partners.com
  fi
}

# Generate alert
ALERT_SUBJECT="[${HEALTH_STATUS}] Platform Health Alert (Score: ${HEALTH_SCORE}/100)"
ALERT_BODY=$(cat <<EOF
CLUSTER & PLATFORM HEALTH CHECK - $(date +%Y-%m-%d_%H-%M-%S)
Cluster Node: $(hostname)
Scope: ${NAMESPACE}
===============================================

$(cat /tmp/health_check_results.txt)

PLATFORM STATUS: ${HEALTH_STATUS} (${HEALTH_SCORE}/100)
EOF
)

send_alert "$ALERT_SUBJECT" "$ALERT_BODY"
```

## The Full Script

The complete script checks:

✅ Node readiness  
✅ Pod health (Running, Failed, Pending states)  
✅ Resource utilization (CPU, memory per node)  
✅ Platform services (containerd, kubelet)  
✅ Network connectivity (DNS, API server)  
✅ Disk space (/ and /var/lib/kubelet)  
✅ Critical directories accessibility  

## Real Production Alert Example

Here's an actual email I received:

```
Subject: [CRITICAL] Platform Health Alert - production (Score: 65/100)

CLUSTER & PLATFORM HEALTH CHECK - 2025-01-14_15-30-45
Cluster Node: aks-worker-node-1
Scope: Namespace: production
===============================================

=== KUBERNETES CLUSTER STATUS ===
OK: All cluster nodes ready
CRITICAL: 3 pods in failed state (Namespace: production)

Failed Pods:
NAMESPACE    NAME                          STATUS             
production   backend-django-7d8f9c-xyz     CrashLoopBackOff
production   worker-celery-6f8d9-abc       OOMKilled
production   redis-sentinel-8g7h-def       Error

=== CLUSTER RESOURCE UTILIZATION ===
WARNING: Node aks-worker-2 memory usage is 78%

=== PLATFORM SERVICES STATUS ===
OK: containerd service running
OK: kubelet service running

=== PLATFORM HEALTH ASSESSMENT ===
PLATFORM STATUS: CRITICAL (65/100)
Platform requires immediate intervention
```

This alert woke me up (literally - it was set to my phone), and I fixed the CrashLoopBackOff within 20 minutes.

## Automation with Cron

```bash
# Edit crontab
crontab -e

# Add monitoring schedule
*/30 * * * * /opt/scripts/latest.sh production >> /var/log/k8s-health.log 2>&1
```

Every 30 minutes, the script:
1. Checks cluster health
2. Calculates score
3. Sends email if score < 70
4. Logs results

## Advanced Features I Added

### 1. Namespace-Specific Monitoring

```bash
#!/bin/bash
NAMESPACE="${1:-all}"  # Default to "all" if not provided

if [ "$NAMESPACE" = "all" ]; then
  PODS=$(kubectl get pods -A)
else
  PODS=$(kubectl get pods -n "$NAMESPACE")
fi
```

Usage:
```bash
./latest.sh production  # Only production namespace
./latest.sh             # All namespaces
```

### 2. Historical Tracking

```bash
# Save results with timestamp
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
RESULTS_FILE="/tmp/health_check_${TIMESTAMP}.txt"

# Keep last 7 days only
find /tmp -name "health_check_*.txt" -mtime +7 -delete
```

### 3. Detailed Pod Analysis

```bash
# For each failed pod, get recent events
kubectl describe pod $POD_NAME -n $NAMESPACE | tail -20
```

### 4. Slack Integration (Bonus)

```bash
# Send to Slack webhook
send_slack_alert() {
  curl -X POST https://hooks.slack.com/services/YOUR/WEBHOOK/URL \
    -H 'Content-Type: application/json' \
    -d "{
      \"text\": \"🚨 K8s Health Alert\",
      \"attachments\": [{
        \"color\": \"danger\",
        \"text\": \"Health Score: ${HEALTH_SCORE}/100\"
      }]
    }"
}
```

## Lessons Learned

### 1. Start Simple, Iterate

Version 1: Just checked if nodes were ready  
Version 2: Added pod status checks  
Version 3: Added resource monitoring  
Version 4: Added health scoring  
Version 5: Added email alerts  

Each version added value. I didn't try to build everything at once.

### 2. Health Scores Are Subjective

I weighted penalties based on business impact:
- Node failure: -40 points (catastrophic)
- Pod failure: -30 points (major)
- High memory: -25 points (warning)

Your priorities might differ. Adjust the weights.

### 3. Alert Fatigue Is Real

Don't alert on every minor issue. We set threshold at 70/100 to reduce noise.

Too many alerts = team ignores them.

### 4. Bash Is Powerful

You don't always need Python/Go. For simple monitoring scripts, bash + kubectl is perfect:
- No dependencies
- Easy to modify
- Runs everywhere
- Team can read it

## The Tools I Used

### kubectl
```bash
kubectl get pods -A --no-headers
kubectl top nodes
kubectl describe pod <name>
```

### msmtp (Lightweight Email)
```bash
# Install
apt-get install msmtp msmtp-mta

# Configure ~/.msmtprc
account default
host smtp.office365.com
port 587
from no-reply@company.com
auth on
user your-email@company.com
password your-password
tls on
```

### systemctl
```bash
systemctl is-active kubelet
systemctl status containerd
```

## Running in Production

The script runs on all our K8s nodes:

```bash
# On each node
/opt/scripts/latest.sh production
```

It catches issues before they become incidents:
- Disk space filling up
- Memory pressure before OOMKills
- Failed pods before services degrade
- DNS issues before total outage

## The Impact

After deploying this script:

- **Faster incident response**: Alerts often arrive before users notice
- **Better visibility**: Weekly health reports showed trends
- **Reduced downtime**: Caught 3 potential outages in first month
- **Team confidence**: Engineers trusted the monitoring

## Improvements I'd Make

If I started over:

1. ✅ Add Prometheus integration for historical data
2. ✅ Graph health scores over time
3. ✅ Predict failures with trend analysis
4. ✅ Auto-remediation for common issues
5. ✅ Mobile-friendly alert format

But honestly? **The simple version works great.**

## Conclusion

You don't need enterprise monitoring tools for effective cluster monitoring. A well-written bash script with:

- Clear checks
- Sensible scoring
- Timely alerts
- Easy maintenance

...can catch 90% of issues before they become critical.

**Pro tip**: When writing monitoring scripts, optimize for readability over cleverness. Future you (at 3am during an incident) will thank you.

The full script is ~300 lines. Small enough to understand, comprehensive enough to be useful.

**Sometimes the best tools are the ones you build yourself.**

