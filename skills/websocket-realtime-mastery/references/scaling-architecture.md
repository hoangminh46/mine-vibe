# Scaling & Architecture

> Patterns for scaling WebSocket applications to millions of connections.

---

## Table of Contents

1. [Horizontal Scaling](#1-horizontal-scaling)
2. [Pub/Sub Architecture](#2-pubsub-architecture)
3. [Connection Pooling](#3-connection-pooling)
4. [Load Balancing](#4-load-balancing)
5. [Monitoring & Metrics](#5-monitoring--metrics)

---

## 1. Horizontal Scaling

### The N-Squared Problem

```
When user A sends message in a room with N users:
- Each of N servers receives the message
- Each server broadcasts to its M connected users
- Total: N × M messages processed

Solution: Use Pub/Sub to route messages only to relevant servers
```

### Sharding Strategy

```typescript
// Shard by room ID
function getShardForRoom(roomId: string, totalShards: number): number {
  const hash = roomId.split('').reduce((acc, char) => {
    return ((acc << 5) - acc + char.charCodeAt(0)) | 0;
  }, 0);
  return Math.abs(hash) % totalShards;
}

// Route connection to correct shard
const shard = getShardForRoom(roomId, 4);
const wsUrl = `wss://ws-${shard}.example.com`;
```

---

## 2. Pub/Sub Architecture

### Redis Pub/Sub

```typescript
import { Redis } from 'ioredis';

const pub = new Redis(process.env.REDIS_URL);
const sub = new Redis(process.env.REDIS_URL);

// Subscribe to channels
sub.subscribe('chat:*', 'notifications');

sub.on('message', (channel, message) => {
  const data = JSON.parse(message);
  
  if (channel.startsWith('chat:')) {
    const roomId = channel.replace('chat:', '');
    io.to(roomId).emit('message', data);
  }
});

// Publish from any server
function broadcastToRoom(roomId: string, data: unknown) {
  pub.publish(`chat:${roomId}`, JSON.stringify(data));
}
```

### Event-Driven Microservices

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   API       │────▶│   Redis     │────▶│  WebSocket  │
│   Server    │     │   Pub/Sub   │     │   Server    │
└─────────────┘     └─────────────┘     └─────────────┘
                          │
                          ▼
                    ┌─────────────┐
                    │  WebSocket  │
                    │   Server 2  │
                    └─────────────┘
```

---

## 3. Connection Pooling

### Connection Limits

```typescript
const MAX_CONNECTIONS = 10000;
let connectionCount = 0;

io.use((socket, next) => {
  if (connectionCount >= MAX_CONNECTIONS) {
    return next(new Error('Server at capacity'));
  }
  connectionCount++;
  next();
});

io.on('connection', (socket) => {
  socket.on('disconnect', () => {
    connectionCount--;
  });
});
```

### Graceful Shutdown

```typescript
process.on('SIGTERM', async () => {
  // Stop accepting new connections
  io.close();
  
  // Allow existing connections to finish
  const timeout = setTimeout(() => {
    process.exit(0);
  }, 30000);
  
  // Wait for connections to close
  io.on('close', () => {
    clearTimeout(timeout);
    process.exit(0);
  });
});
```

---

## 4. Load Balancing

### Sticky Sessions with NGINX

```nginx
upstream websocket {
    ip_hash;  # Sticky sessions
    server ws1.example.com:3001;
    server ws2.example.com:3001;
    server ws3.example.com:3001;
}

server {
    location /socket.io/ {
        proxy_pass http://websocket;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### WebSocket-Only Mode

```typescript
// Client: Skip polling fallback
const socket = io(WS_URL, {
  transports: ['websocket'],  // No polling = no sticky sessions needed
});
```

---

## 5. Monitoring & Metrics

### Key Metrics

| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| Active Connections | Current open sockets | > 80% capacity |
| Messages/Second | Throughput | Sudden drops |
| Connection Latency | Time to establish | > 500ms |
| Error Rate | Failed connections | > 1% |
| Memory Usage | Per connection | > 80% |

### Prometheus Metrics

```typescript
import { Counter, Gauge, Histogram } from 'prom-client';

const connections = new Gauge({
  name: 'websocket_connections_total',
  help: 'Total active WebSocket connections',
});

const messagesReceived = new Counter({
  name: 'websocket_messages_received_total',
  help: 'Total messages received',
});

const messageLatency = new Histogram({
  name: 'websocket_message_latency_seconds',
  help: 'Message processing latency',
});

io.on('connection', (socket) => {
  connections.inc();
  
  socket.on('message', () => {
    messagesReceived.inc();
  });
  
  socket.on('disconnect', () => {
    connections.dec();
  });
});
```

### Health Check Endpoint

```typescript
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    connections: io.engine.clientsCount,
    uptime: process.uptime(),
    memory: process.memoryUsage(),
  });
});
```

---

> **Best Practice:** Start with a single server, add Redis Pub/Sub for horizontal scaling, then add sharding when needed.
