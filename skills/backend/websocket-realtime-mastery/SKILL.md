---
name: websocket-realtime-mastery
description: WebSocket and real-time application development for React/Next.js. Native WebSocket API, Socket.IO, connection management, heartbeat/ping-pong, reconnection with exponential backoff, optimistic updates, state synchronization, presence indicators, live collaboration, chat applications, real-time notifications, TanStack Query integration. Use when building chat apps, live dashboards, collaborative editing, multiplayer features, real-time notifications, presence systems, or any bidirectional real-time communication.
---

# WebSocket Realtime Mastery 🔌

> Build robust real-time applications with professional-grade patterns.

---

## 1. WebSocket Fundamentals

### WebSocket vs HTTP

| Aspect | HTTP | WebSocket |
|--------|------|-----------|
| Connection | Request-Response | Persistent bidirectional |
| Overhead | Headers on every request | Initial handshake only |
| Latency | Higher (new connection) | Lower (persistent) |
| Server Push | Polling/SSE workarounds | Native support |
| Use Case | REST APIs, static content | Real-time, live updates |

### When to Use WebSocket

| ✅ Use WebSocket | ❌ Use HTTP/REST |
|------------------|------------------|
| Chat/Messaging | CRUD operations |
| Live dashboards | Form submissions |
| Collaborative editing | File uploads |
| Gaming/Multiplayer | Infrequent updates |
| Presence indicators | Cacheable data |
| Real-time notifications | One-time requests |

### Connection Lifecycle

```
Client                    Server
  |                         |
  |------- Handshake -----→ |  HTTP Upgrade Request
  |←------ Upgrade -------- |  101 Switching Protocols
  |                         |
  |←------→ Messages ←-----→|  Bidirectional communication
  |                         |
  |------- Ping/Pong ------→|  Keep-alive (every 25-30s)
  |←------ Pong ----------- |
  |                         |
  |------- Close ---------→ |  Clean termination
  |←------ Close --------- |
```

---

## 2. Native WebSocket API

### Basic Connection

```typescript
// websocket-manager.ts
type ConnectionState = 'connecting' | 'connected' | 'disconnected' | 'reconnecting';

interface WebSocketManager {
  socket: WebSocket | null;
  state: ConnectionState;
  connect: () => void;
  disconnect: () => void;
  send: (data: unknown) => void;
}

function createWebSocketManager(url: string): WebSocketManager {
  let socket: WebSocket | null = null;
  let state: ConnectionState = 'disconnected';
  
  const connect = () => {
    state = 'connecting';
    socket = new WebSocket(url);
    
    socket.onopen = () => {
      state = 'connected';
      console.log('WebSocket connected');
    };
    
    socket.onmessage = (event) => {
      const data = JSON.parse(event.data);
      handleMessage(data);
    };
    
    socket.onerror = (error) => {
      console.error('WebSocket error:', error);
    };
    
    socket.onclose = (event) => {
      state = 'disconnected';
      console.log(`WebSocket closed: ${event.code} ${event.reason}`);
    };
  };
  
  const disconnect = () => {
    socket?.close(1000, 'Client disconnect');
    socket = null;
  };
  
  const send = (data: unknown) => {
    if (socket?.readyState === WebSocket.OPEN) {
      socket.send(JSON.stringify(data));
    }
  };
  
  return { socket, state, connect, disconnect, send };
}
```

### Close Codes Reference

| Code | Name | Description |
|------|------|-------------|
| 1000 | Normal Closure | Clean disconnect |
| 1001 | Going Away | Page navigation, server shutdown |
| 1002 | Protocol Error | Invalid frame received |
| 1003 | Unsupported Data | Unexpected data type |
| 1006 | Abnormal Closure | Connection lost (no close frame) |
| 1008 | Policy Violation | Message violated server policy |
| 1011 | Server Error | Unexpected server condition |

---

## 3. React Custom Hook

### useWebSocket Hook

