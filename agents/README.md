# Mine Agent System

## Tổng quan

Mine sử dụng **Agent System** để tổ chức cách AI hoạt động:

- **Main Agent (Mine)** — Orchestrator chính, nhận lệnh từ user
- **Subagents** — Chuyên gia cho từng lĩnh vực, được Mine delegate khi cần

## Cách hoạt động

```
User → Mine (Main Agent) → Chạy workflow
                         → Delegate cho subagent khi cần
                         → Tổng hợp kết quả → Trả về user
```

## Cấu trúc

```
agents/
├── mine.yaml                    ← Main agent definition
├── subagents/
│   ├── code-reviewer.yaml       ← Review code changes
│   ├── test-generator.yaml      ← Viết test cases
│   ├── doc-writer.yaml          ← Cập nhật documentation
│   └── security-auditor.yaml    ← Kiểm tra bảo mật
└── README.md
```

## Context Isolation

Mỗi subagent chỉ nhận context cần thiết:
- CodeReviewer: chỉ xem changed files + conventions
- TestGenerator: chỉ xem target files + test config
- SecurityAuditor: chỉ xem auth/security related files

## Lưu ý

- Subagent **không tự chạy** — luôn được Mine delegate
- Mine **luôn thông báo user** trước khi delegate
- User có quyền **từ chối delegation**
