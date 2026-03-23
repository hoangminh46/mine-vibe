# Mine Workflows

## Workflow hiện có

### Discovery & Planning
- `/brainstorm`: bàn ý tưởng, clarify scope, research khi cần
- `/requirements`: phân tích yêu cầu, use cases, acceptance criteria
- `/plan`: thiết kế logic, phase, và spec cho tính năng
- `/visualize`: thiết kế UI/UX

### Build & Validate
- `/code`: triển khai code theo spec/phase
- `/test`: kiểm tra logic và test status
- `/debug`: phân tích và sửa lỗi
- `/mock-api`: giả lập backend/API cho frontend
- `/refactor`: cải tổ code an toàn
- `/audit`: kiểm tra chất lượng, bảo mật, rủi ro

### Memory & Guidance
- `/save-brain`: lưu memory theo Git + handoff
- `/recap`: phục hồi context bằng memory + Git
- `/next`: gợi ý bước tiếp theo
- `/customize`: cá nhân hóa hành vi AI
- `/mine-update`: kiểm tra/cập nhật Mine

## Workflow đã bỏ

Repo này không còn duy trì:
- `/init`
- `/run`
- `/deploy`
- `/rollback`
- `/cloudflare-tunnel`

## Memory model

Mine hiện dùng:
- `brain.json`: kiến thức ổn định
- `session.json`: snapshot hiện tại
- `history.json`: handoff xuyên phiên

## Luồng khuyến nghị

### Khởi đầu

```text
/brainstorm -> /requirements -> /plan -> /visualize
```

### Triển khai

```text
/code -> /test -> /debug hoặc /refactor
```

### Kết thúc phiên

```text
/save-brain
```

### Bắt đầu phiên mới

```text
/recap
```