```typescript
// hooks/use-websocket.ts
import { useRef, useState, useCallback, useEffect } from 'react';

type ConnectionState = 'connecting' | 'connected' | 'disconnected' | 'reconnecting';

interface UseWebSocketOptions {
  url: string;
  onMessage?: (data: unknown) => void;
  onOpen?: () => void;
  onClose?: (event: CloseEvent) => void;
  onError?: (error: Event) => void;
  reconnect?: boolean;
  reconnectAttempts?: number;
  reconnectInterval?: number;
}

interface UseWebSocketReturn {
  state: ConnectionState;
  send: (data: unknown) => void;
  disconnect: () => void;
  connect: () => void;
}

export function useWebSocket({
  url,
  onMessage,
  onOpen,
  onClose,
  onError,
  reconnect = true,
  reconnectAttempts = 5,
  reconnectInterval = 1000,
}: UseWebSocketOptions): UseWebSocketReturn {
  const socketRef = useRef<WebSocket | null>(null);
  const attemptRef = useRef(0);
  const reconnectTimeoutRef = useRef<NodeJS.Timeout>();
  
  const [state, setState] = useState<ConnectionState>('disconnected');
  
  // Use refs for callbacks to avoid stale closures
  const onMessageRef = useRef(onMessage);
  const onOpenRef = useRef(onOpen);
  const onCloseRef = useRef(onClose);
  const onErrorRef = useRef(onError);
  
  useEffect(() => {
    onMessageRef.current = onMessage;
    onOpenRef.current = onOpen;
    onCloseRef.current = onClose;
    onErrorRef.current = onError;
  });
  
  const connect = useCallback(() => {
    // Prevent multiple connections
    if (socketRef.current?.readyState === WebSocket.OPEN) return;
    
    setState('connecting');
    const ws = new WebSocket(url);
    socketRef.current = ws;
    
    ws.onopen = () => {
      setState('connected');
      attemptRef.current = 0;
      onOpenRef.current?.();
    };
    
    ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        onMessageRef.current?.(data);
      } catch {
        onMessageRef.current?.(event.data);
      }
    };
    
    ws.onerror = (error) => {
      onErrorRef.current?.(error);
    };
    
    ws.onclose = (event) => {
      setState('disconnected');
      onCloseRef.current?.(event);
      
      // Reconnect logic with exponential backoff
      if (reconnect && attemptRef.current < reconnectAttempts && event.code !== 1000) {
        setState('reconnecting');
        const delay = Math.min(
          reconnectInterval * Math.pow(2, attemptRef.current),
          30000 // Max 30 seconds
        );
        attemptRef.current++;
        
        reconnectTimeoutRef.current = setTimeout(() => {
          connect();
        }, delay);
      }
    };
  }, [url, reconnect, reconnectAttempts, reconnectInterval]);
  
  const disconnect = useCallback(() => {
    clearTimeout(reconnectTimeoutRef.current);
    attemptRef.current = reconnectAttempts; // Prevent reconnection
    socketRef.current?.close(1000, 'Client disconnect');
  }, [reconnectAttempts]);
  
  const send = useCallback((data: unknown) => {
    if (socketRef.current?.readyState === WebSocket.OPEN) {
      socketRef.current.send(JSON.stringify(data));
    } else {
      console.warn('WebSocket not connected');
    }
  }, []);
  
  // Connect on mount, cleanup on unmount
  useEffect(() => {
    connect();
    return () => disconnect();
  }, [connect, disconnect]);
  
  return { state, send, disconnect, connect };
}
```

### Usage Example

