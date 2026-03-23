# Mine User Guide

Mine là bộ workflow giúp AI làm việc theo quy trình rõ ràng trong dự án phần mềm. Bộ workflow hiện tại tập trung vào 3 nhóm việc: khám phá yêu cầu, triển khai kỹ thuật, và lưu/khôi phục context giữa các phiên làm việc.

## 1. Khi nào dùng workflow nào

### Bắt đầu từ ý tưởng

```text
/brainstorm -> /requirements -> /plan -> /visualize
```

### Bắt đầu từ dự án đang làm dở

```text
/recap -> /code hoặc /debug -> /test -> /save-brain
```

### Khi không biết làm gì tiếp

```text
/next
```

## 2. Danh sách workflow hiện có

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

## 3. Workflow đã bị loại bỏ

Các workflow sau không còn được hỗ trợ trong Mine:
- `/init`
- `/run`
- `/deploy`
- `/rollback`
- `/cloudflare-tunnel`

## 4. Memory giữa các phiên

Mine dùng 3 file trong `.brain/`:
- `brain.json`: kiến thức ổn định của dự án
- `session.json`: snapshot hiện tại
- `history.json`: handoff giữa các phiên

### Cuối ngày

```text
/save-brain
```

### Đầu ngày mới

```text
/recap
```

Nếu quên `/save-brain`, `/recap` vẫn có thể dựng lại tương đối tốt từ Git, nhưng chất lượng handoff sẽ kém hơn vì thiếu decisions và next steps đã được chốt.
