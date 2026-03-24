# Workflow Flowchart

## Nhóm workflow hiện tại

```text
Discovery & Requirements
/brainstorm -> /requirements -> /plan

Design & Implementation
/visualize -> /code
/mock-api -> /code
/refactor

Validation & Recovery
/test -> /debug -> /code -> /test
/audit
/next

Memory & Utilities
/save-brain <-> /recap
/customize
/mine-update
```

## Flow khuyến nghị

### Ý tưởng mới

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

### Quay lại làm việc

```text
/recap -> /next -> /code hoặc /debug hoặc /plan
```

## Đã loại bỏ

```text
/init
/run
/deploy
/rollback
/cloudflare-tunnel
```