```tsx
function ChatRoom({ roomId }: { roomId: string }) {
  const [messages, setMessages] = useState<Message[]>([]);
  
  const { state, send } = useWebSocket({
    url: `wss://api.example.com/chat/${roomId}`,
    onMessage: (data) => {
      const message = data as Message;
      setMessages(prev => [...prev, message]);
    },
    onOpen: () => console.log('Connected to chat'),
  });
  
  const sendMessage = (text: string) => {
    send({ type: 'message', text });
  };
  
  return (
    <div>
      <ConnectionIndicator state={state} />
      <MessageList messages={messages} />
      <MessageInput onSend={sendMessage} disabled={state !== 'connected'} />
    </div>
  );
}
```

---

## 4. Socket.IO Integration

### Setup

```bash
npm install socket.io-client
```

### Socket Context Provider

```typescript
// contexts/socket-context.tsx
import { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { io, Socket } from 'socket.io-client';

interface SocketContextType {
  socket: Socket | null;
  isConnected: boolean;
}

const SocketContext = createContext<SocketContextType>({
  socket: null,
  isConnected: false,
});

export function SocketProvider({ children }: { children: ReactNode }) {
  const [socket, setSocket] = useState<Socket | null>(null);
  const [isConnected, setIsConnected] = useState(false);
  
  useEffect(() => {
    const socketInstance = io(process.env.NEXT_PUBLIC_WS_URL!, {
      // Socket.IO options
      transports: ['websocket', 'polling'], // WebSocket first, fallback to polling
      reconnection: true,
      reconnectionAttempts: 5,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 30000,
      auth: {
        token: localStorage.getItem('token'),
      },
    });
    
    socketInstance.on('connect', () => {
      setIsConnected(true);
      console.log('Socket connected:', socketInstance.id);
    });
    
    socketInstance.on('disconnect', (reason) => {
      setIsConnected(false);
      console.log('Socket disconnected:', reason);
    });
    
    socketInstance.on('connect_error', (error) => {
      console.error('Connection error:', error.message);
    });
    
    setSocket(socketInstance);
    
    return () => {
      socketInstance.disconnect();
    };
  }, []);
  
  return (
    <SocketContext.Provider value={{ socket, isConnected }}>
      {children}
    </SocketContext.Provider>
  );
}

export const useSocket = () => useContext(SocketContext);
```

### Socket.IO Namespaces & Rooms

```typescript
// Namespace for different features
const chatSocket = io('/chat');
const notificationsSocket = io('/notifications');

// Joining rooms
socket.emit('join-room', { roomId: 'room-123' });

// Server-side room handling
io.on('connection', (socket) => {
  socket.on('join-room', ({ roomId }) => {
    socket.join(roomId);
    socket.to(roomId).emit('user-joined', { userId: socket.id });
  });
  
  socket.on('send-message', ({ roomId, message }) => {
    io.to(roomId).emit('new-message', message);
  });
});
```

---

## 5. Connection Resilience

### Heartbeat Implementation

```typescript
// Keep connection alive and detect dead connections
class HeartbeatManager {
  private pingInterval: NodeJS.Timeout | null = null;
  private pongTimeout: NodeJS.Timeout | null = null;
  private readonly PING_INTERVAL = 25000; // 25 seconds
  private readonly PONG_TIMEOUT = 5000;   // 5 seconds to respond
  
  constructor(
    private socket: WebSocket,
    private onDead: () => void
  ) {}
  
  start() {
    this.pingInterval = setInterval(() => {
      if (this.socket.readyState === WebSocket.OPEN) {
        this.socket.send(JSON.stringify({ type: 'ping' }));
        
        // Set timeout for pong response
        this.pongTimeout = setTimeout(() => {
          console.warn('Connection dead - no pong received');
          this.onDead();
        }, this.PONG_TIMEOUT);
      }
    }, this.PING_INTERVAL);
  }
  
  handlePong() {
    if (this.pongTimeout) {
      clearTimeout(this.pongTimeout);
      this.pongTimeout = null;
    }
  }
  
  stop() {
    if (this.pingInterval) {
      clearInterval(this.pingInterval);
      this.pingInterval = null;
    }
    if (this.pongTimeout) {
      clearTimeout(this.pongTimeout);
      this.pongTimeout = null;
    }
  }
}
```

### Exponential Backoff with Jitter

```typescript
// Prevent "thundering herd" when server recovers
function getReconnectDelay(attempt: number): number {
  const baseDelay = 1000;   // 1 second
  const maxDelay = 30000;   // 30 seconds
  
  // Exponential backoff: 1s, 2s, 4s, 8s, 16s, 30s
  const exponentialDelay = Math.min(baseDelay * Math.pow(2, attempt), maxDelay);
  
  // Add random jitter (±25%) to prevent synchronized reconnections
  const jitter = exponentialDelay * 0.25 * (Math.random() * 2 - 1);
  
  return Math.floor(exponentialDelay + jitter);
}

// Usage in reconnection logic
let attempt = 0;

function reconnect() {
  const delay = getReconnectDelay(attempt);
  console.log(`Reconnecting in ${delay}ms (attempt ${attempt + 1})`);
  
  setTimeout(() => {
    attempt++;
    connect();
  }, delay);
}
```

### Offline Message Queue

```typescript
// Queue messages when offline, send when reconnected
class MessageQueue {
  private queue: Array<{ id: string; data: unknown; timestamp: number }> = [];
  private maxSize = 100;
  private maxAge = 5 * 60 * 1000; // 5 minutes
  
  enqueue(data: unknown): string {
    const id = crypto.randomUUID();
    
    // Remove old messages
    this.queue = this.queue.filter(
      msg => Date.now() - msg.timestamp < this.maxAge
    );
    
    // Limit queue size
    if (this.queue.length >= this.maxSize) {
      this.queue.shift();
    }
    
    this.queue.push({ id, data, timestamp: Date.now() });
    return id;
  }
  
  flush(send: (data: unknown) => void): void {
    while (this.queue.length > 0) {
      const message = this.queue.shift();
      if (message) {
        send(message.data);
      }
    }
  }
  
  remove(id: string): void {
    this.queue = this.queue.filter(msg => msg.id !== id);
  }
  
  get pendingCount(): number {
    return this.queue.length;
  }
}
```

---

## 6. State Synchronization

### Optimistic Updates

```typescript
// Show immediate feedback, rollback on failure
interface Message {
  id: string;
  text: string;
  status: 'pending' | 'sent' | 'failed';
}

function useChatMessages() {
  const [messages, setMessages] = useState<Message[]>([]);
  const { send } = useSocket();
  
  const sendMessage = useCallback((text: string) => {
    const tempId = `temp-${Date.now()}`;
    
    // Step 1: Optimistic update - show immediately
    const optimisticMessage: Message = {
      id: tempId,
      text,
      status: 'pending',
    };
    setMessages(prev => [...prev, optimisticMessage]);
    
    // Step 2: Send to server with acknowledgment
    send({
      type: 'message',
      tempId,
      text,
    });
  }, [send]);
  
  // Handle server acknowledgment
  const handleAck = useCallback(({ tempId, serverId, success }: AckPayload) => {
    setMessages(prev => prev.map(msg => 
      msg.id === tempId
        ? { ...msg, id: serverId, status: success ? 'sent' : 'failed' }
        : msg
    ));
  }, []);
  
  // Handle incoming messages from others
  const handleNewMessage = useCallback((message: Message) => {
    setMessages(prev => {
      // Deduplicate - don't add if we already have this message
      if (prev.some(m => m.id === message.id)) return prev;
      return [...prev, { ...message, status: 'sent' }];
    });
  }, []);
  
  return { messages, sendMessage };
}
```

### TanStack Query Integration

```typescript
// Invalidate queries on WebSocket events
import { useQueryClient } from '@tanstack/react-query';

function useRealtimeSync() {
  const queryClient = useQueryClient();
  const { socket } = useSocket();
  
  useEffect(() => {
    if (!socket) return;
    
    // Invalidate specific queries when data changes
    socket.on('task-updated', ({ taskId }) => {
      queryClient.invalidateQueries({ queryKey: ['tasks', taskId] });
    });
    
    socket.on('tasks-list-changed', () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
    });
    
    // Direct cache updates for efficiency
    socket.on('task-status-changed', ({ taskId, status }) => {
      queryClient.setQueryData(['tasks', taskId], (old: Task) => ({
        ...old,
        status,
      }));
    });
    
    return () => {
      socket.off('task-updated');
      socket.off('tasks-list-changed');
      socket.off('task-status-changed');
    };
  }, [socket, queryClient]);
}
```

---

## 7. Common Patterns

### Presence System (Who's Online)

```typescript
// Track online users in real-time
interface User {
  id: string;
  name: string;
  avatar: string;
  lastSeen: number;
}

