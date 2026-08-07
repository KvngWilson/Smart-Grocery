# 🚀 Docker Quick Start - Smart Grocery Manager

## ✅ Current Status: RUNNING & FIXED

Your application is currently running in Docker with the following configuration:

### 🌐 Access URLs:
- **Frontend**: http://localhost:8080 (with API proxy configured)
- **Direct Backend API**: http://localhost:5001  
- **Redis**: localhost:6380

**Note:** The frontend automatically proxies API requests through `/api/*` to the backend server, so no CORS issues!

### 📦 Running Containers:
```
smart-grocery-client-dev   → Port 8080 (Frontend)
smart-grocery-server-dev   → Port 5001 (API Server)
smart-grocery-redis-dev    → Port 6380 (Database)
```

---

## 🎯 Common Commands

### View Status
```bash
docker-compose -f docker-compose.dev.yml ps
```

### View Logs
```bash
# All services
docker-compose -f docker-compose.dev.yml logs -f

# Specific service
docker-compose -f docker-compose.dev.yml logs -f server
```

### Stop All Services
```bash
docker-compose -f docker-compose.dev.yml down
```

### Restart Services
```bash
docker-compose -f docker-compose.dev.yml restart
```

### Stop and Remove Everything (Including Data)
```bash
docker-compose -f docker-compose.dev.yml down -v
```

---

## 🔄 Why Development Mode?

You're using `docker-compose.dev.yml` because:
- **Port 6379** (Redis) was already in use by your local Redis
- **Port 5000** (Server) was already in use by your local Node server  
- **Port 80** (Nginx) was already in use by another service

The dev configuration uses alternate ports to avoid conflicts.

---

## 🔁 Switch to Production Mode

If you want to use standard ports (80, 5000):

1. **Stop all local services:**
   ```bash
   # Check what's using the ports
   lsof -i :80
   lsof -i :5000
   lsof -i :6379
   
   # Kill processes using those ports
   kill <PID>
   ```

2. **Use production configuration:**
   ```bash
   docker-compose -f docker-compose.dev.yml down
   docker-compose up -d
   ```

   Then access at:
   - Frontend: http://localhost
   - Backend: http://localhost:5000

---

## 🐛 Troubleshooting

### Check if containers are healthy
```bash
docker ps
```

### Access container shell
```bash
docker exec -it smart-grocery-server-dev sh
docker exec -it smart-grocery-redis-dev redis-cli
```

### Rebuild after code changes
```bash
docker-compose -f docker-compose.dev.yml up --build
```

### Check Redis data
```bash
docker exec -it smart-grocery-redis-dev redis-cli
> KEYS *
> GET grocery_items
```

---

## 📊 Resource Monitoring

```bash
docker stats
```

---

## 🎉 Test Your Application

Open http://localhost:8080 in your browser and try:
1. Adding a grocery item
2. Filtering items
3. Removing items
4. Clearing all items

All data is persisted in Redis and survives container restarts!
