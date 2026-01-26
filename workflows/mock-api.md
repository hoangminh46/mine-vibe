---
description: 💃 Tạo và quản lý Mock API (MSW) - Professional Edition
---

# 🎭 Mock API Workflow (MSW + Faker + Data)

Workflow này giúp bạn thiết lập môi trường giả lập API (Mocking) "Premium" - không chỉ trả về dữ liệu tĩnh mà còn hỗ trợ **CRUD, Persistence Data, giả lập Network Delay và Error Handling**.

## 📦 1. Cài đặt Dependencies

Cài đặt `msw` (v2), `@faker-js/faker` và `@mswjs/data` để quản lý database ảo.

// turbo
```bash
npm install msw @faker-js/faker @mswjs/data --save-dev
```

## 🛠 2. Khởi tạo MSW

Tạo Service Worker script trong thư mục `public`.

// turbo
```bash
npx msw init public/ --save
```

## 📂 3. Cấu trúc thư mục (Advanced)

```text
src/
  mocks/
    ├── db.ts           # Database ảo (Persistence layer)
    ├── handlers.ts     # Definition của các API endpoints
    ├── browser.ts      # Setup Client-side
    ├── node.ts         # Setup Server-side (Testing/SSR)
    └── MSWProvider.tsx # Client Component để kích hoạt Mocking
```

## 📝 4. Implement Code

### 4.1. Define Database (`src/mocks/db.ts`)
Sử dụng `@mswjs/data` để dữ liệu không bị reset khi chuyển trang và hỗ trợ CRUD.

```typescript
import { factory, primaryKey } from '@mswjs/data';
import { faker } from '@faker-js/faker';

export const db = factory({
  user: {
    id: primaryKey(faker.string.uuid),
    name: String,
    email: String,
    avatar: String,
  },
});

// Khởi tạo dữ liệu mẫu
db.user.create({
  id: 'user-1',
  name: 'Vibe Coder',
  email: 'hello@mine.vibe',
  avatar: 'https://i.pravatar.cc/150?u=mine',
});
```

### 4.2. Handlers với Delay & Error (`src/mocks/handlers.ts`)

```typescript
import { http, HttpResponse, delay } from 'msw';
import { db } from './db';

export const handlers = [
  // Mock API: GET /api/me
  http.get('*/api/me', async () => {
    // 1. Giả lập độ trễ mạng (Real vibration!)
    await delay(800); 

    // 2. Giả lập lỗi ngẫu nhiên (Optional - dùng để test Error Boundary)
    // if (Math.random() > 0.9) {
    //   return new HttpResponse(null, { status: 500 });
    // }

    const user = db.user.findFirst({ where: { id: { equals: 'user-1' } } });
    return HttpResponse.json(user);
  }),

  // Add thêm các handlers khác sử dụng db.user.findMany(), db.user.update(), etc.
];
```

### 4.3. Setup Environments

**Browser (`src/mocks/browser.ts`):**
```typescript
import { setupWorker } from 'msw/browser';
import { handlers } from './handlers';
export const worker = setupWorker(...handlers);
```

**Node/Server (`src/mocks/node.ts`):**
```typescript
import { setupServer } from 'msw/node';
import { handlers } from './handlers';
export const server = setupServer(...handlers);
```

### 4.4. MSW Provider Chống Flash Content (`src/mocks/MSWProvider.tsx`)

```tsx
'use client';

import { useEffect, useState } from 'react';

export function MSWProvider({ children }: { children: React.ReactNode }) {
  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    const init = async () => {
      if (process.env.NEXT_PUBLIC_API_MOCKING === 'true' && typeof window !== 'undefined') {
        const { worker } = await import('./browser');
        await worker.start({
          onUnhandledRequest: 'bypass',
        });
      }
      setIsReady(true);
    };

    init();
  }, []);

  if (!isReady && process.env.NEXT_PUBLIC_API_MOCKING === 'true') return null;

  return <>{children}</>;
}
```

## � 5. Next.js Server Components Support (Optional)

Để mock hoạt động trong Server Components, tạo file `instrumentation.ts` ở thư mục gốc (`src/` hoặc root):

```typescript
export async function register() {
  if (process.env.NEXT_RUNTIME === 'nodejs' && process.env.NEXT_PUBLIC_API_MOCKING === 'true') {
    const { server } = await import('./mocks/node');
    server.listen();
  }
}
```
*Lưu ý: Bật `experimental.instrumentationHook: true` trong `next.config.js`.*

## ⚙️ 6. Kích hoạt
Thêm vào `.env.local`:
```env
NEXT_PUBLIC_API_MOCKING=true
```

## ✅ Next Steps
1. Chạy `npm install` các packages mới.
2. Tạo các file theo cấu trúc trên (Có thể nhờ Mine hỗ trợ bằng lệnh `/code`).
3. Bọc `MSWProvider` vào `src/app/layout.tsx`.
4. Run app và tận hưởng cảm giác API trả về mượt mà! 💃
