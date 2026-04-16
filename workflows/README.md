# Mine Workflows

## Overview

Thư mục `workflows/` hiện được tổ chức theo 3 thư mục con:
- `workflows/coding/`: workflow phục vụ discovery, implementation, validation
- `workflows/system/`: workflow phục vụ memory và utility
- `workflows/media/`: workflow tạo tài liệu và nội dung

Tổng thể workflow vẫn chia thành 4 nhóm workflow chính:
- discovery & requirements
- design & implementation
- validation & recovery
- memory & utilities

Các workflow lõi đã được nâng cấp theo hướng:
- rõ scope và context
- bám Git / `.brain/` / plan / spec khi cần
- có quality gates, handoff, và next steps rõ ràng

---

## Workflow Hiện Có

### Discovery & Requirements
- `/brainstorm`: discovery ý tưởng, làm rõ user/problem/outcome/MVP, tạo `docs/BRIEF.md`
- `/requirements`: chuyển brief/nhu cầu thành requirements có thể verify, đủ tốt để bàn giao sang `/plan`
- `/plan`: thiết kế implementation plan, phases, spec, acceptance criteria, definition of done

### Design & Implementation
- `/visualize`: chốt visual direction, layout/states/responsive behavior, tạo `docs/design-specs.md`
- `/code`: triển khai code theo plan/spec/phase, validate theo repo thật
- `/mock-api`: dựng mock API thực dụng cho dev/test, có mode, verification, và anti-drift rules
- `/refactor`: refactor an toàn, giữ behavior, validate theo safety baseline

### Media & Document
- `/essay`: tạo bài tiểu luận học thuật (.docx) theo chuẩn ĐH Giáo Dục — hướng dẫn từng bước, không cần biết code
- `/format`: format file Word (.docx) theo chuẩn học thuật — tự chọn font, cỡ chữ, giãn dòng, lề

### Validation & Recovery
- `/test`: chọn validation phù hợp, kiểm tra acceptance criteria và mức confidence hiện tại
- `/debug`: triage, reproduce, isolate, fix, verify
- `/audit`: audit theo scope, bằng chứng, severity/confidence, rồi handoff sang workflow phù hợp
- `/next`: đọc trạng thái thật của dự án và gợi ý 1 bước tiếp theo ưu tiên nhất

### Memory & Utilities
- `/save-brain`: lưu memory theo Git, session snapshot, và cross-session handoff
- `/recap`: phục hồi context bằng cách đối chiếu memory với Git hiện tại
- `/customize`: cá nhân hóa cách Mine giao tiếp và làm việc
- `/mine-update`: kiểm tra phiên bản Mine và cập nhật khi cần

---

## Workflow Cốt Lõi

Nếu cần nhìn nhanh các workflow "xương sống" của Mine, ưu tiên:
- `/brainstorm`
- `/requirements`
- `/plan`
- `/visualize`
- `/code`
- `/test`
- `/debug`
- `/save-brain`
- `/recap`
- `/next`

Các workflow còn lại là workflow hỗ trợ hoặc workflow tiện ích.

---

## Workflow Đã Bỏ

Repo này không còn duy trì:
- `/init`
- `/run`
- `/deploy`
- `/rollback`
- `/cloudflare-tunnel`

Workflow catalog hiện tại được quyết định bởi các file đang có trong `workflows/coding/` và `workflows/system/`.

---

## Memory Model

Mine hiện dùng 3 lớp memory:
- `brain.json`: kiến thức ổn định của dự án
- `session.json`: snapshot hiện tại của phiên làm việc
- `history.json`: handoff xuyên phiên, neo theo Git

Nguyên tắc:
- Git là nguồn sự thật cho commit history và thay đổi file
- `brain.json` không dùng để lưu local WIP
- `session.json` phản ánh hiện trạng đang làm
- `history.json` dùng để quay lại nhanh vào phiên sau

---

## Luồng Khuyến Nghị

### Ý Tưởng Mới

```text
/brainstorm -> /requirements -> /plan -> /visualize -> /code -> /test -> /save-brain
```

### Scope Nhỏ / MVP Rõ

```text
/plan -> /visualize -> /code -> /test -> /save-brain
```

### Khi Frontend Bị Chặn Bởi Backend

```text
/mock-api -> /code -> /test
```

### Khi Có Lỗi Hoặc Mất Confidence

```text
/test -> /debug -> /code -> /test
```

### Bắt Đầu Phiên Mới

```text
/recap -> /next -> /code hoặc /debug hoặc /plan
```

### Kết Thúc Phiên

```text
/save-brain
```

### Viết Tiểu Luận / Bài Thu Hoạch

```text
/essay -> cung cấp thông tin -> nhận file .docx
```

---

## Ghi Chú

- Không phải workflow nào cũng cần cùng mức "chuẩn hóa". Các workflow tiện ích như `/customize` và `/mine-update` được giữ nhẹ để giảm ma sát sử dụng.
- Các workflow lõi nên được coi là nguồn điều phối chính cho cách Mine làm việc trong repo này.
