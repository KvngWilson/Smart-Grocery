# 🚀 Smart Grocery Manager - Deployment Options

## Choose Your Deployment Method

### 1️⃣ Local Development (Fastest)
**Best for:** Active development, quick testing

```bash
./run-dev.sh
```

**Access:**
- Frontend: http://localhost:5173
- Backend: http://localhost:5000
- Redis: localhost:6379

**Pros:**
- ✅ Instant hot-reload
- ✅ Easy debugging
- ✅ No containerization overhead

**Cons:**
- ❌ Requires local Node.js, npm, Redis
- ❌ Not production-like

---

### 2️⃣ Docker Compose (Easy)
**Best for:** Testing in containers, simple deployment

```bash
# Development mode (alternate ports)
docker-compose -f docker-compose.dev.yml up -d

# Production mode (standard ports)
docker-compose up -d
```

**Access:**
- Dev: http://localhost:8080
- Prod: http://localhost

**Pros:**
- ✅ Containerized environment
- ✅ Easy setup and teardown
- ✅ Production-like setup
- ✅ Built-in networking

**Cons:**
- ❌ Single-host only
- ❌ No auto-scaling
- ❌ Manual load balancing

**Documentation:** [DOCKER.md](./DOCKER.md) | [DOCKER-QUICK-START.md](./DOCKER-QUICK-START.md)

---

### 3️⃣ Kubernetes (Production-Ready)
**Best for:** Production deployments, high availability, auto-scaling

#### Option A: Kubectl (Direct)
```bash
./k8s-deploy.sh
./k8s-port-forward.sh
```

#### Option B: Helm (Recommended)
```bash
./helm-deploy.sh
./k8s-port-forward.sh
```

**Access:**
- http://localhost:8080 (via port-forward)
- Or LoadBalancer/Ingress IP

**Pros:**
- ✅ High availability (multiple replicas)
- ✅ Auto-scaling based on CPU/Memory
- ✅ Self-healing (automatic restarts)
- ✅ Rolling updates
- ✅ Persistent storage
- ✅ Resource management
- ✅ Production-ready

**Cons:**
- ❌ More complex setup
- ❌ Requires Kubernetes cluster
- ❌ Steeper learning curve

**Documentation:** [KUBERNETES.md](./KUBERNETES.md) | [K8S-QUICK-START.md](./K8S-QUICK-START.md)

---

## 📊 Comparison Table

| Feature | Local Dev | Docker Compose | Kubernetes |
|---------|-----------|----------------|------------|
| **Setup Time** | 1 min | 5 min | 10 min |
| **Hot Reload** | ✅ Yes | ❌ No | ❌ No |
| **Containerized** | ❌ No | ✅ Yes | ✅ Yes |
| **Auto-Scaling** | ❌ No | ❌ No | ✅ Yes |
| **High Availability** | ❌ No | ❌ No | ✅ Yes |
| **Load Balancing** | ❌ No | ❌ No | ✅ Yes |
| **Self-Healing** | ❌ No | ⚠️ Restart policy | ✅ Yes |
| **Resource Limits** | ❌ No | ⚠️ Manual | ✅ Yes |
| **Rolling Updates** | ❌ No | ❌ No | ✅ Yes |
| **Health Checks** | ❌ No | ⚠️ Basic | ✅ Advanced |
| **Persistent Storage** | ✅ Local | ⚠️ Volumes | ✅ PV/PVC |
| **Multi-Node** | ❌ No | ❌ No | ✅ Yes |
| **Production Ready** | ❌ No | ⚠️ Limited | ✅ Yes |

---

## 🎯 Recommended Workflow

### Development Phase
```bash
# Use local development for active coding
./run-dev.sh
```

### Testing Phase
```bash
# Use Docker Compose to test containerized app
docker-compose -f docker-compose.dev.yml up -d
```

### Production Phase
```bash
# Deploy to Kubernetes cluster
./k8s-deploy.sh
# or
./helm-deploy.sh
```

---

## 📝 Quick Command Reference

### Local Development
```bash
./run-dev.sh                    # Start dev servers
npm run dev                     # Client only
cd server && npm run start      # Server only
```

### Docker Compose
```bash
docker-compose up -d            # Start (production)
docker-compose -f docker-compose.dev.yml up -d  # Start (dev)
docker-compose ps               # Check status
docker-compose logs -f          # View logs
docker-compose down             # Stop
docker-compose down -v          # Stop and remove data
```

### Kubernetes
```bash
./k8s-deploy.sh                 # Deploy with kubectl
./helm-deploy.sh                # Deploy with Helm
./k8s-port-forward.sh           # Access locally
kubectl get all -n smart-grocery  # Check status
./k8s-cleanup.sh                # Remove everything
```

---

## 🔐 Environment-Specific Configuration

### Development
- Redis: localhost:6379
- Server: localhost:5000
- Client: localhost:5173
- Hot reload enabled
- Debug logging

### Docker Compose
- Redis: Internal network (redis:6379)
- Server: localhost:5001 (dev) or localhost:5000 (prod)
- Client: localhost:8080 (dev) or localhost:80 (prod)
- Production builds
- Nginx proxy

### Kubernetes
- Redis: Internal service (redis.smart-grocery.svc.cluster.local:6379)
- Server: Internal service (server.smart-grocery.svc.cluster.local:5000)
- Client: LoadBalancer or Ingress
- Multiple replicas
- Auto-scaling
- Health checks
- Resource limits

---

## 🛠️ Switching Between Environments

### From Local Dev to Docker
```bash
# Build Docker images
docker-compose build

# Run
docker-compose up -d
```

### From Docker to Kubernetes
```bash
# Ensure images are built
docker build -f Dockerfile.server -t smart-grocery-server:latest .
docker build -f Dockerfile.client -t smart-grocery-client:latest .

# Deploy to K8s
./k8s-deploy.sh
```

### From Kubernetes back to Local Dev
```bash
# Clean up K8s
./k8s-cleanup.sh

# Start local dev
./run-dev.sh
```

---

## 📚 Documentation Index

- **[README.md](./README.md)** - Project overview
- **[DOCKER.md](./DOCKER.md)** - Complete Docker guide
- **[DOCKER-QUICK-START.md](./DOCKER-QUICK-START.md)** - Docker quick reference
- **[KUBERNETES.md](./KUBERNETES.md)** - Complete Kubernetes guide
- **[K8S-QUICK-START.md](./K8S-QUICK-START.md)** - Kubernetes quick reference
- **[DEPLOYMENT-OPTIONS.md](./DEPLOYMENT-OPTIONS.md)** - This file

---

## 🎉 Need Help?

Choose based on your needs:
- **Learning/Development?** → Use Local Dev
- **Testing containers?** → Use Docker Compose
- **Production deployment?** → Use Kubernetes
- **Not sure?** → Start with Docker Compose, move to Kubernetes later

Happy deploying! 🚀
