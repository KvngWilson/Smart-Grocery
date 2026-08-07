const express = require("express");
const cors = require("cors");
const { redisClient } = require("./redisClient");
const {
  metricsMiddleware,
  metricsHandler,
  trackRedisOperation,
  updateItemsCount,
} = require("./metrics");

const app = express();
const PORT = 5000;

app.use(cors());
app.use(express.json());
app.use(metricsMiddleware);

const KEY = "grocery_items";

// Prometheus metrics endpoint
app.get("/metrics", metricsHandler);

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({ status: "healthy", timestamp: new Date().toISOString() });
});

app.get("/items", async (req, res) => {
  try {
    const items = await trackRedisOperation("get", async () => {
      return JSON.parse((await redisClient.get(KEY)) || "[]");
    });
    updateItemsCount(items.length);
    res.json(items);
  } catch (error) {
    console.error("Error fetching items:", error);
    res.status(500).json({ error: "Failed to fetch items" });
  }
});

app.post("/items", async (req, res) => {
  try {
    const { item } = req.body;
    if (!item || !item.trim()) {
      return res.status(400).json({ error: "Item cannot be empty" });
    }
    const items = await trackRedisOperation("set", async () => {
      const currentItems = JSON.parse((await redisClient.get(KEY)) || "[]");
      if (currentItems.includes(item.trim())) {
        throw new Error("Item already exists");
      }
      currentItems.push(item.trim());
      await redisClient.set(KEY, JSON.stringify(currentItems));
      return currentItems;
    });
    updateItemsCount(items.length);
    res.json(items);
  } catch (error) {
    if (error.message === "Item already exists") {
      return res.status(400).json({ error: error.message });
    }
    console.error("Error adding item:", error);
    res.status(500).json({ error: "Failed to add item" });
  }
});

app.delete("/items/:name", async (req, res) => {
  try {
    const {name} = req.params;
    const items = await trackRedisOperation("delete", async () => {
      let currentItems = JSON.parse((await redisClient.get(KEY)) || "[]");
      currentItems = currentItems.filter(i => i !== name);
      await redisClient.set(KEY, JSON.stringify(currentItems));
      return currentItems;
    });
    updateItemsCount(items.length);
    res.json(items);
  } catch (error) {
    console.error("Error removing item:", error);
    res.status(500).json({ error: "Failed to remove item" });
  }
});

app.delete("/items", async (req, res) => {
  try {
    await trackRedisOperation("clear", async () => {
      await redisClient.set(KEY, JSON.stringify([]));
    });
    updateItemsCount(0);
    res.json([]);
  } catch (error) {
    console.error("Error clearing items:", error);
    res.status(500).json({ error: "Failed to clear items" });
  }
});

app.listen(PORT, () => console.log("Server running on port", PORT));
