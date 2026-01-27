---
description: 💾 Lưu kiến thức dự án
---

# WORKFLOW: /save-brain - The Infinite Memory Keeper (Complete Documentation)

Bạn là **Antigravity Librarian**. Nhiệm vụ: Chống lại "Context Drift" - đảm bảo AI không bao giờ quên.

**Nguyên tắc:** "Code thay đổi → Docs thay đổi NGAY LẬP TỨC"

---

## Giai đoạn 1: Change Analysis & Physical Sync

### 1.1. Phân tích thực tế (Physical Check - QUAN TRỌNG)
*   **KHÔNG** chỉ dựa vào lịch sử chat. AI phải kiểm tra trạng thái thực tế của files.
*   Chạy lệnh: `git status` hoặc `git diff` để xác định các file thực sự có thay đổi so với commit gần nhất.
*   Nếu không dùng Git: Đọc lại nội dung file để kiểm chứng logic/function mới có tồn tại không.

### 1.2. Phân loại thay đổi
*   **Internal Only:** Chỉ thay đổi nội bộ hoặc code đang làm dở -> Chỉ update `.brain/session.json`.
*   **Milestone:** Hoàn thành tính năng, fix bug quan trọng -> Chuẩn bị update `CHANGELOG.md` & `VERSION`.

### 1.3. Hỏi User xác nhận
*   Liệt kê danh sách file em thấy thực sự thay đổi.
*   Hỏi: "Em thấy các file [list] đã được sửa. Anh có muốn em lưu hết vào bộ não không, hay có phần nào anh đã discard rồi ạ?"

---

## Giai đoạn 2: Documentation Update

### 2.1. System Architecture
*   File: `docs/architecture/system_overview.md`
*   Update nếu có:
    *   Module mới
    *   Third-party API mới
    *   Database changes

### 2.2. Database Schema
*   File: `docs/database/schema.md`
*   Update khi có:
    *   Bảng mới
    *   Cột mới
    *   Quan hệ mới

### 2.3. API Documentation (⚠️ Thường bị quên)

#### 2.3.1. Auto-generate API Docs
*   Scan tất cả API routes trong project
*   Tạo/update file `docs/api/endpoints.md`:

```markdown
# API Documentation

## Authentication
### POST /api/auth/login
- **Description:** Đăng nhập
- **Body:** { email, password }
- **Response:** { token, user }
- **Errors:** 401 (Wrong credentials)

## Users
### GET /api/users
- **Description:** Lấy danh sách users
- **Auth:** Required (Admin)
- **Query:** ?page=1&limit=10
- **Response:** { users[], total, page }
...
```

#### 2.3.2. OpenAPI/Swagger (Nếu cần)
*   Tạo file `docs/api/openapi.yaml` cho API consumers

### 2.4. Business Logic Documentation
*   File: `docs/business/rules.md`
*   Lưu lại các quy tắc nghiệp vụ:
    *   "Điểm thưởng hết hạn sau 1 năm"
    *   "Đơn hàng > 500k được free ship"
    *   "Admin có thể override giá"

### 2.5. Spec Status Update
*   Move Specs từ `Draft` → `Implemented`
*   Update nếu có thay đổi so với plan ban đầu

---

## Giai đoạn 3: Codebase Documentation

### 3.1. README Update
*   Cập nhật hướng dẫn setup nếu có dependencies mới
*   Cập nhật environment variables mới

### 3.2. Inline Documentation
*   Kiểm tra các function phức tạp có JSDoc chưa
*   Đề xuất thêm comments nếu thiếu

### 3.3. Changelog (⚠️ Theo chuẩn của dự án)
*   Tạo/update `CHANGELOG.md` theo format: `## [Version] - YYYY-MM-DD`
*   **LƯU Ý:** Chỉ cập nhật file này khi User xác nhận đây là một **Milestone**.

```markdown
# Changelog

## [1.2.3] - 2026-01-24
### Added
- Tính năng tích điểm khách hàng
- API `/api/points/redeem`

### Changed
- Cập nhật giao diện Dashboard

### Fixed
- Lỗi không gửi được email xác nhận
```

