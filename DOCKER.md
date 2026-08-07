# Smart Grocery Manager - Docker Setup

## 🐳 Docker Configuration

This project includes complete Docker containerization with:
- **Client**: React frontend served via Nginx
- **Server**: Node.js/Express API server
- **Redis**: Data persistence layer

## 📋 Prerequisites

- Docker (v20.10+)
- Docker Compose (v2.0+)

## 🚀 Quick Start

### Option 1: Production Mode (Recommended)

```bash
docker-compose up --build
```

This uses the default `docker-compose.yml` which:
- Does NOT expose Redis externally (avoids port conflicts)
- Uses standard ports: 80 (frontend), 5000 (backend)
- Redis only accessible within Docker network

**Access the Application:**
- **Frontend**: http://localhost
- **Backend API**: http://localhost:5000

### Option 2: Development Mode (With Port Mapping)

If you need to access Redis directly or have port conflicts:

```bash
docker-compose -f docker-compose.dev.yml up --build
```

This uses alternative ports:
- **Frontend**: http://localhost:8080
- **Backend API**: http://localhost:5001
- **Redis**: localhost:6380

### ⚠️ Port Conflict Issues

If you see `bind: address already in use` errors:

1. **Check what's using the ports:**
   ```bash
   lsof -i :6379  # Check Redis
   lsof -i :5000  # Check Server
   lsof -i :80    # Check Nginx
   ```

2. **Stop local services or use development mode:**
   ```bash
   # Either stop your local services
   # Or use the dev compose file with different ports
   docker-compose -f docker-compose.dev.yml up --build
   ```

## 🛠️ Docker Commands

### Start Services (Detached Mode)
```bash
docker-compose up -d
```

### Stop Services
```bash
docker-compose down
```

### Stop Services and Remove Volumes
```bash
docker-compose down -v
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f server
docker-compose logs -f client
docker-compose logs -f redis
```

### Rebuild Specific Service
```bash
docker-compose build server
docker-compose build client
```

### Restart a Service
```bash
docker-compose restart server
```

## 📁 Docker Files Structure

```
├── Dockerfile.client       # Multi-stage build for React frontend
├── Dockerfile.server       # Node.js backend container
├── docker-compose.yml      # Orchestrates all services
├── nginx.conf             # Nginx configuration for SPA
└── .dockerignore          # Files to exclude from Docker build
```

## 🔧 Architecture

### Services

1. **Redis**
   - Image: `redis:7-alpine`
   - Port: 6379
   - Persistent volume: `redis_data`
   - Health check enabled

2. **Server**
   - Built from `Dockerfile.server`
   - Port: 5000
   - Connects to Redis via internal network
   - Auto-restarts on failure

3. **Client**
   - Built from `Dockerfile.client` (multi-stage)
   - Port: 80
   - Nginx serves static files
   - Optimized production build

### Networking

All services communicate via `smart-grocery-network` bridge network, allowing service discovery by name (e.g., `redis:6379`).

## 🔄 Development vs Production

### Development (without Docker)
```bash
./run-dev.sh
```

### Production (with Docker)
```bash
docker-compose up -d
```

## 🐛 Troubleshooting

### Port Already in Use Error

**Error:** `bind: address already in use`

**Solution 1:** Use development mode with alternate ports
```bash
docker-compose -f docker-compose.dev.yml up --build
```

**Solution 2:** Stop conflicting services
```bash
# Find what's using the port
lsof -i :6379
lsof -i :5000
lsof -i :80

# Stop your local Redis/server if running
# Then use standard docker-compose
docker-compose up --build
```

### Check Service Status
```bash
docker-compose ps
```

### Inspect Container
```bash
docker exec -it smart-grocery-server sh
docker exec -it smart-grocery-redis redis-cli

# For dev mode
docker exec -it smart-grocery-redis-dev redis-cli
```

### Clear All Data and Restart
```bash
docker-compose down -v
docker-compose up --build
```

### View Resource Usage
```bash
docker stats
```

### Redis Connection Issues

If the server can't connect to Redis:
```bash
# Check Redis is running
docker-compose logs redis

# Test Redis connection from server container
docker exec -it smart-grocery-server sh
# Inside container: nc -zv redis 6379
```

## 🔐 Environment Variables

The server supports the following environment variables:

- `REDIS_URL`: Redis connection URL (default: `redis://redis:6379`)
- `NODE_ENV`: Environment mode (default: `production`)

## 📦 Volume Management

Redis data is persisted in a named volume `redis_data`. To backup:

```bash
docker run --rm -v smart-grocery_redis_data:/data -v $(pwd):/backup alpine tar czf /backup/redis-backup.tar.gz -C /data .
```

To restore:
```bash
docker run --rm -v smart-grocery_redis_data:/data -v $(pwd):/backup alpine tar xzf /backup/redis-backup.tar.gz -C /data
```

## 🏗️ Build Optimization

The client uses a multi-stage build:
1. **Build stage**: Compiles React app with Vite
2. **Production stage**: Serves static files with Nginx

This results in a smaller final image (~25MB vs ~200MB).

## 🚦 Health Checks

Redis includes a health check that ensures the server only starts when Redis is ready.

## 📝 Notes

- The client build is optimized for production with minification and tree-shaking
- Nginx is configured for SPA routing (all routes serve `index.html`)
- Static assets are cached for 1 year
- Redis data persists between container restarts