function usePresence(channelId: string) {
  const [members, setMembers] = useState<Map<string, User>>(new Map());
  const { socket } = useSocket();
  
  useEffect(() => {
    if (!socket) return;
    
    // Join presence channel
    socket.emit('presence:join', { channelId });
    
    // Handle presence updates
    socket.on('presence:sync', (users: User[]) => {
      setMembers(new Map(users.map(u => [u.id, u])));
    });
    
    socket.on('presence:join', (user: User) => {
      setMembers(prev => new Map(prev).set(user.id, user));
    });
    
    socket.on('presence:leave', ({ userId }) => {
      setMembers(prev => {
        const next = new Map(prev);
        next.delete(userId);
        return next;
      });
    });
    
    return () => {
      socket.emit('presence:leave', { channelId });
      socket.off('presence:sync');
      socket.off('presence:join');
      socket.off('presence:leave');
    };
  }, [socket, channelId]);
  
  return { members: Array.from(members.values()) };
}
```

### Typing Indicators

```typescript
function useTypingIndicator(chatId: string, userId: string) {
  const [typingUsers, setTypingUsers] = useState<Set<string>>(new Set());
  const { socket, send } = useSocket();
  const typingTimeoutRef = useRef<Map<string, NodeJS.Timeout>>(new Map());
  
  // Send typing status (debounced)
  const sendTyping = useMemo(
    () => debounce(() => {
      send({ type: 'typing:start', chatId, userId });
    }, 300),
    [send, chatId, userId]
  );
  
  const stopTyping = useCallback(() => {
    send({ type: 'typing:stop', chatId, userId });
  }, [send, chatId, userId]);
  
  useEffect(() => {
    if (!socket) return;
    
    socket.on('typing:start', ({ userId: typingUserId }) => {
      setTypingUsers(prev => new Set(prev).add(typingUserId));
      
      // Auto-remove after 3 seconds if no stop event
      const existingTimeout = typingTimeoutRef.current.get(typingUserId);
      if (existingTimeout) clearTimeout(existingTimeout);
      
      typingTimeoutRef.current.set(
        typingUserId,
        setTimeout(() => {
          setTypingUsers(prev => {
            const next = new Set(prev);
            next.delete(typingUserId);
            return next;
          });
        }, 3000)
      );
    });
    
    socket.on('typing:stop', ({ userId: typingUserId }) => {
      setTypingUsers(prev => {
        const next = new Set(prev);
        next.delete(typingUserId);
        return next;
      });
    });
    
    return () => {
      socket.off('typing:start');
      socket.off('typing:stop');
      typingTimeoutRef.current.forEach(clearTimeout);
    };
  }, [socket]);
  
  return { typingUsers: Array.from(typingUsers), sendTyping, stopTyping };
}
```

### Live Cursors (Collaborative)

```typescript
interface CursorPosition {
  userId: string;
  x: number;
  y: number;
  color: string;
}

