-# 🎯 Minikube Quick Start Guide

## ✅ Current Status

Your Smart Grocery Manager is **successfully deployed** on Minikube with:

- ✅ **Kubernetes v1.31.0** cluster running
- ✅ **2 Client pods** (Frontend - React + Nginx)
- ✅ **2 Server pods** (Backend - Node.js + Express)
- ✅ **1 Redis pod** (Database)
- ✅ **1 Prometheus pod** (Metrics collection)
- ✅ **1 Grafana pod** (Monitoring dashboards)
- ✅ **1 Redis Exporter pod** (Redis metrics)

---

## 🚀 Access Your Application

### Method 1: Using Minikube Service

```bash
# Access application
minikube service client -n smart-grocery

# Access Grafana
minikube service grafana -n smart-grocery
```

### Method 2: Using the Access Script

```bash
./minikube-access.sh
```

### Method 3: Get URLs Manually

```bash
# Application URL
minikube service client -n smart-grocery --url

# Grafana URL
minikube service grafana -n smart-grocery --url
```

---

## 📊 Monitoring Dashboards

### Grafana

**Access:** Run `minikube service grafana -n smart-grocery`

**Credentials:**
- Username: `admin`
- Password: `admin123`

**Features:**
- Pre-configured Smart Grocery dashboard
- Real-time metrics visualization
- 12 monitoring panels
- CPU, memory, request rates, latency

### Prometheus

**Access:**
```bash
kubectl port-forward -n smart-grocery svc/prometheus 9090:9090
```
Then visit: http://localhost:9090

---

## 🔍 Troubleshooting

### Issue: Minikube API Server Failed to Start

**Solution Applied:**
```bash
# Deleted corrupt cluster
minikube delete

# Started fresh with stable Kubernetes version
minikube start --driver=docker --kubernetes-version=v1.31.0
```

### Check Pod Status

```bash
kubectl get pods -n smart-grocery
```

### View Pod Logs

```bash
# Server logs
kubectl logs -n smart-grocery -l app=server -f

# Client logs
kubectl logs -n smart-grocery -l app=client -f

# Redis logs
kubectl logs -n smart-grocery -l app=redis -f
```

### Describe Pod for Errors

```bash
kubectl describe pod -n smart-grocery <pod-name>
```

### Restart Deployment

```bash
kubectl rollout restart deployment/server -n smart-grocery
kubectl rollout restart deployment/client -n smart-grocery
```

---

## 📦 Common Operations

### Scale Application

```bash
# Scale server to 3 replicas
kubectl scale deployment/server --replicas=3 -n smart-grocery

# Scale client to 3 replicas
kubectl scale deployment/client --replicas=3 -n smart-grocery
```

### Update Application

```bash
# Build new images in Minikube's Docker
eval $(minikube docker-env)
docker build -t smart-grocery-server:latest -f server/Dockerfile server/
docker build -t smart-grocery-client:latest -f Dockerfile.client .

# Restart deployments to use new images
kubectl rollout restart deployment/server -n smart-grocery
kubectl rollout restart deployment/client -n smart-grocery
```

### View Metrics

```bash
# Application metrics
kubectl port-forward -n smart-grocery svc/server 5000:5000
curl http://localhost:5000/metrics

# Redis metrics
kubectl port-forward -n smart-grocery svc/redis-exporter 9121:9121
curl http://localhost:9121/metrics
```

---

## 🛑 Stop and Cleanup

### Stop Minikube (Preserve Data)

```bash
minikube stop
```

### Delete Namespace Only

```bash
kubectl delete namespace smart-grocery
```

### Delete Entire Cluster

```bash
minikube delete
```

---

## 🔄 Restart Everything

```bash
# Start Minikube
minikube start

# Deploy application
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/redis-pv.yaml
kubectl apply -f k8s/redis-deployment.yaml
kubectl apply -f k8s/server-deployment.yaml
kubectl apply -f k8s/client-deployment.yaml

# Deploy monitoring
kubectl apply -f k8s/prometheus-config.yaml
kubectl apply -f k8s/prometheus-deployment.yaml
kubectl apply -f k8s/grafana-config.yaml
kubectl apply -f k8s/grafana-deployment.yaml
kubectl apply -f k8s/redis-exporter.yaml
```

---

## 📝 Useful Commands

### Minikube Commands

```bash
# Status
minikube status

# Dashboard
minikube dashboard

# SSH into node
minikube ssh

# View IP
minikube ip

# List addons
minikube addons list

# Enable addon
minikube addons enable metrics-server
```

### Kubectl Commands

```bash
# Get all resources
kubectl get all -n smart-grocery

# Get pods with details
kubectl get pods -n smart-grocery -o wide

# Get services
kubectl get svc -n smart-grocery

# Get persistent volumes
kubectl get pv,pvc -n smart-grocery

# Watch resources
kubectl get pods -n smart-grocery -w

# Execute command in pod
kubectl exec -it -n smart-grocery deployment/server -- sh

# Copy file from pod
kubectl cp smart-grocery/server-pod:/app/file.txt ./file.txt
```

---

## 🎓 Next Steps

1. **Test the application** - Add and remove grocery items
2. **View Grafana dashboards** - Monitor metrics in real-time
3. **Try scaling** - Scale up/down server pods
4. **Deploy to production** - Use GCP/GKE deployment scripts
5. **Set up CI/CD** - Use GitHub Actions workflows
6. **Add more features** - Extend the application

---

## 📚 Related Documentation

- `KUBERNETES.md` - Full Kubernetes deployment guide
- `MONITORING.md` - Prometheus & Grafana documentation
- `DOCKER.md` - Docker containerization guide
- `GCP-TERRAFORM.md` - GCP infrastructure guide
- `GITHUB-ACTIONS.md` - CI/CD automation guide

---

Your application is ready to use on Minikube! 🎉
