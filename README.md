# Mine - Antigravity Workflow Framework v3.5

Mine là bộ workflow cho AI coding trong Antigravity/Cursor. Repo này không phải ứng dụng sản phẩm, mà là tập lệnh, schema và template để AI làm việc theo quy trình thống nhất, có memory theo dự án.

## Mục tiêu

- Chuẩn hóa cách AI brainstorm, phân tích yêu cầu, lên plan, code, test, debug và lưu memory
- Giảm context drift giữa các phiên làm việc
- Dùng Git + `.brain/` để recap lại dự án chính xác hơn

## Workflow còn lại

### Discovery & Planning
- `/brainstorm`
- `/requirements`
- `/plan`
- `/visualize`

### Build & Validate
- `/code`
- `/test`
- `/debug`
- `/mock-api`
- `/refactor`
- `/audit`

### Memory & Guidance
- `/save-brain`
- `/recap`
- `/next`
- `/customize`
- `/mine-update`

## Workflow đã loại bỏ

Các workflow sau không còn được duy trì trong repo này:
- `/init`
- `/run`
- `/deploy`
- `/rollback`
- `/cloudflare-tunnel`

## Memory system

Mine hiện dùng 3 lớp memory:
- `.brain/brain.json`: kiến thức ổn định của dự án
- `.brain/session.json`: snapshot hiện tại của phiên làm việc
- `.brain/history.json`: handoff giữa các phiên, neo theo Git

`/save-brain` sẽ reconcile với Git trước khi lưu. `/recap` sẽ đọc memory rồi đối chiếu lại với Git hiện tại trước khi tóm tắt.

## Cấu trúc repo

- [workflows](/C:/Users/admin/Desktop/AmelaProject/mine-vibe/workflows): workflow Markdown
- [schemas](/C:/Users/admin/Desktop/AmelaProject/mine-vibe/schemas): JSON schema cho memory và preferences
- [templates](/C:/Users/admin/Desktop/AmelaProject/mine-vibe/templates): file mẫu
- [docs](/C:/Users/admin/Desktop/AmelaProject/mine-vibe/docs): tài liệu tổng quan
- [skills](/C:/Users/admin/Desktop/AmelaProject/mine-vibe/skills): skill tham khảo/cài kèm

## Cài đặt

### Windows

```powershell
iex "& { $(irm https://raw.githubusercontent.com/hoangminh46/mine-vibe/main/install.ps1) }"
```

### Mac / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/hoangminh46/mine-vibe/main/install.sh | sh
```

## Luồng dùng khuyến nghị

### Dự án mới hoặc ý tưởng mới

```text
/brainstorm -> /requirements -> /plan -> /visualize -> /code -> /test -> /save-brain
```

### Bắt đầu ngày làm việc mới

```text
/recap -> /code hoặc /debug -> /test -> /save-brain
```

### Khi bị kẹt

```text
/next hoặc /debug
```

## Tài liệu

- [User Guide](/C:/Users/admin/Desktop/AmelaProject/mine-vibe/docs/USER_GUIDE.md)
- [Workflow Overview](/C:/Users/admin/Desktop/AmelaProject/mine-vibe/workflows/README.md)
- [System Architecture](/C:/Users/admin/Desktop/AmelaProject/mine-vibe/docs/architecture/system_overview.md)