function useLiveCursors(documentId: string) {
  const [cursors, setCursors] = useState<Map<string, CursorPosition>>(new Map());
  const { socket, send } = useSocket();
  
  // Throttle cursor updates to reduce network traffic
  const updatePosition = useMemo(
    () => throttle((x: number, y: number) => {
      send({ type: 'cursor:move', documentId, x, y });
    }, 50), // Max 20 updates per second
    [send, documentId]
  );
  
  useEffect(() => {
    if (!socket) return;
    
    socket.on('cursor:move', (cursor: CursorPosition) => {
      setCursors(prev => new Map(prev).set(cursor.userId, cursor));
    });
    
    socket.on('cursor:leave', ({ userId }) => {
      setCursors(prev => {
        const next = new Map(prev);
        next.delete(userId);
        return next;
      });
    });
    
    return () => {
      send({ type: 'cursor:leave', documentId });
      socket.off('cursor:move');
      socket.off('cursor:leave');
    };
  }, [socket, send, documentId]);
  
  return { cursors: Array.from(cursors.values()), updatePosition };
}
```

---

## 8. Security

### Authentication

```typescript
// Authenticate during handshake, not after
const socket = io(WS_URL, {
  auth: {
    token: await getAccessToken(),
  },
  // Or via query params (less secure)
  query: {
    token: accessToken,
  },
});

// Server-side validation
io.use((socket, next) => {
  const token = socket.handshake.auth.token;
  
  try {
    const user = verifyToken(token);
    socket.data.user = user;
    next();
  } catch (err) {
    next(new Error('Authentication failed'));
  }
});
```

### Room Authorization

```typescript
// Verify access before joining rooms
socket.on('join-room', async ({ roomId }) => {
  const user = socket.data.user;
  
  // Check if user has access to this room
  const hasAccess = await checkRoomAccess(user.id, roomId);
  
  if (!hasAccess) {
    socket.emit('error', { message: 'Access denied' });
    return;
  }
  
  socket.join(roomId);
  socket.emit('room-joined', { roomId });
});
```

### Input Validation

```typescript
import { z } from 'zod';

