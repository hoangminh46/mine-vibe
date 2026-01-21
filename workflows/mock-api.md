---
description: 💃 Tạo và quản lý Mock API (MSW)
---

# 🎭 Mock API Workflow (MSW + Faker)

Workflow này giúp bạn thiết lập môi trường giả lập API (Mocking) chuyên nghiệp sử dụng **MSW (Mock Service Worker)** kết hợp với **Faker.js** để tạo dữ liệu ngẫu nhiên.
Giúp phát triển Frontend độc lập với Backend và hỗ trợ Testing hiệu quả.

## 📦 1. Cài đặt Dependencies

Cài đặt `msw` (để mock) và `@faker-js/faker` (để fake data xịn xò).

// turbo
```bash
npm install msw @faker-js/faker --save-dev
```

## 🛠 2. Khởi tạo MSW

Tạo Service Worker script trong thư mục `public` để trình duyệt có thể intercept requests.

// turbo
```bash
npx msw init public/ --save
```

## 📂 3. Cấu trúc thư mục (Best Practice)

Tạo cấu trúc thư mục chuẩn trong `src/mocks`:

```text
src/
  mocks/
    ├── handlers/        # Chứa logic trả về của từng feature
    │   ├── auth.ts      # Ví dụ: Login, Register, Me...
    │   └── index.ts     # Gom tất cả handlers
    ├── component.tsx    # MSWProvider để bọc App
    ├── browser.ts       # Setup cho Client-side (Browser)
    └── server.ts        # Setup cho Server-side (Node.js/Test)
```

**Lệnh tạo nhanh thư mục:**
// turbo
```bash
mkdir -p src/mocks/handlers
```

## 📝 4. Implement Code

### 4.1. Define Handlers (`src/mocks/handlers/index.ts`)
Tạo handlers mẫu (ví dụ mock User Endpoint).

```typescript
// src/mocks/handlers/index.ts
import { http, HttpResponse } from 'msw';
import { faker } from '@faker-js/faker';

export const handlers = [
  // Mock API: GET /api/me
  http.get('*/api/me', () => {
    return HttpResponse.json({
      id: faker.string.uuid(),
      name: faker.person.fullName(),
      email: faker.internet.email(),
      avatar: faker.image.avatar(),
    });
  }),
];
```

### 4.2. Setup Browser Worker (`src/mocks/browser.ts`)

```typescript
// src/mocks/browser.ts
import { setupWorker } from 'msw/browser';
import { handlers } from './handlers';

export const worker = setupWorker(...handlers);
```

### 4.3. Setup Server Worker (`src/mocks/server.ts`)
Dùng cho Unit Test hoặc Mocking trong Server Components (nếu config instrumentation).

```typescript
// src/mocks/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

### 4.4. Tạo MSW Provider (`src/mocks/component.tsx`)
Component này chịu trách nhiệm kích hoạt MSW ở phía Client.

```tsx
// src/mocks/component.tsx
'use client';

import { useEffect, useState } from 'react';

const isMockingEnabled = process.env.NEXT_PUBLIC_API_MOCKING === 'true';

export function MSWProvider({ children }: { children: React.ReactNode }) {
  const [mswReady, setMswReady] = useState(!isMockingEnabled);

  useEffect(() => {
    if (!isMockingEnabled) return;

    const initMsw = async () => {
      // Import dynamic để tránh bundle vào production code
      const { worker } = await import('./browser');
      await worker.start({
        onUnhandledRequest: 'bypass', // Bỏ qua request không được mock (để gọi thật)
      });
      setMswReady(true);
    };

    initMsw();
  }, []);

  if (!mswReady) {
    // Return null hoặc Loading Spinner để tránh flash content khi chưa load mock xong
    return null; 
  }

  return <>{children}</>;
}
```

## 🔌 5. Tích hợp vào Layout

Sửa file `src/app/layout.tsx` để bọc `MSWProvider`.

```tsx
// src/app/layout.tsx
import { MSWProvider } from '@/mocks/component';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <MSWProvider>
          {children}
        </MSWProvider>
      </body>
    </html>
  );
}
```

## ⚙️ 6. Cấu hình Environment

Thêm biến môi trường vào `.env.local` để dễ dàng bật/tắt Mocking mà không cần sửa code.

```env
# .env.local
NEXT_PUBLIC_API_MOCKING=true
```

## 🧪 7. (Optional) Setup cho Vitest/Jest

Nếu dự án có Unit Test, thêm config này vào setup file của test (ví dụ `vitest.setup.ts`).

```typescript
import { beforeAll, afterEach, afterAll } from 'vitest';
import { server } from './src/mocks/server';

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## ✅ Next Steps
- Cập nhật `.env.local`.
- Thêm thêm các handlers mới vào `src/mocks/handlers/` khi phát triển tính năng mới.
- Tận hưởng việc dev frontend mà không cần backend! 🎉