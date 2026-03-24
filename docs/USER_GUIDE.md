# Mine User Guide

Mine là bộ workflow giúp AI làm việc theo quy trình rõ ràng trong dự án phần mềm. Bộ workflow hiện tại chia thành 4 nhóm việc: discovery, implementation, validation, và memory/utilities.

## 1. Dùng workflow nào khi nào

### Ý tưởng mới hoặc dự án mới

```text
/brainstorm -> /requirements -> /plan -> /visualize -> /code -> /test -> /save-brain
```

### Scope nhỏ hoặc MVP đã rõ

```text
/plan -> /visualize -> /code -> /test -> /save-brain
```

### Frontend bị chặn bởi backend

```text
/mock-api -> /code -> /test
```

### Có bug hoặc mất confidence

```text
/test -> /debug -> /code -> /test
```

### Quay lại dự án đang làm dở

```text
/recap -> /next -> /code hoặc /debug hoặc /plan
```

## 2. Danh sách workflow hiện có

### Discovery & Requirements
- `/brainstorm`
- `/requirements`
- `/plan`

### Design & Implementation
- `/visualize`
- `/code`
- `/mock-api`
- `/refactor`

### Validation & Recovery
- `/test`
- `/debug`
- `/audit`
- `/next`

### Memory & Utilities
- `/save-brain`
- `/recap`
- `/customize`
- `/mine-update`

`/customize` và `/mine-update` là workflow tiện ích nên được giữ nhẹ hơn workflow cốt lõi.

## 3. Workflow đã bị loại bỏ

Các workflow sau không còn được hỗ trợ trong Mine:
- `/init`
- `/run`
- `/deploy`
- `/rollback`
- `/cloudflare-tunnel`

Catalog workflow hiện tại được quyết định bởi các file đang có trong thư mục `workflows/`.

## 4. Memory giữa các phiên

Mine dùng 3 file trong `.brain/`:
- `brain.json`: kiến thức ổn định của dự án
- `session.json`: snapshot hiện tại
- `history.json`: handoff giữa các phiên

### Cuối phiên

```text
/save-brain
```

### Đầu phiên mới

```text
/recap
```

Nếu quên `/save-brain`, `/recap` vẫn có thể dựng lại tương đối tốt từ Git, nhưng chất lượng handoff sẽ kém hơn vì thiếu decisions, risks và next steps đã được chốt.
