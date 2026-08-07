# 🚢 Kubernetes Deployment Guide - Smart Grocery Manager

## 📋 Overview

This guide covers deploying the Smart Grocery Manager application to Kubernetes with:
- **3-tier architecture** (Client, Server, Redis)
- **High availability** with multiple replicas
- **Auto-scaling** based on CPU/memory usage
- **Persistent storage** for Redis data
- **Health checks** and readiness probes
- **Resource limits** and requests

## 📁 Kubernetes Files Structure

```
k8s/
├── namespace.yaml              # Isolated namespace for the app
├── configmap.yaml             # Application configuration
├── redis-pv.yaml              # Persistent storage for Redis
├── redis-deployment.yaml      # Redis StatefulSet
├── server-deployment.yaml     # Backend API deployment
├── client-deployment.yaml     # Frontend deployment
├── ingress.yaml               # Ingress rules (optional)
├── hpa.yaml                   # Horizontal Pod Autoscaler
└── kustomization.yaml         # Kustomize configuration
```

## 🚀 Quick Start

### Prerequisites

1. **Kubernetes Cluster** (one of):
   - Minikube (local)
   - Kind (local)
   - Docker Desktop with Kubernetes
   - Cloud provider (GKE, EKS, AKS)

2. **Required Tools**:
   ```bash
   kubectl --version    # Kubernetes CLI
   docker --version     # Docker for building images
   ```

### Deploy Everything

```bash
# Option 1: Automated deployment script
./k8s-deploy.sh

# Option 2: Manual deployment
kubectl apply -k k8s/
```

### Access the Application

**If using LoadBalancer:**
```bash
kubectl get svc client -n smart-grocery
# Access via the EXTERNAL-IP shown
```

**If using local cluster (Minikube/Kind):**
```bash
# Use port forwarding
./k8s-port-forward.sh

# Or manually:
kubectl port-forward -n smart-grocery svc/client 8080:80
kubectl port-forward -n smart-grocery svc/server 5000:5000
```

Then open: http://localhost:8080

## 🏗️ Architecture

### Components

```
┌─────────────────────────────────────────────┐
│           Ingress / LoadBalancer            │
│         (smart-grocery.local:80)            │
└──────────────────┬──────────────────────────┘
                   │
        ┌──────────┴───────────┐
        │                      │
┌───────▼────────┐   ┌────────▼────────┐
│  Client Pods   │   │  Server Pods    │
│  (2 replicas)  │   │  (2 replicas)   │
│  Nginx:Alpine  │   │  Node.js API    │
└────────────────┘   └────────┬────────┘
                              │
                     ┌────────▼────────┐
                     │   Redis Pod     │
                     │  (1 replica)    │
                     │  PersistentVol  │
                     └─────────────────┘
```

### Resource Allocation

| Component | Replicas | CPU Request | CPU Limit | Memory Request | Memory Limit |
|-----------|----------|-------------|-----------|----------------|--------------|
| Client    | 2-5      | 50m         | 100m      | 64Mi           | 128Mi        |
| Server    | 2-10     | 100m        | 500m      | 256Mi          | 512Mi        |
| Redis     | 1        | 100m        | 200m      | 128Mi          | 256Mi        |

## 📊 Management Commands

### View Status

```bash
# Check all pods
kubectl get pods -n smart-grocery

# Check services
kubectl get services -n smart-grocery

# Check deployments
kubectl get deployments -n smart-grocery

# Check HPA status
kubectl get hpa -n smart-grocery

# Watch pod status in real-time
kubectl get pods -n smart-grocery -w
```

### View Logs

```bash
# All server logs
kubectl logs -f -l app=server -n smart-grocery

# Specific pod logs
kubectl logs -f <pod-name> -n smart-grocery

# Previous container logs (if crashed)
kubectl logs --previous <pod-name> -n smart-grocery

# Multiple containers in a pod
kubectl logs <pod-name> -c <container-name> -n smart-grocery
```

### Scale Applications

```bash
# Manual scaling
kubectl scale deployment server --replicas=5 -n smart-grocery
kubectl scale deployment client --replicas=3 -n smart-grocery

# Check auto-scaling status
kubectl get hpa -n smart-grocery -w
```

### Execute Commands in Pods

```bash
# Shell into server pod
kubectl exec -it <server-pod-name> -n smart-grocery -- sh

# Shell into Redis pod
kubectl exec -it <redis-pod-name> -n smart-grocery -- sh

# Check Redis data
kubectl exec -it <redis-pod-name> -n smart-grocery -- redis-cli
> KEYS *
> GET grocery_items
```

### Update Deployments

```bash
# After rebuilding images
docker build -f Dockerfile.server -t smart-grocery-server:latest .
docker build -f Dockerfile.client -t smart-grocery-client:latest .

# Restart deployments
kubectl rollout restart deployment/server -n smart-grocery
kubectl rollout restart deployment/client -n smart-grocery

# Check rollout status
kubectl rollout status deployment/server -n smart-grocery
```

### Debug Issues

```bash
# Describe pod for events and status
kubectl describe pod <pod-name> -n smart-grocery

# Check events in namespace
kubectl get events -n smart-grocery --sort-by='.lastTimestamp'

# Check resource usage
kubectl top pods -n smart-grocery
kubectl top nodes
```

## 🔧 Configuration

### Environment Variables

Managed via ConfigMap (`k8s/configmap.yaml`):
- `REDIS_URL`: Redis connection string
- `NODE_ENV`: Environment mode
- `API_BASE_URL`: API endpoint base path

To update configuration:
```bash
kubectl edit configmap app-config -n smart-grocery
kubectl rollout restart deployment/server -n smart-grocery
```