// Define message schema
const MessageSchema = z.object({
  type: z.literal('message'),
  text: z.string().min(1).max(1000),
  roomId: z.string().uuid(),
});

// Validate all incoming messages
socket.on('message', (data) => {
  const result = MessageSchema.safeParse(data);
  
  if (!result.success) {
    socket.emit('error', { message: 'Invalid message format' });
    return;
  }
  
  // Process validated data
  handleMessage(result.data);
});
```

### Rate Limiting

```typescript
// Server-side rate limiting
import { RateLimiterMemory } from 'rate-limiter-flexible';

const rateLimiter = new RateLimiterMemory({
  points: 10,    // 10 messages
  duration: 1,   // per 1 second
});

io.use(async (socket, next) => {
  try {
    await rateLimiter.consume(socket.handshake.address);
    next();
  } catch {
    next(new Error('Rate limit exceeded'));
  }
});
```

---

## 9. Performance Optimization

### Message Batching

```typescript
// Batch multiple updates into single transmission
class MessageBatcher {
  private batch: unknown[] = [];
  private timeout: NodeJS.Timeout | null = null;
  private readonly BATCH_SIZE = 10;
  private readonly BATCH_INTERVAL = 50; // 50ms
  
  constructor(private send: (messages: unknown[]) => void) {}
  
  add(message: unknown) {
    this.batch.push(message);
    
    if (this.batch.length >= this.BATCH_SIZE) {
      this.flush();
    } else if (!this.timeout) {
      this.timeout = setTimeout(() => this.flush(), this.BATCH_INTERVAL);
    }
  }
  
  private flush() {
    if (this.timeout) {
      clearTimeout(this.timeout);
      this.timeout = null;
    }
    
    if (this.batch.length > 0) {
      this.send(this.batch);
      this.batch = [];
    }
  }
}
```

### Lazy Subscription

```typescript
// Only subscribe to rooms when component is visible
function ChatRoom({ roomId }: { roomId: string }) {
  const { socket } = useSocket();
  const [isVisible, setIsVisible] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  
  // Track visibility with Intersection Observer
  useEffect(() => {
    if (!containerRef.current) return;
    
    const observer = new IntersectionObserver(
      ([entry]) => setIsVisible(entry.isIntersecting),
      { threshold: 0.1 }
    );
    
    observer.observe(containerRef.current);
    return () => observer.disconnect();
  }, []);
  
  // Subscribe only when visible
  useEffect(() => {
    if (!socket || !isVisible) return;
    
    socket.emit('subscribe', { roomId });
    
    return () => {
      socket.emit('unsubscribe', { roomId });
    };
  }, [socket, roomId, isVisible]);
  
  return <div ref={containerRef}>...</div>;
}
```

### Binary Data & Compression

```typescript
// Use binary formats for large data
import * as msgpack from '@msgpack/msgpack';

// Encode as binary (smaller than JSON)
const binaryData = msgpack.encode({ type: 'update', data: largeArray });
socket.send(binaryData);

// Receive and decode
socket.binaryType = 'arraybuffer';
socket.onmessage = (event) => {
  const data = msgpack.decode(new Uint8Array(event.data));
};
```

---

## 10. Connection State UI

### Connection Indicator Component

```tsx
import { cva } from 'class-variance-authority';

const indicatorStyles = cva(
  'flex items-center gap-2 px-3 py-1 rounded-full text-sm font-medium',
  {
    variants: {
      state: {
        connected: 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200',
        connecting: 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200',
        reconnecting: 'bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-200',
        disconnected: 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200',
      },
    },
  }
);

const dotStyles = cva('w-2 h-2 rounded-full', {
  variants: {
    state: {
      connected: 'bg-green-500 animate-pulse',
      connecting: 'bg-yellow-500 animate-pulse',
      reconnecting: 'bg-orange-500 animate-ping',
      disconnected: 'bg-red-500',
    },
  },
});

