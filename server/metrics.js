// Prometheus metrics middleware for Express
const promClient = require('prom-client');

// Create a Registry
const register = new promClient.Registry();

// Add default metrics (CPU, memory, event loop, etc.)
promClient.collectDefaultMetrics({
  register,
  prefix: 'smart_grocery_',
});

// Custom metrics
const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1, 5],
  registers: [register],
});

const httpRequestTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
});

const activeConnections = new promClient.Gauge({
  name: 'active_connections',
  help: 'Number of active connections',
  registers: [register],
});

const redisOperations = new promClient.Counter({
  name: 'redis_operations_total',
  help: 'Total number of Redis operations',
  labelNames: ['operation', 'status'],
  registers: [register],
});

const redisLatency = new promClient.Histogram({
  name: 'redis_operation_duration_seconds',
  help: 'Duration of Redis operations in seconds',
  labelNames: ['operation'],
  buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1],
  registers: [register],
});

const itemsCount = new promClient.Gauge({
  name: 'grocery_items_total',
  help: 'Total number of grocery items',
  registers: [register],
});

// Middleware to track metrics
const metricsMiddleware = (req, res, next) => {
  const start = Date.now();
  
  // Increment active connections
  activeConnections.inc();

  // Track response
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;
    const status = res.statusCode;

    // Record metrics
    httpRequestDuration.observe(
      { method: req.method, route, status },
      duration
    );
    httpRequestTotal.inc({ method: req.method, route, status });
    
    // Decrement active connections
    activeConnections.dec();
  });

  next();
};

// Helper function to track Redis operations
const trackRedisOperation = async (operation, fn) => {
  const start = Date.now();
  try {
    const result = await fn();
    const duration = (Date.now() - start) / 1000;
    
    redisOperations.inc({ operation, status: 'success' });
    redisLatency.observe({ operation }, duration);
    
    return result;
  } catch (error) {
    redisOperations.inc({ operation, status: 'error' });
    throw error;
  }
};

// Update items count
const updateItemsCount = (count) => {
  itemsCount.set(count);
};

// Metrics endpoint handler
const metricsHandler = async (req, res) => {
  try {
    res.set('Content-Type', register.contentType);
    const metrics = await register.metrics();
    res.end(metrics);
  } catch (error) {
    res.status(500).end(error);
  }
};

module.exports = {
  register,
  metricsMiddleware,
  metricsHandler,
  trackRedisOperation,
  updateItemsCount,
};
