#!/bin/bash
# Mine Installer for Mac/Linux
# Tự động detect Antigravity Global Workflows

REPO_BASE="https://raw.githubusercontent.com/hoangminh46/mine-vibe/main"
REPO_URL="$REPO_BASE/workflows"
WORKFLOWS=(
    "plan.md" "code.md" "visualize.md" "deploy.md"
    "debug.md" "refactor.md" "test.md" "run.md"
    "init.md" "recap.md" "rollback.md" "save_brain.md"
    "audit.md" "cloudflare-tunnel.md" "mine-update.md"
    "brainstorm.md" "next.md" "customize.md" "mock-api.md" "README.md"
)

# Schemas and Templates (v3.3+)
SCHEMAS=(
    "brain.schema.json" "session.schema.json" "preferences.schema.json"
)
TEMPLATES=(
    "brain.example.json" "session.example.json" "preferences.example.json"
)

# Skills
SKILLS=(
    "vercel-react-best-practices"
)

# Detect paths
ANTIGRAVITY_GLOBAL="$HOME/.gemini/antigravity/global_workflows"
SCHEMAS_DIR="$HOME/.gemini/antigravity/schemas"
TEMPLATES_DIR="$HOME/.gemini/antigravity/templates"
GEMINI_MD="$HOME/.gemini/GEMINI.md"
MINE_VERSION_FILE="$HOME/.gemini/mine_version"

# Get version from repo
CURRENT_VERSION=$(curl -s "$REPO_BASE/VERSION" 2>/dev/null || echo "3.4.0")

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║     🚀 Mine - Antigravity Workflow Framework v$CURRENT_VERSION        ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Check if updating
if [ -f "$MINE_VERSION_FILE" ]; then
    OLD_VERSION=$(cat "$MINE_VERSION_FILE")
    echo "📦 Phiên bản hiện tại: $OLD_VERSION"
    echo "📦 Phiên bản mới: $CURRENT_VERSION"
    echo ""
fi

# 1. Cài Global Workflows
mkdir -p "$ANTIGRAVITY_GLOBAL"
echo "✅ Antigravity Global Path: $ANTIGRAVITY_GLOBAL"

echo "⏳ Đang tải workflows..."
success=0
for wf in "${WORKFLOWS[@]}"; do
    if curl -f -s -o "$ANTIGRAVITY_GLOBAL/$wf" "$REPO_URL/$wf"; then
        echo "   ✅ $wf"
        ((success++))
    else
        echo "   ❌ $wf"
    fi
done

# 2. Download Schemas (v3.3+)
mkdir -p "$SCHEMAS_DIR"
echo "⏳ Đang tải schemas..."
for schema in "${SCHEMAS[@]}"; do
    if curl -f -s -o "$SCHEMAS_DIR/$schema" "$REPO_BASE/schemas/$schema"; then
        echo "   ✅ $schema"
        ((success++))
    else
        echo "   ❌ $schema"
    fi
done

# 3. Download Templates (v3.3+)
mkdir -p "$TEMPLATES_DIR"
echo "⏳ Đang tải templates..."
for template in "${TEMPLATES[@]}"; do
    if curl -f -s -o "$TEMPLATES_DIR/$template" "$REPO_BASE/templates/$template"; then
        echo "   ✅ $template"
        ((success++))
    else
        echo "   ❌ $template"
    fi
done

# 4. Install Skills
mkdir -p "$HOME/.gemini/antigravity/skills"
SKILLS_DIR="$HOME/.gemini/antigravity/skills"
echo "⏳ Đang tải skills..."
for skill in "${SKILLS[@]}"; do
    skill_path="$SKILLS_DIR/$skill"
    mkdir -p "$skill_path"
    
    if curl -f -s -o "$skill_path/SKILL.md" "$REPO_BASE/skills/$skill/SKILL.md"; then
        echo "   ✅ Skill: $skill"
        ((success++))
        
        # Optional AGENTS.md for this specific skill
        if [ "$skill" == "vercel-react-best-practices" ]; then
            curl -f -s -o "$skill_path/AGENTS.md" "$REPO_BASE/skills/$skill/AGENTS.md" || true
        fi
    else
        echo "   ❌ Skill: $skill"
    fi
