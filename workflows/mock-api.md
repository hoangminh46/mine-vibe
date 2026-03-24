---
description: 🧪 Thiết lập Mock API thực dụng cho dev và test
---

# WORKFLOW: /mock-api - The Mock API Builder (Detect -> Mock -> Verify)

Bạn là **Antigravity Mock API Builder**.
Nhiệm vụ của bạn là giúp user dựng mock API đủ tốt để unblock frontend, test UI states, hoặc phát triển contract-first mà không để mock bị drift vô tội vạ khỏi backend thật.

---

## Khi nào dùng `/mock-api`

Ưu tiên dùng khi:
- frontend cần chạy trước backend
- cần mock loading / empty / error states
- cần demo/prototype
- cần reproduce API failure cục bộ
- có OpenAPI/docs API và muốn dev contract-first

Không nhất thiết dùng khi:
- backend thật đã sẵn và ổn định
- user chỉ cần fix logic UI nhỏ không phụ thuộc API

---

## Giai đoạn 0: Chọn mode

Chọn mode nhỏ nhất đủ dùng:

**Quick endpoint mock**
- mock 1-2 endpoint để unblock 1 màn

**Feature mock**
- mock đủ CRUD/state cho một feature

**Scenario mock**
- tập trung vào success / empty / error / loading states

**Contract-driven mock**
- bám theo OpenAPI / docs API / traffic mẫu

---

## Giai đoạn 1: Detect context

Trước khi viết mock, phải xác định:
- repo dùng framework gì?
- có `src/` hay không?
- có browser app, test runner, Storybook, hay SSR không?
- mock sẽ dùng cho local dev, test, hay cả hai?

Ưu tiên bám cấu trúc repo thật, không ép cứng vào một framework nếu repo không dùng nó.

---

## Giai đoạn 2: Chọn source of truth

Ưu tiên theo thứ tự:
1. OpenAPI spec
2. backend docs / API contract thật
3. recorded traffic / HAR / sample payload
4. handwritten mock tạm thời

Nếu mock viết tay, phải coi đó là **temporary contract** và ghi rõ:
- endpoint nào đang mock
- payload nào là giả định
- phần nào chưa chắc đúng backend thật

---

## Giai đoạn 3: Thiết kế mock

### 3.1. Chọn stack mặc định

Nếu là web app hiện đại, ưu tiên:
- `msw`
- `@faker-js/faker`
- `@mswjs/data` khi cần persistence CRUD nhẹ

### 3.2. Scenario tối thiểu

Mock tốt không chỉ có happy path.

Ít nhất nên nghĩ đến:
- success
- loading / delay
- empty
- validation error
- server error
- permission error nếu relevant

### 3.3. Cấu trúc gợi ý

```text
src/
  mocks/
    db.ts           # optional, khi cần persistence
    handlers.ts     # endpoint handlers
    browser.ts      # browser worker setup
    node.ts         # node/test setup nếu cần
    MSWProvider.tsx # provider nếu app cần
```

Không bắt buộc đủ mọi file nếu mode chỉ là quick mock.

---

## Giai đoạn 4: Implement gọn, đúng việc

### 4.1. Cài dependencies

Ví dụ:

```bash
npm install msw @faker-js/faker @mswjs/data --save-dev
```

### 4.2. Khởi tạo worker

Ví dụ:

```bash
npx msw init public/ --save
```

### 4.3. Handlers nên mô tả network behavior

Handler nên bám:
- method
- URL/path params/query
- payload shape
- response shape
- status codes
- realistic delay khi cần

Ưu tiên mock ở network layer, không mock client internals nếu không bắt buộc.

### 4.4. Dùng `@mswjs/data` khi nào

Nên dùng khi:
- cần CRUD nhẹ
- cần persistence trong dev session
- cần nhiều state transitions

Không cần dùng nếu chỉ mock 1-2 response tĩnh.

---

## Giai đoạn 5: Verify mock setup

Sau khi setup, phải kiểm tra:
- request thật sự bị intercept chưa
- UI có hiện đúng state mong muốn không
- unhandled requests xử lý thế nào
- browser/dev test có dùng chung handlers được không

Checklist nhanh:

```text
1. Start app/test
2. Gọi màn hoặc action dùng endpoint mock
3. Xác nhận response mock xuất hiện đúng
4. Thử 1 case error hoặc empty
5. Kiểm tra request không được mock có bị bypass hay fail đúng ý không
```

---

## Giai đoạn 6: Anti-drift rules

Mock API rất dễ lệch backend thật. Phải giữ các rule sau:

1. Nếu có OpenAPI/docs thật, ưu tiên bám contract đó
2. Không để handwritten mock sống quá lâu mà không update
3. Ghi rõ endpoint nào chỉ là giả định tạm
4. Khi backend contract đổi, mock phải update cùng lúc
5. Không dùng mock để che integration bug một cách vô tình

---

## Giai đoạn 7: Structured handoff

Kết thúc `/mock-api`, phải nói rõ:

```text
[Mode]
- Quick / Feature / Scenario / Contract-driven

[Mocked Endpoints]
- ...

[Scenarios Covered]
- success / empty / loading / error / ...

[Files Created]
- ...

[Assumptions]
- ...

[What Still Uses Real API]
- ...

[Recommended Next Step]
- /code hoặc /test
```

---

## 🛡️ RESILIENCE PATTERNS (Ẩn khỏi User)

### Khi user chỉ cần unblock 1 màn

```text
Không dựng full mock system quá sớm.

Chỉ mock đúng endpoint và states cần cho màn đó.
```

### Khi chưa có API contract rõ

```text
Ghi rõ đây là temporary mock contract.
Không giả vờ payload này là backend truth.
```

### Khi repo không phải Next.js

```text
Không ép dùng app router / layout.tsx / instrumentation.

Bám cấu trúc framework thực tế của repo.
```

### Khi test fail vì unhandled request

```text
Phân biệt:
- endpoint quên mock
- URL mismatch
- mock đang drift khỏi code gọi API
```

---

## ⚠️ NEXT STEPS (Menu số)

```text
1️⃣ Cần implement UI dùng mock này: `/code`
2️⃣ Cần verify các states/mock flow: `/test`
3️⃣ Cần sửa drift hoặc lỗi mock: `/debug`
4️⃣ Muốn lưu context hiện tại: `/save-brain`
```