### Persistent Storage

Redis data is stored in a PersistentVolume:
```bash
# Check PV and PVC status
kubectl get pv
kubectl get pvc -n smart-grocery

# Backup Redis data
kubectl exec <redis-pod> -n smart-grocery -- redis-cli SAVE
```

## 🔄 Horizontal Pod Autoscaling

The HPA automatically scales pods based on:
- **CPU utilization**: Target 70%
- **Memory utilization**: Target 80%

Server scaling: 2-10 replicas
Client scaling: 2-5 replicas

```bash
# Watch autoscaling in action
kubectl get hpa -n smart-grocery -w

# Generate load to test autoscaling
kubectl run -it --rm load-generator --image=busybox -n smart-grocery -- /bin/sh
# Inside the pod:
while true; do wget -q -O- http://server:5000/items; done
```

## 🌐 Ingress Configuration

### Prerequisites

Install Nginx Ingress Controller:
```bash
# For Minikube
minikube addons enable ingress

# For bare Kubernetes
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
```

### Access via Ingress

Add to `/etc/hosts`:
```
<INGRESS-IP> smart-grocery.local
```

Then access: http://smart-grocery.local

## 🛡️ Health Checks

### Liveness Probes
- Detect crashed or hung containers
- Restart unhealthy pods automatically

### Readiness Probes
- Determine when pod is ready to receive traffic
- Remove from service load balancer if not ready

### Current Configuration

**Redis:**
- Liveness: `redis-cli ping` every 10s
- Readiness: `redis-cli ping` every 5s

**Server:**
- Liveness: HTTP GET `/items` every 10s
- Readiness: HTTP GET `/items` every 5s

**Client:**
- Liveness: HTTP GET `/` every 10s
- Readiness: HTTP GET `/` every 5s

## 🧹 Cleanup

```bash
# Option 1: Automated cleanup script
./k8s-cleanup.sh

# Option 2: Manual cleanup
kubectl delete namespace smart-grocery

# Option 3: Delete specific resources
kubectl delete -k k8s/
```

## 🔐 Production Considerations

### Security

1. **Use Secrets for sensitive data:**
   ```bash
   kubectl create secret generic redis-password \
     --from-literal=password=<your-password> \
     -n smart-grocery
   ```

2. **Network Policies:**
   - Restrict pod-to-pod communication
   - Only allow necessary traffic

3. **RBAC:**
   - Create service accounts with minimal permissions
   - Use Role and RoleBinding

### Monitoring

1. **Install Prometheus + Grafana:**
   ```bash
   helm install prometheus prometheus-community/kube-prometheus-stack
   ```

2. **Add ServiceMonitor for metrics collection**

3. **Set up alerts for:**
   - Pod restarts
   - High CPU/Memory usage
   - Failed deployments

### Backup Strategy

```bash
# Backup Redis data
kubectl exec <redis-pod> -n smart-grocery -- redis-cli BGSAVE

# Copy data from pod
kubectl cp smart-grocery/<redis-pod>:/data/dump.rdb ./backup/dump.rdb

# Restore Redis data
kubectl cp ./backup/dump.rdb smart-grocery/<redis-pod>:/data/dump.rdb
kubectl exec <redis-pod> -n smart-grocery -- redis-cli SHUTDOWN
```

## 📚 Additional Resources

### Local Development

For Minikube:
```bash
# Start cluster
minikube start --cpus=4 --memory=8192

# Enable addons
minikube addons enable metrics-server
minikube addons enable ingress

# Deploy
./k8s-deploy.sh

# Get service URL
minikube service client -n smart-grocery
```

For Kind:
```bash
# Create cluster
kind create cluster --name smart-grocery

# Deploy
./k8s-deploy.sh

# Port forward to access
./k8s-port-forward.sh
```

### Useful Commands Reference

```bash
# Get all resources
kubectl get all -n smart-grocery

# Get detailed info
kubectl describe deployment server -n smart-grocery

# Edit live resource
kubectl edit deployment server -n smart-grocery

# View API resources
kubectl api-resources

# Explain resource fields
kubectl explain deployment.spec.template.spec

# Port forward
kubectl port-forward svc/client 8080:80 -n smart-grocery

# Copy files to/from pod
kubectl cp <file> smart-grocery/<pod>:/path
kubectl cp smart-grocery/<pod>:/path <local-file>

# Execute command
kubectl exec <pod> -n smart-grocery -- <command>
```

## 🎯 Next Steps

1. **Set up CI/CD pipeline** (Jenkins, GitLab CI, GitHub Actions)
2. **Implement GitOps** with ArgoCD or Flux
3. **Add monitoring and logging** (Prometheus, Grafana, ELK Stack)
4. **Configure SSL/TLS** with cert-manager
5. **Implement service mesh** (Istio, Linkerd) for advanced traffic management
6. **Set up disaster recovery** and backup automation

---

## 📞 Troubleshooting

### Pods not starting?
```bash
kubectl describe pod <pod-name> -n smart-grocery
kubectl logs <pod-name> -n smart-grocery
```

### Can't connect to services?
```bash
kubectl get endpoints -n smart-grocery
kubectl exec -it <pod> -n smart-grocery -- nc -zv <service> <port>
```

### Images not pulling?
```bash
# For local clusters, load images manually
minikube image load smart-grocery-server:latest
kind load docker-image smart-grocery-server:latest
```

### HPA not working?
```bash
# Ensure metrics-server is installed
kubectl get apiservice v1beta1.metrics.k8s.io -o yaml
kubectl top pods -n smart-grocery
```