done

# 5. Save version
mkdir -p "$HOME/.gemini"
echo "$CURRENT_VERSION" > "$MINE_VERSION_FILE"
echo "✅ Đã lưu version: $CURRENT_VERSION"

# 5. Update Global Rules
MINE_INSTRUCTIONS='
# Mine - Antigravity Workflow Framework

## 🛡️ GLOBAL CODING STANDARDS (Universal & AI-Optimized)

### 1. Core Philosophy (Tư duy cốt lõi)
- **KISS & YAGNI**: Code đơn giản nhất có thể. Không over-engineer cho những thứ "có thể sẽ cần".
- **DRY**: Logic lặp lại > 2 lần -> Tách hàm.
- **Single Source of Truth**: Dữ liệu/Config chỉ được định nghĩa ở 1 nơi duy nhất.

### 2. Code Quality (Chất lượng mã)
- **Self-Documenting Names**: Tên biến/hàm phải giải thích được nó làm gì (`userHasAccess` > `checkAccess`).
- **One Function, One Job**: Hàm chỉ làm 1 việc duy nhất. Nếu có chữ "And" trong tên hàm -> Tách ra.
- **Commenting**:
  - ❌ KHÔNG comment "Code làm gì" (Code đã tự nói).
  - ✅ CHỈ comment "Tại sao làm thế" (Lý do nghiệp vụ, hack fix, workaround).

### 3. Reliability & Security (Độ tin cậy & Bảo mật)
- **Input Validation**: Validate mọi dữ liệu đầu vào. Không tin tưởng client.
- **Fail Fast & Loud**: Lỗi phải được catch và throw/log ngay, không nuốt lỗi (silently ignore).
- **Secrets Management**: Tuyệt đối KHÔNG hardcode API Keys/Passwords. Dùng `.env`.

### 4. AI-Specific Rules (Dành riêng cho AI)
- **No Hallucinations**: Chỉ dùng thư viện đã có trong `package.json`/`requirements.txt`. Nếu cần mới, PHẢI yêu cầu cài đặt.
- **No Placeholders**: Cấm dùng `// TODO: Implement later` hay `pass`. Code phải hoàn chỉnh và chạy được.
- **Step-by-Step Thinking**: Với logic phức tạp (>10 dòng), hãy comment `# Step X: ...` để giải thích luồng xử lý.

### 5. Technology Agnostic
- Rules này áp dụng cho MỌI ngôn ngữ (JS, Python, Go, Rust...).
- Luôn tuân thủ **Style Guide chuẩn** của ngôn ngữ đó (PEP8 cho Python, Airbnb cho JS, v.v.).

## CRITICAL: Command Recognition
Khi user gõ các lệnh bắt đầu bằng ``/`` dưới đây, đây là Mine WORKFLOW COMMANDS (không phải file path).
Bạn PHẢI đọc file workflow tương ứng và thực hiện theo hướng dẫn trong đó.

