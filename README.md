# 🛒 Smart Grocery Manager

A full-stack grocery list management application with enterprise-grade deployment options, comprehensive monitoring, and automated CI/CD pipelines.

[![CI](https://img.shields.io/badge/CI-GitHub%20Actions-blue)](https://github.com)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-326CE5?logo=kubernetes)](https://kubernetes.io/)
[![Monitoring](https://img.shields.io/badge/Monitoring-Prometheus%20%2B%20Grafana-orange)](https://prometheus.io/)

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Quick Start](#-quick-start)
- [Deployment Options](#-deployment-options)
- [Monitoring](#-monitoring)
- [CI/CD](#-cicd)
- [Documentation](#-documentation)
- [Architecture](#-architecture)
- [Development](#-development)
- [Contributing](#-contributing)

---

## 🎯 Overview

Smart Grocery Manager is a modern web application that helps you manage your grocery shopping list efficiently. Built with React and Node.js, it features real-time updates, persistent storage with Redis, and can be deployed anywhere from local development to enterprise Kubernetes clusters on Google Cloud Platform.

**Live Demo:** Coming soon!

---

## ✨ Features

### Application Features
- ✅ Add, remove, and clear grocery items
- ✅ Filter items in real-time
- ✅ Persistent storage with Redis
- ✅ Responsive UI with modern design
- ✅ Error handling and validation
- ✅ Real-time metrics and monitoring

### DevOps Features
- 🐳 **Docker & Docker Compose** - Containerized deployment
- ☸️ **Kubernetes** - Production-ready orchestration
- 📊 **Prometheus & Grafana** - Comprehensive monitoring
- 🤖 **GitHub Actions** - Automated CI/CD pipelines
- ☁️ **GCP/GKE** - Cloud deployment with Terraform
- 📦 **Helm Charts** - Package management
- 🔄 **Auto-scaling** - Horizontal Pod Autoscaling (HPA)
- 🔍 **Health Checks** - Liveness and readiness probes

---

## 🛠️ Tech Stack

### Frontend
- **React 19.2.0** - UI library
- **Redux Toolkit 2.11.0** - State management
- **Vite 7.2.4** - Build tool & dev server
- **Axios 1.13.2** - HTTP client
- **Nginx** - Production web server

### Backend
- **Node.js 20** - Runtime
- **Express 5.1.0** - Web framework
- **Redis 7** - In-memory database
- **Prom-Client 15.1.0** - Prometheus metrics

### Infrastructure
- **Docker** - Containerization
- **Kubernetes** - Orchestration
- **Prometheus** - Metrics collection
- **Grafana** - Dashboards & visualization
- **Terraform** - Infrastructure as Code
- **Helm** - Package manager
- **GitHub Actions** - CI/CD automation

---

## 🚀 Quick Start

### Prerequisites
- Node.js 20+
- Docker & Docker Compose
- (Optional) Kubernetes cluster or Minikube
- (Optional) Terraform for cloud deployment

### Local Development

```bash
# Clone the repository
git clone https://github.com/yourusername/Smart-Grocery.git
cd Smart-Grocery

# Install dependencies
npm install
cd server && npm install && cd ..

# Start development servers
./run-dev.sh

# Or manually:
# Terminal 1 - Backend
cd server && npm start

# Terminal 2 - Frontend
npm run dev

# Access application at http://localhost:5173
```

### Docker Compose (Recommended)

```bash
# Development mode (ports: 8080, 5001, 6380)
docker-compose -f docker-compose.dev.yml up -d

# Production mode (ports: 80, 5000, 6379)
docker-compose up -d

# With monitoring stack
docker-compose -f docker-compose.monitoring.yml up -d

# Access:
# Application: http://localhost:8080
# Grafana: http://localhost:3000 (admin/admin123)
# Prometheus: http://localhost:9091
```

### Minikube

```bash
# Start Minikube
minikube start --driver=docker --kubernetes-version=v1.31.0

# Build images in Minikube
eval $(minikube docker-env)
docker build -t smart-grocery-server:latest -f server/Dockerfile server/
docker build -t smart-grocery-client:latest -f Dockerfile.client .

# Deploy application
kubectl create namespace smart-grocery
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

# Access services
minikube service client -n smart-grocery
minikube service grafana -n smart-grocery
```

---

## 📦 Deployment Options

### 1. Local Development
- **Best for:** Development and testing
- **Setup time:** 2 minutes
- **Guide:** Run `./run-dev.sh`

### 2. Docker Compose
- **Best for:** Local production testing
- **Setup time:** 5 minutes
- **Guide:** See [DOCKER.md](DOCKER.md) or [DOCKER-QUICK-START.md](DOCKER-QUICK-START.md)

### 3. Minikube
- **Best for:** Local Kubernetes testing
- **Setup time:** 10 minutes
- **Guide:** See [MINIKUBE.md](MINIKUBE.md)

### 4. Kubernetes
- **Best for:** Production on any K8s cluster
- **Setup time:** 15 minutes
- **Guide:** See [KUBERNETES.md](KUBERNETES.md) or [K8S-QUICK-START.md](K8S-QUICK-START.md)

### 5. Google Cloud Platform (GKE)
- **Best for:** Production cloud deployment
- **Setup time:** 30 minutes
- **Guide:** See [GCP-TERRAFORM.md](GCP-TERRAFORM.md)

**Comparison Table:**

| Option | Cost | Scalability | Monitoring | Auto-scaling | Best For |
|--------|------|-------------|------------|--------------|----------|
| Local Dev | Free | Low | Basic | No | Development |
| Docker Compose | Free | Low | Full | No | Testing |
| Minikube | Free | Medium | Full | Yes | K8s Learning |
| Kubernetes | Varies | High | Full | Yes | Production |
| GCP/GKE | $50-500/mo | Very High | Full | Yes | Enterprise |

---

## 📊 Monitoring

### Prometheus Metrics

**Application Metrics:**
- HTTP request rate and latency
- Active connections
- Grocery items count
- Redis operations rate and latency
- CPU and memory usage

**Access:** `http://localhost:9090` (port-forward) or `http://localhost:9091` (Docker)

### Grafana Dashboards

**Pre-configured dashboard with 12 panels:**
- Service health status
- Real-time item count
- HTTP request rates
- Response time percentiles (p50, p95, p99)
- CPU and memory usage
- Redis operations and latency

**Access:** 
- Docker: `http://localhost:3000`
- Kubernetes: `kubectl port-forward -n smart-grocery svc/grafana 3000:3000`
- Minikube: `minikube service grafana -n smart-grocery`

**Credentials:** `admin` / `admin123` (change in production!)

**Full Guide:** [MONITORING.md](MONITORING.md)

---

## 🤖 CI/CD

### GitHub Actions Workflows

**6 automated workflows:**

1. **CI - Build and Test** - Runs on every push/PR
   - Frontend/backend linting
   - Docker builds
   - Security scanning with Trivy

2. **CD - Deploy to GCP** - Auto-deploy to GKE
   - Build and push images to GCR
   - Deploy to Kubernetes
   - Smoke tests

3. **Terraform - Infrastructure** - IaC management
   - Validate and format
   - Plan on PRs
   - Apply on main branch

4. **Docker Compose Test** - Integration tests
   - Full stack testing
   - Health checks

5. **Dependency Updates** - Weekly automation
   - Check outdated packages
   - Create update issues

6. **Release Management** - Version tagging
   - Generate changelogs
   - Build release images

### Setup CI/CD

```bash
# Run setup script
./setup-github-actions.sh

# Or manually configure secrets:
# GCP_PROJECT_ID
# GCP_SERVICE_ACCOUNT
# GCP_WORKLOAD_IDENTITY_PROVIDER
```

**Full Guide:** [GITHUB-ACTIONS.md](GITHUB-ACTIONS.md)

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [DOCKER.md](DOCKER.md) | Complete Docker guide |
| [DOCKER-QUICK-START.md](DOCKER-QUICK-START.md) | Quick Docker reference |
| [KUBERNETES.md](KUBERNETES.md) | Comprehensive K8s guide |
| [K8S-QUICK-START.md](K8S-QUICK-START.md) | Quick K8s reference |
| [K8S-SUMMARY.md](K8S-SUMMARY.md) | K8s deployment summary |
| [MINIKUBE.md](MINIKUBE.md) | Minikube local deployment |
| [GCP-TERRAFORM.md](GCP-TERRAFORM.md) | GCP infrastructure guide |
| [MONITORING.md](MONITORING.md) | Prometheus & Grafana setup |
| [GITHUB-ACTIONS.md](GITHUB-ACTIONS.md) | CI/CD automation guide |
| [DEPLOYMENT-OPTIONS.md](DEPLOYMENT-OPTIONS.md) | Deployment comparison |

---

## 🏗️ Architecture

### System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Load Balancer / Ingress              │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
┌───────▼────────┐      ┌────────▼─────────┐
│  Client Pods   │      │   Server Pods    │
│  (React/Nginx) │◄────►│  (Node.js/       │
│  Replicas: 2-5 │      │   Express)       │
└────────────────┘      │  Replicas: 2-10  │
                        └────────┬─────────┘
                                 │
                        ┌────────▼─────────┐
                        │   Redis Pod      │
                        │   (Database)     │
                        │   Replicas: 1    │
                        └──────────────────┘

┌─────────────────────────────────────────────────────────┐
│              Monitoring & Observability                  │
├─────────────────────────────────────────────────────────┤
│  Prometheus  │  Grafana  │  Redis Exporter             │
└─────────────────────────────────────────────────────────┘
```

### Component Interactions

```
User Browser
    │
    ▼
Nginx (Client) ──► React App
    │
    ▼ /api/*
Express Server ──► Redis Database
    │
    ▼ /metrics
Prometheus ──► Grafana Dashboard
```

### Data Flow

1. User interacts with React frontend
2. Frontend sends API requests to Express backend
3. Backend validates and processes requests
4. Redis stores/retrieves data
5. Metrics collected by Prometheus
6. Grafana visualizes metrics

---

## 💻 Development

### Project Structure

```
Smart-Grocery/
├── src/                    # Frontend source
│   ├── components/         # React components
│   ├── store/             # Redux store
│   └── modules/           # Utility modules
├── server/                # Backend source
│   ├── index.js           # Express server
│   ├── metrics.js         # Prometheus metrics
│   └── redisClient.js     # Redis connection
├── k8s/                   # Kubernetes manifests
├── helm/                  # Helm charts
├── terraform/             # Infrastructure as Code
├── monitoring/            # Monitoring configs
├── .github/workflows/     # CI/CD pipelines
└── docs/                  # Documentation

```

### Available Scripts

**Frontend:**
```bash
npm run dev         # Development server
npm run build       # Production build
npm run preview     # Preview production build
npm run lint        # Lint code
```

**Backend:**
```bash
npm start           # Start server with nodemon
```

**Docker:**
```bash
./run-dev.sh                              # Local development
docker-compose up                         # Production mode
docker-compose -f docker-compose.dev.yml up  # Dev mode
```

**Kubernetes:**
```bash
./k8s-deploy.sh           # Deploy to K8s
./k8s-cleanup.sh          # Remove from K8s
./k8s-port-forward.sh     # Port forward services
./helm-deploy.sh          # Deploy with Helm
```

**Monitoring:**
```bash
./deploy-monitoring.sh    # Deploy monitoring stack
```

**GCP:**
```bash
./gcp-deploy.sh dev       # Deploy to GCP dev
./gcp-build-push.sh       # Build & push images
./gcp-destroy.sh dev      # Destroy infrastructure
```

### Adding New Features

1. **Frontend:** Add components in `src/components/`
2. **Backend:** Add routes in `server/index.js`
3. **State:** Update Redux store in `src/store/`
4. **Metrics:** Add custom metrics in `server/metrics.js`

### Environment Variables

**Backend:**
- `NODE_ENV` - Environment (development/production)
- `REDIS_URL` - Redis connection string
- `PORT` - Server port (default: 5000)

**Frontend:**
- `VITE_API_URL` - API endpoint (default: /api)

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** changes (`git commit -m 'Add AmazingFeature'`)
4. **Push** to branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow existing code style
- Add tests for new features
- Update documentation
- Ensure CI passes

---

## 📄 License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- React team for the amazing framework
- Kubernetes community for orchestration tools
- Prometheus & Grafana for monitoring solutions
- Docker for containerization
- All open-source contributors

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/yourusername/Smart-Grocery/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/Smart-Grocery/discussions)
- **Documentation:** See [docs folder](/)

---

## 🗺️ Roadmap

- [ ] User authentication
- [ ] Multiple shopping lists
- [ ] Item categories
- [ ] Shopping history
- [ ] Price tracking
- [ ] Mobile app
- [ ] Barcode scanning
- [ ] Recipe integration
- [ ] Shopping reminders

---

**Built with ❤️ using React, Node.js, Redis, and Kubernetes**

---

## 📊 Project Stats

![GitHub stars](https://img.shields.io/github/stars/yourusername/Smart-Grocery?style=social)
![GitHub forks](https://img.shields.io/github/forks/yourusername/Smart-Grocery?style=social)
![GitHub issues](https://img.shields.io/github/issues/yourusername/Smart-Grocery)
![GitHub pull requests](https://img.shields.io/github/issues-pr/yourusername/Smart-Grocery)

---

*Last updated: November 2025*
