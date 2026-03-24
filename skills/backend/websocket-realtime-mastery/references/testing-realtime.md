# Testing Real-time Applications

> Strategies for testing WebSocket and real-time features.

---

## Table of Contents

1. [Unit Testing Hooks](#1-unit-testing-hooks)
2. [Mocking WebSocket](#2-mocking-websocket)
3. [Integration Testing](#3-integration-testing)
4. [E2E Testing with Playwright](#4-e2e-testing-with-playwright)
5. [Load Testing](#5-load-testing)

---

## 1. Unit Testing Hooks

### Testing Custom Hook

```typescript
// hooks/__tests__/use-websocket.test.ts
import { renderHook, act, waitFor } from '@testing-library/react';
import { useWebSocket } from '../use-websocket';
import { MockWebSocket } from '@/__mocks__/websocket';

describe('useWebSocket', () => {
  beforeEach(() => {
    MockWebSocket.instances = [];
    (global as any).WebSocket = MockWebSocket;
  });

  it('connects on mount', async () => {
    const { result } = renderHook(() => 
      useWebSocket({ url: 'wss://test.com' })
    );

    expect(result.current.state).toBe('connecting');
    
    await waitFor(() => {
      expect(result.current.state).toBe('connected');
    });
  });

  it('receives messages', async () => {
    const onMessage = jest.fn();
    renderHook(() => useWebSocket({ 
      url: 'wss://test.com',
      onMessage 
    }));

    await waitFor(() => {
      expect(MockWebSocket.instances).toHaveLength(1);
    });

    act(() => {
      MockWebSocket.instances[0].receiveMessage({ 
        type: 'test',
        data: 'hello' 
      });
    });

    expect(onMessage).toHaveBeenCalledWith({ type: 'test', data: 'hello' });
  });

  it('reconnects on close', async () => {
    jest.useFakeTimers();
    
    renderHook(() => useWebSocket({ 
      url: 'wss://test.com',
      reconnect: true 
    }));

    await waitFor(() => {
      expect(MockWebSocket.instances).toHaveLength(1);
    });

    act(() => {
      MockWebSocket.instances[0].close(1006); // Abnormal
    });

    act(() => {
      jest.advanceTimersByTime(1000);
    });

    expect(MockWebSocket.instances).toHaveLength(2);
    
    jest.useRealTimers();
  });
});
```

---

## 2. Mocking WebSocket

### Mock Implementation

```typescript
// __mocks__/websocket.ts
export class MockWebSocket {
  static instances: MockWebSocket[] = [];
  static CONNECTING = 0;
  static OPEN = 1;
  static CLOSING = 2;
  static CLOSED = 3;

  url: string;
  readyState = MockWebSocket.CONNECTING;
  onopen: ((event: Event) => void) | null = null;
  onclose: ((event: CloseEvent) => void) | null = null;
  onmessage: ((event: MessageEvent) => void) | null = null;
  onerror: ((event: Event) => void) | null = null;

  constructor(url: string) {
    this.url = url;
    MockWebSocket.instances.push(this);

    // Simulate async connection
    setTimeout(() => {
      this.readyState = MockWebSocket.OPEN;
      this.onopen?.(new Event('open'));
    }, 0);
  }

  send(data: string) {
    if (this.readyState !== MockWebSocket.OPEN) {
      throw new Error('WebSocket not open');
    }
    console.log('MockWebSocket sent:', data);
  }

  close(code = 1000, reason = '') {
    this.readyState = MockWebSocket.CLOSED;
    this.onclose?.(new CloseEvent('close', { code, reason }));
  }

  // Test helpers
  receiveMessage(data: unknown) {
    this.onmessage?.(new MessageEvent('message', {
      data: JSON.stringify(data),
    }));
  }

  triggerError(message = 'Test error') {
    this.onerror?.(new ErrorEvent('error', { message }));
  }
}
```

### Mock Socket.IO

```typescript
// __mocks__/socket.io-client.ts
export const mockSocket = {
  on: jest.fn(),
  off: jest.fn(),
  emit: jest.fn(),
  connect: jest.fn(),
  disconnect: jest.fn(),
  connected: true,
  id: 'mock-socket-id',
};

export const io = jest.fn(() => mockSocket);

// Reset helper
export function resetMockSocket() {
  mockSocket.on.mockClear();
  mockSocket.off.mockClear();
  mockSocket.emit.mockClear();
}
```

---

## 3. Integration Testing

### Testing Components with WebSocket

```typescript
// components/__tests__/chat-room.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ChatRoom } from '../chat-room';
import { SocketProvider } from '@/contexts/socket-context';
import { mockSocket, resetMockSocket } from '@/__mocks__/socket.io-client';

describe('ChatRoom', () => {
  beforeEach(() => {
    resetMockSocket();
  });

  it('displays received messages', async () => {
    render(
      <SocketProvider>
        <ChatRoom roomId="test-room" />
      </SocketProvider>
    );

    // Get the handler registered for 'message' event
    const messageHandler = mockSocket.on.mock.calls.find(
      call => call[0] === 'message'
    )?.[1];

    // Simulate receiving a message
    messageHandler?.({ id: '1', text: 'Hello!', userId: 'user-1' });

    await waitFor(() => {
      expect(screen.getByText('Hello!')).toBeInTheDocument();
    });
  });

  it('sends message on submit', async () => {
    const user = userEvent.setup();
    
    render(
      <SocketProvider>
        <ChatRoom roomId="test-room" />
      </SocketProvider>
    );

    await user.type(screen.getByRole('textbox'), 'Hi there!');
    await user.click(screen.getByRole('button', { name: 'Send' }));

    expect(mockSocket.emit).toHaveBeenCalledWith(
      'message',
      expect.objectContaining({ text: 'Hi there!' }),
      expect.any(Function)
    );
  });
});
```

---

## 4. E2E Testing with Playwright

### WebSocket Test

```typescript
// e2e/chat.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Real-time Chat', () => {
  test('two users can chat', async ({ browser }) => {
    // Create two browser contexts
    const context1 = await browser.newContext();
    const context2 = await browser.newContext();
    
    const page1 = await context1.newPage();
    const page2 = await context2.newPage();

    // Both join the same room
    await page1.goto('/chat/room-123');
    await page2.goto('/chat/room-123');

    // User 1 sends message
    await page1.fill('[data-testid="message-input"]', 'Hello from User 1');
    await page1.click('[data-testid="send-button"]');

    // User 2 sees the message
    await expect(page2.locator('text=Hello from User 1')).toBeVisible();

    // User 2 replies
    await page2.fill('[data-testid="message-input"]', 'Hi User 1!');
    await page2.click('[data-testid="send-button"]');

    // User 1 sees the reply
    await expect(page1.locator('text=Hi User 1!')).toBeVisible();

    await context1.close();
    await context2.close();
  });

  test('shows connection status', async ({ page }) => {
    await page.goto('/chat/room-123');
    
    // Should show connected
    await expect(page.locator('[data-testid="connection-status"]'))
      .toHaveText('Connected');
  });
});
```

---

## 5. Load Testing

### Artillery Configuration

```yaml
# artillery.yml
config:
  target: "wss://ws.example.com"
  phases:
    - duration: 60
      arrivalRate: 10
      name: "Warm up"
    - duration: 120
      arrivalRate: 50
      name: "Ramp up"
    - duration: 300
      arrivalRate: 100
      name: "Sustained load"
  engines:
    socketio-v3: {}

scenarios:
  - name: "Chat user"
    engine: socketio-v3
    flow:
      - emit:
          channel: "join-room"
          data:
            roomId: "load-test-room"
      - think: 2
      - loop:
          - emit:
              channel: "message"
              data:
                text: "Load test message {{ $randomString() }}"
          - think: 5
        count: 10
      - emit:
          channel: "leave-room"
          data:
            roomId: "load-test-room"
```

### Run Load Test

```bash
npx artillery run artillery.yml --output report.json
npx artillery report report.json
```

### k6 WebSocket Test

```javascript
// k6-ws-test.js
import ws from 'k6/ws';
import { check } from 'k6';

export const options = {
  vus: 100,
  duration: '5m',
};

export default function () {
  const url = 'wss://ws.example.com/socket.io/?transport=websocket';
  
  const res = ws.connect(url, {}, function (socket) {
    socket.on('open', () => {
      socket.send(JSON.stringify({ type: 'join', room: 'test' }));
    });

    socket.on('message', (data) => {
      check(data, {
        'received message': (d) => d.length > 0,
      });
    });

    socket.setTimeout(function () {
      socket.close();
    }, 10000);
  });

  check(res, { 'connected': (r) => r && r.status === 101 });
}
```

---

> **Tip:** Always test reconnection scenarios and message ordering under high load.