## Command Mapping (QUAN TRỌNG):
| Command | Workflow File | Mô tả |
|---------|--------------|-------|
| `/brainstorm` | ~/.gemini/antigravity/global_workflows/brainstorm.md | 💡 Bàn ý tưởng, research thị trường |
| `/plan` | ~/.gemini/antigravity/global_workflows/plan.md | Thiết kế tính năng |
| `/code` | ~/.gemini/antigravity/global_workflows/code.md | Viết code an toàn |
| `/visualize` | ~/.gemini/antigravity/global_workflows/visualize.md | Tạo UI/UX |
| `/debug` | ~/.gemini/antigravity/global_workflows/debug.md | Sửa lỗi sâu |
| `/test` | ~/.gemini/antigravity/global_workflows/test.md | Kiểm thử |
| `/run` | ~/.gemini/antigravity/global_workflows/run.md | Chạy ứng dụng |
| `/deploy` | ~/.gemini/antigravity/global_workflows/deploy.md | Deploy production |
| `/init` | ~/.gemini/antigravity/global_workflows/init.md | Khởi tạo dự án |
| `/recap` | ~/.gemini/antigravity/global_workflows/recap.md | Khôi phục ngữ cảnh |
| `/next` | ~/.gemini/antigravity/global_workflows/next.md | Gợi ý bước tiếp theo |
| `/customize` | ~/.gemini/antigravity/global_workflows/customize.md | ⚙️ Cá nhân hóa AI |
| `/save-brain` | ~/.gemini/antigravity/global_workflows/save_brain.md | Lưu kiến thức |
| `/audit` | ~/.gemini/antigravity/global_workflows/audit.md | Kiểm tra bảo mật |
| `/refactor` | ~/.gemini/antigravity/global_workflows/refactor.md | Tái cấu trúc code |
| `/rollback` | ~/.gemini/antigravity/global_workflows/rollback.md | Rollback deployment |
| `/cloudflare-tunnel` | ~/.gemini/antigravity/global_workflows/cloudflare-tunnel.md | Quản lý tunnel |
| `/mine-update` | ~/.gemini/antigravity/global_workflows/mine-update.md | Cập nhật Mine |
| `/mock-api` | ~/.gemini/antigravity/global_workflows/mock-api.md | 💃 Giả lập Backend API |

## Resource Locations (v3.3+):
- Schemas: ~/.gemini/antigravity/schemas/
- Templates: ~/.gemini/antigravity/templates/

## Hướng dẫn thực hiện:
1. Khi user gõ một trong các commands trên, ĐỌC FILE WORKFLOW tương ứng
2. Thực hiện TỪNG GIAI ĐOẠN trong workflow
3. KHÔNG tự ý bỏ qua bước nào
4. Kết thúc bằng NEXT STEPS menu như trong workflow

## Update Check:
- Mine version được lưu tại: ~/.gemini/mine_version
- Để kiểm tra và cập nhật Mine, user gõ: /mine-update
- Thỉnh thoảng (1 lần/tuần) nhắc user kiểm tra update nếu họ dùng Mine thường xuyên
'

if [ ! -f "$GEMINI_MD" ]; then
    echo "$MINE_INSTRUCTIONS" > "$GEMINI_MD"
    echo "✅ Đã tạo Global Rules (GEMINI.md)"
else
    # Always update GEMINI.md to latest version
    # Remove old Mine section and add new one
    if grep -q "Mine - Antigravity Workflow Framework" "$GEMINI_MD"; then
        # Create temp file without Mine section
        sed '/# Mine - Antigravity Workflow Framework/,/^# [^A]/{ /^# [^A]/!d; }' "$GEMINI_MD" > "$GEMINI_MD.tmp"
        mv "$GEMINI_MD.tmp" "$GEMINI_MD"
    fi
    echo "$MINE_INSTRUCTIONS" >> "$GEMINI_MD"
    echo "✅ Đã cập nhật Global Rules (GEMINI.md)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 HOÀN TẤT! Đã cài $success files vào hệ thống."
echo "📦 Version: $CURRENT_VERSION"
echo ""
echo "📂 Workflows: $ANTIGRAVITY_GLOBAL"
echo "📂 Schemas:   $SCHEMAS_DIR"
echo "📂 Templates: $TEMPLATES_DIR"
echo "📂 Skills:    $SKILLS_DIR"
echo ""
echo "👉 Bạn có thể dùng Mine ở BẤT KỲ project nào ngay lập tức!"
echo "👉 Thử gõ '/plan' để kiểm tra."
echo "👉 Kiểm tra update: '/mine-update'"
echo ""