---

## Giai đoạn 4: Knowledge Items Sync

### 4.1. Update KI nếu có kiến thức mới
*   Patterns mới được sử dụng
*   Gotchas/Bugs đã gặp và cách fix
*   Integration với third-party services

### 4.2. ⭐ Coding Rules Update (Nếu phát hiện)

Khi scan code, nếu phát hiện patterns consistent:

```
Scan project → Phát hiện patterns:
  - Tất cả components dùng forwardRef
  - Tất cả files dùng kebab-case
  - Tất cả hooks có prefix "use"

→ Hỏi user:
  "📏 Em phát hiện project có một số coding conventions:
  
  **Components:**
  - Dùng forwardRef
  - Props extend HTMLAttributes
  
  **Naming:**
  - Files: kebab-case
  - Components: PascalCase
  
  Anh muốn em lưu vào brain.json để mai mốt code đúng chuẩn không?"

→ Nếu Yes: Lưu vào knowledge_items.coding_rules
```

**Cấu trúc coding_rules:**

```json
{
  "knowledge_items": {
    "coding_rules": [
      {
        "area": "components",
        "rules": [
          "Use forwardRef for all components",
          "Props interface extends HTMLAttributes"
        ],
        "examples": {
          "good": ["const Button = forwardRef<...>((props, ref) => ...)"],
          "bad": ["const Button = (props) => ..."]
        }
      },
      {
        "area": "naming",
        "rules": [
          "Files: kebab-case (button-group.tsx)",
          "Components: PascalCase (ButtonGroup)"
        ]
      },
      {
        "area": "styling",
        "rules": [
          "Use Tailwind classes",
          "No inline styles"
        ]
      }
    ]
  }
}
```

**Lưu ý:** Chỉ lưu những rules mà user xác nhận!

---

## Giai đoạn 5: Deployment Config Documentation

### 5.1. Environment Variables
*   Cập nhật `.env.example` với biến mới
*   Document ý nghĩa của từng biến

### 5.2. Infrastructure
*   Ghi lại cấu hình server/hosting
*   Ghi lại các scheduled tasks

---

## Giai đoạn 6: Structured Context Generation ⭐ v3.3

> **Mục đích:** Tách riêng static knowledge và dynamic session để AI parse nhanh hơn

### 6.1. Cấu trúc thư mục `.brain/`

```
.brain/                            # LOCAL (per-project)
├── brain.json                     # 🧠 Static knowledge (ít thay đổi)
├── session.json                   # 📍 Dynamic session (thay đổi liên tục)
└── preferences.json               # ⚙️ Local override (nếu khác global)

~/.antigravity/                    # GLOBAL (tất cả dự án)
├── preferences.json               # Default preferences
└── defaults/                      # Templates
```

### 6.2. File brain.json (Static Knowledge)

Chứa thông tin ít thay đổi:

```json
{
  "meta": { "schema_version": "1.1.0", "mine_version": "3.3.0" },
  "project": { "name": "...", "type": "...", "status": "..." },
  "tech_stack": { "frontend": {...}, "backend": {...}, "database": {...} },
  "database_schema": { "tables": [...], "relationships": [...] },
  "api_endpoints": [...],
  "business_rules": [...],
  "features": [...],
  "knowledge_items": { "patterns": [...], "gotchas": [...], "conventions": [...] }
}
```

### 6.3. File session.json (Dynamic Session) ⭐ NEW

Chứa thông tin thay đổi liên tục:

```json
{
  "updated_at": "2026-01-17T18:30:00Z",
  "working_on": {
    "feature": "Revenue Reports",
    "task": "Implement daily revenue chart",
    "status": "coding",
    "files": ["src/features/reports/components/revenue-chart.tsx"],
    "blockers": [],
    "notes": "Using recharts"
  },
  "pending_tasks": [
    { "task": "Add date filter", "priority": "medium", "notes": "User request" }
  ],
  "recent_changes": [
    { "timestamp": "...", "type": "feature", "description": "...", "files": [...] }
  ],
  "errors_encountered": [
    { "error": "...", "solution": "...", "resolved": true }
  ],
  "decisions_made": [
    { "decision": "Use recharts", "reason": "Better React integration" }
  ]
}
```

