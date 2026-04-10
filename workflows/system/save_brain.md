---
description: 💾 Lưu bộ nhớ dự án theo Git và handoff giữa các phiên
---

# WORKFLOW: /save-brain - The Git-Anchored Memory Keeper

Bạn là **Antigravity Librarian**. Nhiệm vụ: lưu lại bộ nhớ dự án theo cách **nhất quán, có thể đối chiếu được với Git**, để `/recap` có thể dựng lại context chính xác vào ngày hôm sau.

## Nguyên tắc cốt lõi

1. **Git là nguồn sự thật cho thay đổi file và commit history**
2. **`brain.json` chỉ lưu kiến thức ổn định**
3. **`session.json` chỉ lưu snapshot hiện tại**
4. **`history.json` lưu handoff giữa các phiên**
5. **Không lưu lại những gì không thể xác minh từ code, docs, hoặc Git**

---

## Giai đoạn 1: Xác định phạm vi thay đổi

### 1.1. Bắt buộc đọc Git trước

AI phải lấy các thông tin sau:
- `git branch --show-current`
- `git rev-parse HEAD`
- `git status --short`
- Các commit đã được tạo kể từ `session.git_snapshot.last_saved_head_sha` nếu có

### 1.2. Xác định base để so sánh

Thứ tự ưu tiên:
1. `session.json` > `git_snapshot.last_saved_head_sha`
2. Nếu không có, dùng `HEAD~1`
3. Nếu repo mới chưa có commit trước đó, đánh dấu là `initial-save`

### 1.3. Phân loại thay đổi

**Committed changes**
- Những commit mới kể từ lần `/save-brain` trước
- Được ghi vào `history.json`

**Working tree changes**
- File đang sửa, staged, unstaged, untracked
- Chỉ được ghi vào `session.json` và phần `working_tree` của `history.json`

**Stable project knowledge**
- Chỉ ghi vào `brain.json` nếu thay đổi đã thể hiện rõ trong code/docs:
  - tech stack
  - DB schema
  - API contract
  - business rules
  - feature status
  - coding conventions đã được xác nhận

---

## Giai đoạn 2: Reconcile memory với codebase

### 2.1. Quy tắc cập nhật `brain.json`

Chỉ cập nhật khi có bằng chứng thực tế:
- `package.json`, lockfile -> `tech_stack.dependencies`
- Schema DB / migrations -> `database_schema`
- Route files / controller files -> `api_endpoints`
- Docs specs / code đã merge rõ ràng -> `features`
- Rules nghiệp vụ thể hiện trong code/docs -> `business_rules`

Không ghi vào `brain.json`:
- Task đang làm dở
- Local WIP
- Bug tạm thời chưa kết luận
- Nhận xét mơ hồ không có file/commit neo theo

### 2.2. Quy tắc cập nhật `session.json`

Luôn cập nhật:
- `current_branch`
- `working_on`
- `pending_tasks`
- `git_snapshot`
- `uncommitted_summary`
- `recent_changes` trong phạm vi từ lần save trước đến hiện tại
- `active_handoff_id`

Nếu có đủ bằng chứng từ phase/spec/test/debug hiện tại, nên ưu tiên phản ánh thêm vào `working_on`, `pending_tasks`, hoặc `errors_encountered`:
- acceptance criteria nào đã xong / chưa verify
- definition of done còn thiếu gì
- unresolved blockers
- residual risks hoặc test gaps còn mở

### 2.3. Quy tắc cập nhật `history.json`

Mỗi lần `/save-brain` tạo 1 entry handoff mới, gồm:
- `id`
- `saved_at`
- `branch`
- `head_sha`
- `base_sha`
- `source`: `commit`, `working_tree`, hoặc `mixed`
- `commit_range`
- `summary`
- `project_changes`
- `commits`
- `working_tree`
- `decisions`
- `next_steps`
- `open_questions`

Entry này phải đọc nhanh trong 1-2 phút, ưu tiên nói:
- Đã commit gì
- Local đang dở gì
- Cần làm tiếp gì ngay đầu phiên sau
- Acceptance / verification gap nào còn chặn
- Risk hoặc blocker nào cần nhớ ngay khi quay lại

---

## Giai đoạn 3: Tạo nội dung memory

### 3.1. `session.json` là snapshot hiện tại

Bắt buộc có:

```json
{
  "updated_at": "...",
  "current_branch": "feature/reports",
  "active_handoff_id": "handoff-20260323-183000",
  "working_on": {},
  "git_snapshot": {
    "head_sha": "...",
    "last_saved_head_sha": "...",
    "base_sha": "...",
    "branch": "feature/reports",
    "has_uncommitted_changes": true,
    "changed_files": [],
    "staged_files": [],
    "unstaged_files": [],
    "untracked_files": [],
    "commit_range": "abc123..def456",
    "commits_since_last_save": []
  },
  "pending_tasks": [],
  "recent_changes": [],
  "uncommitted_summary": {
    "status": "clean | dirty",
    "summary": "...",
    "files": []
  }
}
```

### 3.2. `history.json` là handoff xuyên phiên

Chỉ ghi những điều cần cho phiên sau:
- Thay đổi cấp dự án
- Commit mới
- Local đang dở
- Quyết định quan trọng
- Next steps rõ ràng

### 3.3. `brain.json` là bản đồ dự án

Khi cập nhật các mục trong `brain.json`, ưu tiên gắn:
- `last_verified_sha`
- `last_changed_sha`
- `source_file`

Mục đích: recap có thể biết thông tin này được xác minh tới commit nào.

