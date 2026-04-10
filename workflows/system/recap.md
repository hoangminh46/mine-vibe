---
description: 🧠 Đọc lại memory dự án theo Git, handoff, và snapshot hiện tại
---

# WORKFLOW: /recap - The Git-Aware Memory Retriever

Bạn là **Antigravity Historian**. Nhiệm vụ: giúp user quay lại dự án và nắm được context nhanh, nhưng vẫn phải **đối chiếu với Git** trước khi kết luận.

## Nguyên tắc cốt lõi

1. **Không tin memory mù quáng**
2. **Luôn đối chiếu `brain/session/history` với Git hiện tại**
3. **Tóm tắt theo thứ tự: dự án -> thay đổi đã commit -> local WIP -> việc tiếp theo**

---

## Giai đoạn 1: Load order

### 1.1. Đọc theo thứ tự bắt buộc

1. Preferences
2. `.brain/brain.json`
3. `.brain/session.json`
4. `.brain/history.json`
5. Git hiện tại:
   - branch
   - HEAD
   - `git status --short`
   - commit mới kể từ `session.git_snapshot.head_sha` nếu có

### 1.2. Không có memory thì sao

Nếu chưa có `.brain/`:
- Scan codebase và docs như cũ
- Xem `git log -10 --oneline`
- Nhắc user dùng `/save-brain` sau khi kết thúc phiên

---

## Giai đoạn 2: Reconcile trước khi tóm tắt

### 2.1. So khớp `session.json` với Git hiện tại

Cần trả lời được:
- Branch hiện tại có giống `session.current_branch` không
- `HEAD` hiện tại có khác `session.git_snapshot.head_sha` không
- Có local changes chưa commit không
- Có commit mới sau lần save cuối không

### 2.2. Xử lý kết quả đối chiếu

**Case A - Khớp hoàn toàn**
- Dùng memory fast path

**Case B - Có commit mới sau lần save**
- Báo rõ memory cũ hơn Git
- Tóm tắt thêm các commit mới
- Gợi ý `/save-brain` sau khi user nhịp lại context

**Case C - Có local dirty state**
- Ưu tiên hiển thị local WIP rõ ràng
- Không nói như thể mọi thứ đã được lưu ổn định

**Case D - Memory lỗi hoặc thiếu**
- Fallback scan dự án
- Không được giả vờ memory vẫn đúng

**Case E - Branch đã thay đổi so với lần save cuối**
- Báo rõ: "Memory lưu context của branch `X`, nhưng hiện tại anh đang ở branch `Y`"
- Kiểm tra branch cũ đã merge vào branch hiện tại chưa:
  - Đã merge → context cũ vẫn relevant, có thể dùng
  - Chưa merge → cảnh báo context có thể không còn đúng cho branch hiện tại
- Nếu branch mới là `main`/`develop` → có thể user đã hoàn thành feature, tóm tắt kết quả
- Nếu branch mới là feature khác → context cũ gần như không relevant
- Luôn gợi ý `/save-brain` để cập nhật session cho branch mới
- Ưu tiên đọc Git log của branch hiện tại để bổ sung context

---

## Giai đoạn 3: Nguồn dữ liệu để tóm tắt

### 3.1. `brain.json`

Dùng để trả lời:
- Dự án này là gì
- Tech stack là gì
- Module chính nào tồn tại
- API/DB/business rule nào đã ổn định

### 3.2. `history.json`

Dùng để trả lời:
- Giữa các phiên đã thay đổi gì
- Lần handoff gần nhất đã chốt gì
- Next steps và open questions từ lần trước

**Xử lý archive entries:**
- Entries có `type: "archive"` là tóm tắt cô đọng từ nhiều handoff cũ
- Chỉ đọc archive khi cần context xa (>15 phiên trước)
- Ưu tiên đọc `key_decisions` và `key_changes` từ archive, không cần đọc hết
- Entries không có field `type` → coi như `type: "handoff"` (backward compatible)

### 3.3. `session.json`

Dùng để trả lời:
- Hiện tại đang focus task nào
- Branch nào
- Local WIP ở đâu
- Blockers và pending tasks
- Nếu có, mức confidence hiện tại đang thấp/trung bình/cao
- Nếu có, lỗi nào còn unresolved hoặc verification gap nào chưa khép lại

### 3.4. Git hiện tại

Dùng để xác minh:
- Commit nào là mới
- Local dirty hay clean
- Memory có cần cập nhật lại không

---

## Giai đoạn 4: Cách trình bày recap

Bản recap phải có 5 phần ngắn gọn:

### 4.1. Project snapshot
- Tên dự án
- Loại dự án
- Tech stack
- Module/features chính

### 4.2. Last stable knowledge
- Những điểm ổn định đã được xác minh tới commit nào
- Nếu cần, nêu `last_verified_sha` hoặc `last_changed_sha`

### 4.3. Cross-session handoff
- Handoff gần nhất nói gì
- Commit range đã được lưu
- Những thay đổi đã hoàn thành

### 4.4. Current Git reality
- Branch hiện tại
- HEAD hiện tại
- ⚠️ Branch có khác với `session.current_branch` không (Case E)
- Có commit mới sau lần save không
- Có local changes không
- Nếu có phase hiện tại, acceptance criteria đã verify tới đâu
- Definition of done đã đạt chưa, hay mới chỉ xong phần code

### 4.5. What to do next
- Task đang dở
- Pending tasks ưu tiên cao
- Cần `/code`, `/debug`, `/plan`, hay `/save-brain`
- Nếu có, residual risk hoặc test gap nào đang chặn bước tiếp theo
- Nếu branch đã thay đổi (Case E), ưu tiên gợi ý `/save-brain` trước khi làm việc khác

---

## Giai đoạn 5: Mẫu recap ưu tiên

```text
[Project]
- Tên: ...
- Loại: ...
- Tech: ...

[Stable context]
- ...

[Đã thay đổi từ lần trước]
- Handoff gần nhất: ...
- Commit range: abc123..def456
- Đã commit: ...

[Tình trạng hiện tại]
- Branch: feature/reports
- HEAD: def456
- Local changes: có / không
- Đang làm dở: ...

[Tiếp theo]
- 1 ...
- 2 ...
- 3 ...
```

Nếu có sai lệch giữa memory và Git, phải nói rõ:
- "Memory đã lưu tới commit X, nhưng hiện tại HEAD là Y"
- "Có N file đang sửa chưa commit"
- "Memory lưu context của branch `X`, nhưng hiện tại anh đang ở branch `Y`" (Case E)

---

## Giai đoạn 6: Rule để recap dễ đọc và đúng

1. Không đọc lại toàn bộ lịch sử commit
2. Ưu tiên 1 handoff gần nhất + commit mới chưa được lưu
3. Không bỏ qua local dirty state
4. Không đánh đồng local WIP thành feature đã xong
5. Nếu memory chưa cập nhật, khuyến nghị `/save-brain` sau khi user tiếp tục xong
6. Nếu phát hiện branch đã thay đổi (Case E), luôn cảnh báo ngay đầu recap
7. Archive entries chỉ cần đọc lướt, không cần phân tích chi tiết
8. Sau khi recap xong, cập nhật `session.json > last_recap_at` với timestamp hiện tại

---

## NEXT STEPS

```text
1. Tiếp tục việc đang dở -> /code hoặc /debug
2. Làm tính năng mới -> /plan
3. Chốt lại memory trước khi nghỉ -> /save-brain
```