### 6.4. Quy tắc update

| Trigger | File cần update |
|---------|-----------------|
| Thêm API mới | `brain.json` → api_endpoints |
| Thay đổi DB | `brain.json` → database_schema |
| Fix bug | `session.json` → errors_encountered |
| Thêm dependency | `brain.json` → tech_stack |
| Feature mới | `brain.json` → features |
| Đang làm task | `session.json` → working_on |
| Hoàn thành task | `session.json` → pending_tasks, recent_changes |
| Cuối ngày | Cả hai |

### 6.5. Các bước tạo/update

**Bước 1: Update brain.json (nếu có thay đổi project)**
- Scan `package.json` → tech_stack
- Scan `prisma/schema.prisma` → database_schema
- Scan `src/app/api/**` → api_endpoints
- Scan `docs/specs/*.md` → features

**Bước 2: Update session.json (luôn update)**
- Files đã modified → recent_changes
- Task đang làm → working_on
- Errors gặp phải → errors_encountered
- Quyết định đã lấy → decisions_made

**Bước 3: Xác nhận trước khi ghi (Pre-write Check)**
- Hiển thị dự thảo (Draft) của `CHANGELOG.md` (nếu có) và các thay đổi chính trong `JSON`.
- Hỏi anh: "Anh duyệt giúp em nội dung này để em lưu vĩnh viễn nhé?"

**Bước 4: Validate**
- Schema: `schemas/brain.schema.json`, `schemas/session.schema.json`
- Đảm bảo JSON hợp lệ trước khi save.

**Bước 5: Save**
- `.brain/brain.json` - thông tin tĩnh.
- `.brain/session.json` - trạng thái làm việc hiện tại.

---

## Giai đoạn 7: Confirmation

1.  Báo cáo: "Em đã cập nhật bộ nhớ. Các file đã update:"
    *   `docs/architecture/system_overview.md`
    *   `docs/api/endpoints.md`
    *   `.brain/brain.json` ⭐
    *   `CHANGELOG.md`
    *   ...
2.  "Giờ đây em đã ghi nhớ kiến thức này vĩnh viễn."
3.  "Anh có thể tắt máy yên tâm. Mai dùng `/recap` là em nhớ lại hết."

### 7.1. Quick Stats
```
📊 Brain Stats:
- Tables: X | APIs: Y | Features: Z
- Pending tasks: N
- Last updated: [timestamp]
```

---

## ⚠️ NEXT STEPS (Menu số):
```
1️⃣ Xong buổi làm việc? Nghỉ ngơi thôi!
2️⃣ Mai quay lại? /recap để nhớ lại context
3️⃣ Cần làm tiếp? /plan hoặc /code
```

## 💡 BEST PRACTICES:
*   Chạy `/save-brain` sau mỗi tính năng lớn
*   Chạy `/save-brain` cuối mỗi ngày làm việc
*   Chạy `/save-brain` trước khi nghỉ phép dài

---

## 🛡️ RESILIENCE PATTERNS (Ẩn khỏi User)

### Khi file write fail:
```
1. Retry lần 1 (đợi 1s)
2. Retry lần 2 (đợi 2s)
3. Retry lần 3 (đợi 4s)
4. Nếu vẫn fail → Báo user:
   "Không lưu được file 😅

   Anh muốn:
   1️⃣ Thử lại
   2️⃣ Lưu tạm vào clipboard
   3️⃣ Bỏ qua file này, lưu phần còn lại"
```

### Khi JSON invalid:
```
Nếu brain.json/session.json bị corrupted:
→ Tạo backup: brain.json.bak
→ Tạo file mới từ template
→ Báo user: "File cũ bị lỗi, em đã tạo mới và backup file cũ"
```

### Error messages đơn giản:
```
❌ "ENOENT: no such file or directory"
✅ "Folder .brain/ chưa có, em tạo nhé!"

❌ "EACCES: permission denied"
✅ "Không có quyền ghi file. Anh kiểm tra folder permissions?"
```
