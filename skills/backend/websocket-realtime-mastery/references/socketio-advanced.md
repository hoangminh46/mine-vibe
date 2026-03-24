# Socket.IO Advanced Patterns

> Production-ready patterns for Socket.IO applications.

---

## Table of Contents

1. [Server Setup](#1-server-setup)
2. [Namespaces & Rooms](#2-namespaces--rooms)
3. [Middleware & Authentication](#3-middleware--authentication)
4. [Acknowledgments & Reliability](#4-acknowledgments--reliability)
5. [Error Handling](#5-error-handling)
6. [Scaling with Redis](#6-scaling-with-redis)

---

## 1. Server Setup

### Basic Express + Socket.IO Server

```typescript
import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';

const app = express();
const httpServer = createServer(app);

const io = new Server(httpServer, {
  cors: {
    origin: process.env.CLIENT_URL,
    credentials: true,
  },
  pingTimeout: 60000,
  pingInterval: 25000,
  transports: ['websocket', 'polling'],
});

io.on('connection', (socket) => {
  console.log(`Connected: ${socket.id}`);
  
  socket.on('disconnect', (reason) => {
    console.log(`Disconnected: ${socket.id}, ${reason}`);
  });
});

httpServer.listen(3001);
```

---

## 2. Namespaces & Rooms

### Namespace Organization

```typescript
// Chat namespace
const chatNs = io.of('/chat');

chatNs.on('connection', (socket) => {
  socket.on('room:join', (roomId) => {
    socket.join(roomId);
    socket.to(roomId).emit('user:joined', socket.data.user);
  });
  
  socket.on('room:leave', (roomId) => {
    socket.leave(roomId);
    socket.to(roomId).emit('user:left', socket.data.user.id);
  });
});
```

### Room Broadcasting

```typescript
// To room (including sender)
io.to('room-123').emit('message', data);

// To room (excluding sender)
socket.to('room-123').emit('message', data);

// To multiple rooms
io.to('room-1').to('room-2').emit('announcement', data);

// To user's personal room
io.to(`user:${userId}`).emit('notification', data);
```

---

## 3. Middleware & Authentication

### JWT Authentication

```typescript
import jwt from 'jsonwebtoken';

io.use(async (socket, next) => {
  const token = socket.handshake.auth.token;
  
  if (!token) {
    return next(new Error('No token'));
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!);
    socket.data.user = await getUserById(decoded.userId);
    next();
  } catch {
    next(new Error('Auth failed'));
  }
});
```

### Rate Limiting

```typescript
import { RateLimiterMemory } from 'rate-limiter-flexible';

const limiter = new RateLimiterMemory({
  points: 100,
  duration: 60,
});

io.use(async (socket, next) => {
  try {
    await limiter.consume(socket.id);
    next();
  } catch {
    next(new Error('Rate limit exceeded'));
  }
});
```

---

## 4. Acknowledgments & Reliability

### Server Acknowledgment

```typescript
socket.on('chat:send', async (data, callback) => {
  try {
    const message = await saveMessage(data);
    socket.to(data.roomId).emit('chat:message', message);
    callback({ success: true, messageId: message.id });
  } catch (err) {
    callback({ success: false, error: err.message });
  }
});
```

### Client with Timeout

```typescript
socket.timeout(5000).emit('chat:send', data, (err, response) => {
  if (err) {
    // Timeout or error
    console.error('Failed:', err);
  } else {
    console.log('Sent:', response.messageId);
  }
});
```

---

## 5. Error Handling

### Error Handler Wrapper

```typescript
function withErrorHandler(socket, handler) {
  return async (...args) => {
    try {
      return await handler(...args);
    } catch (err) {
      socket.emit('error', {
        code: 'INTERNAL_ERROR',
        message: err.message,
      });
    }
  };
}

socket.on('action', withErrorHandler(socket, async (data) => {
  // Handler code
}));
```

---

## 6. Scaling with Redis

### Redis Adapter

```typescript
import { createClient } from 'redis';
import { createAdapter } from '@socket.io/redis-adapter';

const pubClient = createClient({ url: process.env.REDIS_URL });
const subClient = pubClient.duplicate();

await Promise.all([pubClient.connect(), subClient.connect()]);
io.adapter(createAdapter(pubClient, subClient));
```

### Cross-Server Operations

```typescript
// Emit to all servers
io.emit('global', data);

// Fetch sockets across servers
const sockets = await io.in('room-123').fetchSockets();
```

---

> **Note:** Sticky sessions are required when using polling transport with load balancers.
