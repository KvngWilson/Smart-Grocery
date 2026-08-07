# 🚀 Kubernetes Quick Start - Smart Grocery Manager

## One-Command Deployment

### Prerequisites
- Kubernetes cluster running (Minikube, Kind, Docker Desktop, or cloud)
- `kubectl` installed and configured
- `docker` installed

### Deploy with Kubectl

```bash
# 1. Build and deploy everything
./k8s-deploy.sh

# 2. Access the application
./k8s-port-forward.sh

# 3. Open in browser
# http://localhost:8080
```

### Deploy with Helm (Recommended)

```bash
# 1. Deploy
./helm-deploy.sh

# 2. Access
./k8s-port-forward.sh
```

---

## 📋 What Gets Deployed?

### Architecture
```
┌─────────────────────────────────────┐
│  Client Pods (2 replicas)           │
│  - React Frontend                   │
│  - Nginx Server                     │
│  - Auto-scales: 2-5 pods            │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Server Pods (2 replicas)           │
│  - Node.js/Express API              │
│  - Connects to Redis                │
│  - Auto-scales: 2-10 pods           │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Redis Pod (1 replica)              │
│  - Data persistence                 │
│  - 1Gi persistent volume            │
└─────────────────────────────────────┘
```

### Components
- ✅ **3 Deployments** (Client, Server, Redis)
- ✅ **3 Services** (LoadBalancer, ClusterIP, ClusterIP)
- ✅ **2 HorizontalPodAutoscalers** (Client, Server)
- ✅ **1 PersistentVolume** (Redis data)
- ✅ **1 ConfigMap** (Environment variables)
- ✅ **1 Namespace** (Isolated environment)

---

## 🎯 Common Tasks

### View Everything
```bash
kubectl get all -n smart-grocery
```

### Check Logs
```bash
# Server logs
kubectl logs -f -l app=server -n smart-grocery

# Client logs
kubectl logs -f -l app=client -n smart-grocery

# Redis logs
kubectl logs -f -l app=redis -n smart-grocery
```

### Scale Manually
```bash
# Scale server to 5 pods
kubectl scale deployment server --replicas=5 -n smart-grocery

# Scale client to 3 pods
kubectl scale deployment client --replicas=3 -n smart-grocery
```

### Watch Auto-Scaling
```bash
kubectl get hpa -n smart-grocery -w
```

### Execute Commands
```bash
# Access server pod
kubectl exec -it $(kubectl get pod -n smart-grocery -l app=server -o jsonpath='{.items[0].metadata.name}') -n smart-grocery -- sh

# Access Redis
kubectl exec -it $(kubectl get pod -n smart-grocery -l app=redis -o jsonpath='{.items[0].metadata.name}') -n smart-grocery -- redis-cli
```

---

## 🧹 Cleanup

### Remove Everything
```bash
# Option 1: Automated script
./k8s-cleanup.sh

# Option 2: Delete namespace
kubectl delete namespace smart-grocery

# Option 3: Helm uninstall
helm uninstall smart-grocery -n smart-grocery
kubectl delete namespace smart-grocery
```

---

## 🔧 Configuration

### Change Replicas
Edit `k8s/server-deployment.yaml` or `helm/smart-grocery/values.yaml`:
```yaml
spec:
  replicas: 3  # Change this number
```

### Change Resource Limits
Edit values in deployment files:
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Enable Ingress
1. Install Ingress Controller:
   ```bash
   minikube addons enable ingress  # For Minikube
   ```

2. Apply ingress:
   ```bash
   kubectl apply -f k8s/ingress.yaml
   ```

3. Add to `/etc/hosts`:
   ```
   <INGRESS-IP> smart-grocery.local
   ```

---

## 🐛 Troubleshooting

### Pods Not Starting?
```bash
kubectl describe pod <pod-name> -n smart-grocery
kubectl logs <pod-name> -n smart-grocery
```

### Can't Access App?
```bash
# Check if port-forward is running
ps aux | grep "port-forward"

# Restart port-forward
./k8s-port-forward.sh
```

### Images Not Found?
```bash
# For local clusters, load images
minikube image load smart-grocery-server:latest
minikube image load smart-grocery-client:latest

# Or for Kind
kind load docker-image smart-grocery-server:latest
kind load docker-image smart-grocery-client:latest
```

### Auto-scaling Not Working?
```bash
# Check if metrics-server is running
kubectl get deployment metrics-server -n kube-system

# Install metrics-server if missing
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# For Minikube
minikube addons enable metrics-server
```

---

## 📚 More Information

- Full Documentation: [KUBERNETES.md](./KUBERNETES.md)
- Docker Setup: [DOCKER.md](./DOCKER.md)
- Quick Reference: [DOCKER-QUICK-START.md](./DOCKER-QUICK-START.md)

---

## 🎉 That's It!

Your Smart Grocery Manager is now running on Kubernetes with:
- ✅ High availability (multiple replicas)
- ✅ Auto-scaling (based on load)
- ✅ Persistent storage (Redis data survives restarts)
- ✅ Health checks (automatic recovery)
- ✅ Production-ready configuration

Access at: **http://localhost:8080** (after port-forward)