export function ConnectionIndicator({ state }: { state: ConnectionState }) {
  const labels: Record<ConnectionState, string> = {
    connected: 'Connected',
    connecting: 'Connecting...',
    reconnecting: 'Reconnecting...',
    disconnected: 'Disconnected',
  };
  
  return (
    <div className={indicatorStyles({ state })}>
      <span className={dotStyles({ state })} />
      <span>{labels[state]}</span>
    </div>
  );
}
```

### Offline Banner

```tsx
function OfflineBanner() {
  const [isOnline, setIsOnline] = useState(navigator.onLine);
  
  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);
    
    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);
    
    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);
  
  if (isOnline) return null;
  
  return (
    <div className="fixed bottom-4 left-1/2 -translate-x-1/2 bg-yellow-500 text-black px-4 py-2 rounded-lg shadow-lg z-50 flex items-center gap-2">
      <WifiOff className="w-4 h-4" />
      <span>You're offline. Changes will sync when you reconnect.</span>
    </div>
  );
}
```

---

## 11. Testing

### Mocking WebSocket

```typescript
// __mocks__/websocket.ts
export class MockWebSocket {
  static instances: MockWebSocket[] = [];
  
  onopen: ((event: Event) => void) | null = null;
  onclose: ((event: CloseEvent) => void) | null = null;
  onmessage: ((event: MessageEvent) => void) | null = null;
  onerror: ((event: Event) => void) | null = null;
  
  readyState = WebSocket.CONNECTING;
  
  constructor(public url: string) {
    MockWebSocket.instances.push(this);
    
    // Simulate connection delay
    setTimeout(() => {
      this.readyState = WebSocket.OPEN;
      this.onopen?.(new Event('open'));
    }, 0);
  }
  
  send(data: string) {
    console.log('MockWebSocket sent:', data);
  }
  
  close(code?: number, reason?: string) {
    this.readyState = WebSocket.CLOSED;
    this.onclose?.(new CloseEvent('close', { code, reason }));
  }
  
  // Test helper: simulate receiving a message
  receiveMessage(data: unknown) {
    this.onmessage?.(new MessageEvent('message', {
      data: JSON.stringify(data),
    }));
  }
  
  // Test helper: simulate error
  triggerError() {
    this.onerror?.(new Event('error'));
  }
}
```

### Test Example

```typescript
import { render, screen, waitFor } from '@testing-library/react';
import { MockWebSocket } from './__mocks__/websocket';

beforeEach(() => {
  MockWebSocket.instances = [];
  (global as any).WebSocket = MockWebSocket;
});

test('displays messages when received via WebSocket', async () => {
  render(<ChatRoom roomId="test" />);
  
  await waitFor(() => {
    expect(MockWebSocket.instances).toHaveLength(1);
  });
  
  const ws = MockWebSocket.instances[0];
  
  // Simulate receiving a message
  ws.receiveMessage({
    type: 'message',
    text: 'Hello from server!',
    userId: 'user-1',
  });
  
  await waitFor(() => {
    expect(screen.getByText('Hello from server!')).toBeInTheDocument();
  });
});
```

---

## 12. Quick Reference

### Performance Checklist

- [ ] WSS (TLS) used in production
- [ ] Heartbeat/ping-pong implemented
- [ ] Exponential backoff with jitter for reconnection
- [ ] Message queue for offline scenarios
- [ ] Authentication on handshake
- [ ] Input validation on all messages
- [ ] Rate limiting configured
- [ ] Proper cleanup in useEffect
- [ ] Connection state indicator visible to users
- [ ] Lazy subscription for offscreen components

### Common Fixes by Symptom

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Connection drops randomly | No heartbeat | Implement ping/pong |
| Server overwhelmed on recovery | Thundering herd | Add jitter to backoff |
| Messages lost offline | No queue | Implement message queue |
| Stale data after reconnect | No sync | Re-fetch or replay events |
| Memory leaks | Missing cleanup | Cleanup subscriptions |
| UI flickers | Unnecessary re-renders | Memoize callbacks |

---

## 13. Advanced Patterns

For detailed implementations:

- **React Integration Patterns**: See [references/react-patterns.md](references/react-patterns.md)
- **Socket.IO Advanced**: See [references/socketio-advanced.md](references/socketio-advanced.md)
- **Scaling & Architecture**: See [references/scaling-architecture.md](references/scaling-architecture.md)
- **Testing Strategies**: See [references/testing-realtime.md](references/testing-realtime.md)

---

> **Remember:** Real-time apps must gracefully handle network instability. Always implement reconnection, message queues, and clear UI feedback for connection states.
