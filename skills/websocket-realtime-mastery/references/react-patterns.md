# React WebSocket Patterns

> Advanced patterns for integrating WebSocket with React applications.

---

## Table of Contents

1. [Context-Based Architecture](#1-context-based-architecture)
2. [Event-Driven State Management](#2-event-driven-state-management)
3. [Zustand Integration](#3-zustand-integration)
4. [Custom Hooks Library](#4-custom-hooks-library)
5. [Server-Sent Events Alternative](#5-server-sent-events-alternative)
6. [Next.js App Router Integration](#6-nextjs-app-router-integration)

---

## 1. Context-Based Architecture

### Full WebSocket Context with All Features

```typescript
// contexts/websocket-context.tsx
import {
  createContext,
  useContext,
  useReducer,
  useEffect,
  useCallback,
  useRef,
  useMemo,
  ReactNode,
} from 'react';

// Types
type ConnectionState = 'connecting' | 'connected' | 'disconnected' | 'reconnecting';

interface WebSocketMessage {
  type: string;
  payload: unknown;
}

interface WebSocketState {
  connectionState: ConnectionState;
  lastMessage: WebSocketMessage | null;
  error: Error | null;
  reconnectAttempt: number;
}

type WebSocketAction =
  | { type: 'CONNECTING' }
  | { type: 'CONNECTED' }
  | { type: 'DISCONNECTED' }
  | { type: 'RECONNECTING'; attempt: number }
  | { type: 'MESSAGE'; message: WebSocketMessage }
  | { type: 'ERROR'; error: Error };

// Reducer
function wsReducer(state: WebSocketState, action: WebSocketAction): WebSocketState {
  switch (action.type) {
    case 'CONNECTING':
      return { ...state, connectionState: 'connecting', error: null };
    case 'CONNECTED':
      return { ...state, connectionState: 'connected', reconnectAttempt: 0, error: null };
    case 'DISCONNECTED':
      return { ...state, connectionState: 'disconnected' };
    case 'RECONNECTING':
      return { ...state, connectionState: 'reconnecting', reconnectAttempt: action.attempt };
    case 'MESSAGE':
      return { ...state, lastMessage: action.message };
    case 'ERROR':
      return { ...state, error: action.error };
    default:
      return state;
  }
}

// Context
interface WebSocketContextType extends WebSocketState {
  send: (type: string, payload: unknown) => void;
  subscribe: <T>(type: string, handler: (payload: T) => void) => () => void;
  disconnect: () => void;
  connect: () => void;
}

const WebSocketContext = createContext<WebSocketContextType | null>(null);

// Provider
interface WebSocketProviderProps {
  url: string;
  children: ReactNode;
  autoConnect?: boolean;
}

export function WebSocketProvider({
  url,
  children,
  autoConnect = true,
}: WebSocketProviderProps) {
  const [state, dispatch] = useReducer(wsReducer, {
    connectionState: 'disconnected',
    lastMessage: null,
    error: null,
    reconnectAttempt: 0,
  });
  
  const socketRef = useRef<WebSocket | null>(null);
  const reconnectTimeoutRef = useRef<NodeJS.Timeout>();
  const subscribersRef = useRef<Map<string, Set<(payload: unknown) => void>>>(new Map());
  const messageQueueRef = useRef<Array<{ type: string; payload: unknown }>>([]);
  
  // Connect function
  const connect = useCallback(() => {
    if (socketRef.current?.readyState === WebSocket.OPEN) return;
    
    dispatch({ type: 'CONNECTING' });
    const ws = new WebSocket(url);
    socketRef.current = ws;
    
    ws.onopen = () => {
      dispatch({ type: 'CONNECTED' });
      
      // Flush queued messages
      while (messageQueueRef.current.length > 0) {
        const msg = messageQueueRef.current.shift();
        if (msg) {
          ws.send(JSON.stringify(msg));
        }
      }
    };
    
    ws.onmessage = (event) => {
      try {
        const message = JSON.parse(event.data) as WebSocketMessage;
        dispatch({ type: 'MESSAGE', message });
        
        // Notify subscribers
        const handlers = subscribersRef.current.get(message.type);
        handlers?.forEach(handler => handler(message.payload));
      } catch (err) {
        console.error('Failed to parse message:', err);
      }
    };
    
    ws.onerror = () => {
      dispatch({ type: 'ERROR', error: new Error('WebSocket error') });
    };
    
    ws.onclose = (event) => {
      dispatch({ type: 'DISCONNECTED' });
      
      // Reconnect if not intentional close
      if (event.code !== 1000) {
        const attempt = state.reconnectAttempt + 1;
        const delay = Math.min(1000 * Math.pow(2, attempt), 30000);
        
        dispatch({ type: 'RECONNECTING', attempt });
        reconnectTimeoutRef.current = setTimeout(connect, delay);
      }
    };
  }, [url, state.reconnectAttempt]);
  
  // Disconnect function
  const disconnect = useCallback(() => {
    clearTimeout(reconnectTimeoutRef.current);
    socketRef.current?.close(1000, 'Client disconnect');
  }, []);
  
  // Send function
  const send = useCallback((type: string, payload: unknown) => {
    const message = { type, payload };
    
    if (socketRef.current?.readyState === WebSocket.OPEN) {
      socketRef.current.send(JSON.stringify(message));
    } else {
      // Queue for later
      messageQueueRef.current.push(message);
    }
  }, []);
  
  // Subscribe function
  const subscribe = useCallback(<T,>(type: string, handler: (payload: T) => void) => {
    if (!subscribersRef.current.has(type)) {
      subscribersRef.current.set(type, new Set());
    }
    subscribersRef.current.get(type)!.add(handler as (payload: unknown) => void);
    
    return () => {
      subscribersRef.current.get(type)?.delete(handler as (payload: unknown) => void);
    };
  }, []);
  
  // Auto connect
  useEffect(() => {
    if (autoConnect) {
      connect();
    }
    return () => disconnect();
  }, [autoConnect, connect, disconnect]);
  
  const value = useMemo(
    () => ({
      ...state,
      send,
      subscribe,
      disconnect,
      connect,
    }),
    [state, send, subscribe, disconnect, connect]
  );
  
  return (
    <WebSocketContext.Provider value={value}>
      {children}
    </WebSocketContext.Provider>
  );
}

// Hook
export function useWebSocket() {
  const context = useContext(WebSocketContext);
  if (!context) {
    throw new Error('useWebSocket must be used within WebSocketProvider');
  }
  return context;
}

// Typed subscription hook
export function useWebSocketEvent<T>(type: string, handler: (payload: T) => void) {
  const { subscribe } = useWebSocket();
  
  useEffect(() => {
    return subscribe<T>(type, handler);
  }, [type, handler, subscribe]);
}
```

### Usage

```tsx
// app/layout.tsx
export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html>
      <body>
        <WebSocketProvider url={process.env.NEXT_PUBLIC_WS_URL!}>
          {children}
        </WebSocketProvider>
      </body>
    </html>
  );
}

// components/chat.tsx
function ChatMessages() {
  const [messages, setMessages] = useState<Message[]>([]);
  
  useWebSocketEvent<Message>('new-message', (message) => {
    setMessages(prev => [...prev, message]);
  });
  
  return <MessageList messages={messages} />;
}
```

---

## 2. Event-Driven State Management

### Event Emitter Pattern

```typescript
// lib/event-emitter.ts
type EventHandler<T = unknown> = (data: T) => void;

class TypedEventEmitter {
  private handlers = new Map<string, Set<EventHandler>>();
  
  on<T>(event: string, handler: EventHandler<T>): () => void {
    if (!this.handlers.has(event)) {
      this.handlers.set(event, new Set());
    }
    this.handlers.get(event)!.add(handler as EventHandler);
    
    return () => this.off(event, handler);
  }
  
  off<T>(event: string, handler: EventHandler<T>): void {
    this.handlers.get(event)?.delete(handler as EventHandler);
  }
  
  emit<T>(event: string, data: T): void {
    this.handlers.get(event)?.forEach(handler => handler(data));
  }
  
  once<T>(event: string, handler: EventHandler<T>): () => void {
    const wrappedHandler: EventHandler<T> = (data) => {
      handler(data);
      this.off(event, wrappedHandler);
    };
    return this.on(event, wrappedHandler);
  }
}

export const wsEvents = new TypedEventEmitter();
```

### React Hook for Event Emitter

```typescript
// hooks/use-event.ts
export function useEvent<T>(event: string, handler: (data: T) => void) {
  const handlerRef = useRef(handler);
  handlerRef.current = handler;
  
  useEffect(() => {
    const stableHandler = (data: T) => handlerRef.current(data);
    return wsEvents.on(event, stableHandler);
  }, [event]);
}

// Usage
function NotificationToast() {
  const [toast, setToast] = useState<{ message: string } | null>(null);
  
  useEvent<{ message: string }>('notification', (data) => {
    setToast(data);
    setTimeout(() => setToast(null), 3000);
  });
  
  if (!toast) return null;
  return <Toast message={toast.message} />;
}
```

---

## 3. Zustand Integration

### WebSocket Store with Zustand

```typescript
// stores/websocket-store.ts
import { create } from 'zustand';
import { subscribeWithSelector } from 'zustand/middleware';

interface Message {
  id: string;
  text: string;
  userId: string;
  timestamp: number;
}

interface WebSocketStore {
  // Connection state
  socket: WebSocket | null;
  isConnected: boolean;
  
  // Data
  messages: Message[];
  onlineUsers: string[];
  
  // Actions
  connect: (url: string) => void;
  disconnect: () => void;
  sendMessage: (text: string) => void;
  
  // Internal
  _addMessage: (message: Message) => void;
  _setOnlineUsers: (users: string[]) => void;
}

export const useWebSocketStore = create<WebSocketStore>()(
  subscribeWithSelector((set, get) => ({
    socket: null,
    isConnected: false,
    messages: [],
    onlineUsers: [],
    
    connect: (url) => {
      const socket = new WebSocket(url);
      
      socket.onopen = () => {
        set({ isConnected: true });
      };
      
      socket.onmessage = (event) => {
        const data = JSON.parse(event.data);
        
        switch (data.type) {
          case 'message':
            get()._addMessage(data.payload);
            break;
          case 'online-users':
            get()._setOnlineUsers(data.payload);
            break;
        }
      };
      
      socket.onclose = () => {
        set({ isConnected: false, socket: null });
      };
      
      set({ socket });
    },
    
    disconnect: () => {
      get().socket?.close(1000);
      set({ socket: null, isConnected: false });
    },
    
    sendMessage: (text) => {
      const { socket } = get();
      if (socket?.readyState === WebSocket.OPEN) {
        socket.send(JSON.stringify({
          type: 'message',
          payload: { text },
        }));
      }
    },
    
    _addMessage: (message) => {
      set((state) => ({
        messages: [...state.messages, message],
      }));
    },
    
    _setOnlineUsers: (users) => {
      set({ onlineUsers: users });
    },
  }))
);

// Selectors
export const selectIsConnected = (state: WebSocketStore) => state.isConnected;
export const selectMessages = (state: WebSocketStore) => state.messages;
export const selectOnlineUsers = (state: WebSocketStore) => state.onlineUsers;
```

### Usage with Zustand

```tsx
function ChatApp() {
  const { connect, disconnect, isConnected } = useWebSocketStore();
  
  useEffect(() => {
    connect(process.env.NEXT_PUBLIC_WS_URL!);
    return () => disconnect();
  }, [connect, disconnect]);
  
  return (
    <div>
      <ConnectionStatus isConnected={isConnected} />
      <MessageList />
      <MessageInput />
    </div>
  );
}

function MessageList() {
  const messages = useWebSocketStore(selectMessages);
  
  return (
    <ul>
      {messages.map(msg => (
        <li key={msg.id}>{msg.text}</li>
      ))}
    </ul>
  );
}

function OnlineUsers() {
  const users = useWebSocketStore(selectOnlineUsers);
  
  return (
    <div>
      <span>{users.length} online</span>
    </div>
  );
}
```

---

## 4. Custom Hooks Library

### useReconnectingWebSocket

```typescript
// hooks/use-reconnecting-websocket.ts
interface Options {
  maxAttempts?: number;
  initialDelay?: number;
  maxDelay?: number;
  onReconnect?: (attempt: number) => void;
}

export function useReconnectingWebSocket(
  url: string,
  {
    maxAttempts = 10,
    initialDelay = 1000,
    maxDelay = 30000,
    onReconnect,
  }: Options = {}
) {
  const [socket, setSocket] = useState<WebSocket | null>(null);
  const [attempt, setAttempt] = useState(0);
  const [status, setStatus] = useState<'idle' | 'connecting' | 'connected' | 'reconnecting'>('idle');
  
  useEffect(() => {
    let ws: WebSocket;
    let timeoutId: NodeJS.Timeout;
    let currentAttempt = 0;
    
    const connect = () => {
      setStatus(currentAttempt === 0 ? 'connecting' : 'reconnecting');
      ws = new WebSocket(url);
      
      ws.onopen = () => {
        currentAttempt = 0;
        setAttempt(0);
        setStatus('connected');
        setSocket(ws);
      };
      
      ws.onclose = (event) => {
        setSocket(null);
        
        if (event.code !== 1000 && currentAttempt < maxAttempts) {
          currentAttempt++;
          setAttempt(currentAttempt);
          onReconnect?.(currentAttempt);
          
          const delay = Math.min(
            initialDelay * Math.pow(2, currentAttempt - 1),
            maxDelay
          );
          timeoutId = setTimeout(connect, delay);
        }
      };
    };
    
    connect();
    
    return () => {
      clearTimeout(timeoutId);
      ws?.close(1000);
    };
  }, [url, maxAttempts, initialDelay, maxDelay, onReconnect]);
  
  return { socket, status, attempt };
}
```

### useWebSocketSubscription

```typescript
// hooks/use-websocket-subscription.ts
type MessageType<T extends Record<string, unknown>> = keyof T;

export function useWebSocketSubscription<
  TMessages extends Record<string, unknown>
>(socket: WebSocket | null) {
  const handlers = useRef<Map<string, (data: unknown) => void>>(new Map());
  
  useEffect(() => {
    if (!socket) return;
    
    const handleMessage = (event: MessageEvent) => {
      try {
        const { type, payload } = JSON.parse(event.data);
        handlers.current.get(type)?.(payload);
      } catch (err) {
        console.error('Parse error:', err);
      }
    };
    
    socket.addEventListener('message', handleMessage);
    return () => socket.removeEventListener('message', handleMessage);
  }, [socket]);
  
  const subscribe = useCallback(<T extends MessageType<TMessages>>(
    type: T,
    handler: (data: TMessages[T]) => void
  ) => {
    handlers.current.set(type as string, handler as (data: unknown) => void);
    return () => handlers.current.delete(type as string);
  }, []);
  
  return { subscribe };
}

// Usage with type safety
interface ChatMessages {
  'user-joined': { userId: string; name: string };
  'user-left': { userId: string };
  'new-message': { id: string; text: string; userId: string };
}

function ChatRoom() {
  const { socket } = useWebSocket();
  const { subscribe } = useWebSocketSubscription<ChatMessages>(socket);
  
  useEffect(() => {
    const unsubJoined = subscribe('user-joined', (data) => {
      // data is typed as { userId: string; name: string }
      console.log(`${data.name} joined`);
    });
    
    const unsubMessage = subscribe('new-message', (data) => {
      // data is typed as { id: string; text: string; userId: string }
      addMessage(data);
    });
    
    return () => {
      unsubJoined();
      unsubMessage();
    };
  }, [subscribe]);
}
```

---

## 5. Server-Sent Events Alternative

### When to Use SSE vs WebSocket

| Aspect | SSE | WebSocket |
|--------|-----|-----------|
| Direction | Server → Client only | Bidirectional |
| Protocol | HTTP | WebSocket |
| Reconnection | Built-in | Manual |
| Complexity | Simpler | More complex |
| Use Case | Live feeds, notifications | Chat, collaboration |

### useEventSource Hook

```typescript
// hooks/use-event-source.ts
interface UseEventSourceOptions {
  onMessage?: (data: unknown) => void;
  onError?: (error: Event) => void;
  withCredentials?: boolean;
}

export function useEventSource(
  url: string,
  { onMessage, onError, withCredentials = false }: UseEventSourceOptions = {}
) {
  const [isConnected, setIsConnected] = useState(false);
  const eventSourceRef = useRef<EventSource | null>(null);
  
  useEffect(() => {
    const es = new EventSource(url, { withCredentials });
    eventSourceRef.current = es;
    
    es.onopen = () => setIsConnected(true);
    
    es.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        onMessage?.(data);
      } catch {
        onMessage?.(event.data);
      }
    };
    
    es.onerror = (error) => {
      setIsConnected(false);
      onError?.(error);
    };
    
    return () => {
      es.close();
    };
  }, [url, withCredentials]);
  
  const close = useCallback(() => {
    eventSourceRef.current?.close();
    setIsConnected(false);
  }, []);
  
  return { isConnected, close };
}

// Usage
function LiveFeed() {
  const [items, setItems] = useState<Item[]>([]);
  
  useEventSource('/api/feed', {
    onMessage: (data) => {
      setItems(prev => [data as Item, ...prev]);
    },
  });
  
  return <FeedList items={items} />;
}
```

---

## 6. Next.js App Router Integration

### Route Handler for WebSocket Upgrade

```typescript
// app/api/ws/route.ts (Edge Runtime with WebSocket)
// Note: Standard Next.js doesn't support WebSocket in API routes
// Use a separate WebSocket server or services like Ably, Pusher, etc.

// For development, you can use a custom server:
// server.js
import { createServer } from 'http';
import { WebSocketServer } from 'ws';
import next from 'next';

const dev = process.env.NODE_ENV !== 'production';
const app = next({ dev });
const handle = app.getRequestHandler();

app.prepare().then(() => {
  const server = createServer((req, res) => handle(req, res));
  
  const wss = new WebSocketServer({ server, path: '/ws' });
  
  wss.on('connection', (ws) => {
    console.log('Client connected');
    
    ws.on('message', (data) => {
      const message = JSON.parse(data.toString());
      // Handle message
    });
    
    ws.on('close', () => {
      console.log('Client disconnected');
    });
  });
  
  server.listen(3000, () => {
    console.log('Server running on http://localhost:3000');
  });
});
```

### Client Component with WebSocket

```tsx
// components/realtime-dashboard.tsx
'use client';

import { useWebSocket } from '@/hooks/use-websocket';
import { useEffect, useState } from 'react';

interface MetricUpdate {
  name: string;
  value: number;
  timestamp: number;
}

export function RealtimeDashboard() {
  const [metrics, setMetrics] = useState<Record<string, MetricUpdate>>({});
  
  const { state, send } = useWebSocket({
    url: process.env.NEXT_PUBLIC_WS_URL!,
    onOpen: () => {
      send({ type: 'subscribe', channels: ['metrics'] });
    },
    onMessage: (data) => {
      const update = data as { type: string; payload: MetricUpdate };
      if (update.type === 'metric-update') {
        setMetrics(prev => ({
          ...prev,
          [update.payload.name]: update.payload,
        }));
      }
    },
  });
  
  return (
    <div className="grid grid-cols-2 gap-4">
      {Object.values(metrics).map(metric => (
        <MetricCard key={metric.name} metric={metric} />
      ))}
    </div>
  );
}
```

---

> **Best Practice:** Keep WebSocket logic in custom hooks and context providers. Avoid putting WebSocket handlers directly in components to maintain clean separation of concerns.