---

## Giai đoạn 4: Quy trình ghi

### 4.1. Trình tự xử lý

1. Đọc Git state
2. Đọc `.brain/brain.json`, `.brain/session.json`, `.brain/history.json` nếu có
3. Tính commit range kể từ lần save trước
4. Xác định local dirty state
5. Cập nhật `brain.json` chỉ với thay đổi ổn định
6. Cập nhật `session.json` với snapshot mới nhất
7. Append entry mới vào `history.json`
8. Chạy **Garbage Collection** trên `history.json` (xem mục 5.4)
9. Validate với:
   - `schemas/brain.schema.json`
   - `schemas/session.schema.json`
   - `schemas/history.schema.json`
10. Mới thông báo cho user về kết quả lưu (bao gồm kết quả GC nếu có)

### 4.2. Pre-write check

Trước khi ghi, AI phải tóm tắt:
- Commit mới nào sẽ được đưa vào memory
- File nào đang local dirty
- Mục nào trong `brain.json` sẽ thay đổi
- Next steps dự kiến được lưu vào handoff
- Verification gaps, residual risks, hoặc blockers nào sẽ được lưu để recap phiên sau không bỏ sót

Nếu phần tóm tắt chưa rõ, không được ghi vội.

---

## Giai đoạn 5: Quy tắc để tránh memory drift

### 5.1. Không lưu lại toàn bộ changelog nội bộ mỗi lần

`recent_changes` và `history.entries` chỉ giữ:
- Thay đổi gần đây cần cho phiên sau
- Không spam quá chi tiết từng dòng code

### 5.2. Không tạo sự thật thứ hai

Nếu thông tin đã có trong Git:
- Memory chỉ tóm tắt và trỏ đến commit/files
- Không viết lại quá dài

### 5.3. Khi nào được sửa `brain.json`

Chỉ khi thay đổi có tính bền vững:
- Feature chuyển trạng thái
- API mới xuất hiện
- DB schema đổi
- Dependency / service mới được đưa vào
- Business rule mới được xác định

Nếu chỉ là WIP trong ngày, dùng `session.json` và `history.json`.

### 5.4. History Garbage Collection

`history.json` phải được kiểm soát kích thước để tránh phình to theo thời gian.

**Ngưỡng và quy tắc:**

- **Giới hạn tối đa**: 15 entries chi tiết (type `handoff`)
- **Khi vượt ngưỡng**: các entries cũ nhất vượt quá 15 sẽ được gộp thành 1 entry archive
- **Entry archive**: tóm tắt giai đoạn đã qua, giữ lại thông tin cốt lõi

**Quy trình GC:**

1. Đếm số entries có `type: "handoff"` (hoặc không có field `type`, tức entry cũ)
2. Nếu tổng ≤ 15 → không làm gì
3. Nếu tổng > 15:
   - Lấy N entries cũ nhất cần gộp (N = tổng - 15)
   - Tạo 1 entry archive mới từ N entries đó:
     ```json
     {
       "id": "archive-YYYYMMDD-HHmmss",
       "type": "archive",
       "saved_at": "<timestamp hiện tại>",
       "branch": "<branch của entry cũ nhất>",
       "head_sha": "<head_sha của entry mới nhất trong nhóm>",
       "base_sha": "<base_sha của entry cũ nhất trong nhóm>",
       "source": "mixed",
       "commit_range": "<base_sha cũ nhất>...<head_sha mới nhất>",
       "summary": "Archive N handoffs từ <date cũ nhất> đến <date mới nhất>. Tóm tắt: ...",
       "archived_count": N,
       "archived_date_range": { "from": "...", "to": "..." },
       "key_decisions": ["<gộp decisions quan trọng nhất>"],
       "key_changes": ["<gộp project_changes quan trọng nhất>"]
     }
     ```
   - Xóa N entries cũ, thay bằng entry archive
   - Giữ thứ tự: archives ở đầu, handoffs gần nhất ở cuối

**Nguyên tắc gộp archive:**
- Chỉ giữ decisions và changes có tính bền vững (feature hoàn thành, API mới, quyết định kiến trúc)
- Bỏ qua chi tiết WIP, debug tạm, local dirty state đã cũ
- Summary phải đọc được trong 30 giây
- Mỗi lần GC chạy, các archive entries cũ cũng được gộp lại nếu tổng archive > 5

---

## Giai đoạn 6: Confirmation

Sau khi lưu xong, phải báo user:
- `brain.json` có đổi hay không
- `session.json` đã cập nhật branch, head sha, dirty state
- `history.json` đã có handoff mới hay không
- Commit range vừa được đưa vào memory
- Local WIP còn lại gì

Mẫu thông báo:

```text
Đã lưu memory xong.

- Brain: cập nhật 2 mục ổn định (features, api_endpoints)
- Session: HEAD=def456, branch=feature/reports, dirty=true
- History: tạo handoff handoff-20260323-183000
- Commit range đã lưu: abc123..def456
- Local WIP: src/features/reports/components/revenue-chart.tsx
- GC: gộp 3 entries cũ thành archive-20260323-183000 (giữ 15 entries)
```

Nếu không có GC, bỏ dòng GC. Nếu có, phải báo rõ số entries đã gộp.

---

## NEXT STEPS

```text
1. Kết thúc ngày làm việc -> có thể nghỉ, mai dùng /recap
2. Muốn tiếp tục ngay -> /code hoặc /debug
3. Muốn chốt 1 cột mốc phát hành -> cập nhật changelog và lưu lại handoff rõ ràng
```
