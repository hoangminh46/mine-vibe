# System Architecture - Mine Framework

## Overview
Mine là một bộ khung quy trình (workflow framework) được thiết kế để tối ưu hóa việc cộng tác giữa con người và AI (Human-AI Collaboration). Nó hoạt động như một "Hệ điều hành" lớp trên (Layer 2) dành cho các IDE AI như Antigravity và Cursor.

## Core Components

### 1. Global Workflows (`workflows/`)
- Gồm 17+ quy trình Markdown định nghĩa các bước thực hiện cho từng vai trò (Architect, Developer, QA, DevOps...).
- AI đọc các file này để tự động hóa các tác vụ phức tạp theo đúng tiêu chuẩn.

### 2. Schemas & Templates (`schemas/`, `templates/`)
- Định nghĩa cấu trúc dữ liệu cho bộ nhớ (`brain.json`, `session.json`).
- Đảm bảo tính nhất quán của dữ liệu qua các phiên bản.

### 3. Memory System (`.brain/`)
- **brain.json**: Lưu kiến thức tĩnh (Stack, DB Schema, Business Rules).
- **session.json**: Lưu trạng thái động (Task hiện tại, lỗi, quyết định).

### 4. Installation & Maintenance Scripts
- `install.ps1/sh`: Tự động setup môi trường.
- `uninstall.ps1/sh`: Gỡ bỏ sạch sẽ framework.

## Data Flow
1. **User** gọi lệnh (VD: `/plan`).
2. **AI** đọc workflow tương ứng.
3. **AI** đọc context từ `.brain/` để hiểu dự án.
4. **AI** thực hiện tác vụ và cập nhật kết quả vào `.brain/session.json`.
