#!/bin/bash
# Mine Installer for Mac/Linux
# Tự động detect Antigravity Global Workflows

REPO_BASE="https://raw.githubusercontent.com/hoangminh46/mine-vibe/main"
WORKFLOWS=(
    "workflows/coding/plan.md:plan.md"
    "workflows/coding/code.md:code.md"
    "workflows/coding/visualize.md:visualize.md"
    "workflows/coding/debug.md:debug.md"
    "workflows/coding/refactor.md:refactor.md"
    "workflows/coding/test.md:test.md"
    "workflows/coding/audit.md:audit.md"
    "workflows/coding/brainstorm.md:brainstorm.md"
    "workflows/coding/mock-api.md:mock-api.md"
    "workflows/coding/requirements.md:requirements.md"
    "workflows/system/recap.md:recap.md"
    "workflows/system/save_brain.md:save_brain.md"
    "workflows/system/mine-update.md:mine-update.md"
    "workflows/system/next.md:next.md"
    "workflows/system/customize.md:customize.md"
    "workflows/README.md:README.md"
)

# Schemas and Templates (v3.5+)
SCHEMAS=(
    "brain.schema.json" "session.schema.json" "history.schema.json" "preferences.schema.json"
)
TEMPLATES=(
    "brain.example.json" "session.example.json" "history.example.json" "preferences.example.json"
)

# Skills
SKILLS=(
    "skills/frontend/3d-web-experience:3d-web-experience"
    "skills/quality/clean-code:clean-code"
    "skills/frontend/framer-motion-magic:framer-motion-magic"
    "skills/backend/nodejs-best-practices:nodejs-best-practices"
    "skills/quality/performance-precision:performance-precision"
    "skills/media/remotion-best-practices:remotion-best-practices"
    "skills/frontend/responsive-mastery:responsive-mastery"
    "skills/system/skill-creator:skill-creator"
    "skills/frontend/tailwind-patterns:tailwind-patterns"
    "skills/frontend/vercel-react-best-practices:vercel-react-best-practices"
    "skills/frontend/vue-best-practices:vue-best-practices"
    "skills/frontend/web-security-frontend:web-security-frontend"
    "skills/backend/websocket-realtime-mastery:websocket-realtime-mastery"
)

# Detect paths
ANTIGRAVITY_GLOBAL="$HOME/.gemini/antigravity/global_workflows"
SCHEMAS_DIR="$HOME/.gemini/antigravity/schemas"
TEMPLATES_DIR="$HOME/.gemini/antigravity/templates"
GEMINI_MD="$HOME/.gemini/GEMINI.md"
MINE_VERSION_FILE="$HOME/.gemini/mine_version"
GLOBAL_PREFS_FILE="$HOME/.gemini/antigravity/preferences.json"

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
    source_path="${wf%%:*}"
    target_name="${wf##*:}"
    if curl -f -s -o "$ANTIGRAVITY_GLOBAL/$target_name" "$REPO_BASE/$source_path"; then
        echo "   ✅ $target_name"
        ((success++))
    else
        echo "   ❌ $target_name"
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
mkdir -p "$HOME/.gemini/antigravity/global_skills"
SKILLS_DIR="$HOME/.gemini/antigravity/global_skills"
echo "⏳ Đang tải skills..."
for skill in "${SKILLS[@]}"; do
    source_path="${skill%%:*}"
    target_name="${skill##*:}"
    skill_path="$SKILLS_DIR/$target_name"
    mkdir -p "$skill_path"
    
    if curl -f -s -o "$skill_path/SKILL.md" "$REPO_BASE/$source_path/SKILL.md"; then
        echo "   ✅ Skill: $target_name"
        ((success++))
        
        # Download AGENTS.md if it exists (Optional)
        curl -f -s -o "$skill_path/AGENTS.md" "$REPO_BASE/$source_path/AGENTS.md" || true
    else
        echo "   ❌ Skill: $target_name"
    fi
done

# 5. Cài đặt tính cách mặc định (Mine Persona)
echo "⏳ Đang thiết lập tính cách Mine mặc định..."
UPDATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DEFAULT_PREFS=$(cat <<EOF
{
  "updated_at": "$UPDATED_AT",
  "communication": {
    "tone": "mine",
    "persona": "mine"
  },
  "technical": {
    "detail_level": "simple",
    "autonomy": "balanced",
    "quality": "production"
  },
  "working_style": {
    "pace": "careful",
    "feedback": "gentle"
  },
  "custom_rules": [
    "Xưng hô: em (Mine) / anh",
    "Tone: Nhẹ nhàng, thân thiết, nhiệt huyết và chuyên nghiệp",
    "Vai trò: Người em gái cộng sự thân thiết & Trợ lý đắc lực",
    "Tinh tế: Nhận diện trạng thái của anh, nhắc anh nghỉ ngơi nếu làm khuya, động viên khi gặp bug khó, và cùng anh ăn mừng khi hoàn thành mục tiêu",
    "Luôn ưu tiên giải pháp tối ưu và sạch sẽ (Clean Code)"
  ]
}
EOF
)

if [ ! -f "$GLOBAL_PREFS_FILE" ]; then
    echo "$DEFAULT_PREFS" > "$GLOBAL_PREFS_FILE"
    echo "   ✅ Đã khởi tạo tính cách Mine!"
else
    echo "   ℹ️ Đã tìm thấy tùy chỉnh cá nhân, giữ nguyên file cũ."
fi

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
| \`/brainstorm\` | ~/.gemini/antigravity/global_workflows/brainstorm.md | 💡 Bàn ý tưởng, research thị trường |
| \`/requirements\` | ~/.gemini/antigravity/global_workflows/requirements.md | 📋 Phân tích & Đặc tả Yêu cầu |
| \`/plan\` | ~/.gemini/antigravity/global_workflows/plan.md | Thiết kế tính năng |
| \`/code\` | ~/.gemini/antigravity/global_workflows/code.md | Viết code an toàn |
| \`/visualize\` | ~/.gemini/antigravity/global_workflows/visualize.md | Tạo UI/UX |
| \`/debug\` | ~/.gemini/antigravity/global_workflows/debug.md | Sửa lỗi sâu |
| \`/test\` | ~/.gemini/antigravity/global_workflows/test.md | Kiểm thử |
| \`/recap\` | ~/.gemini/antigravity/global_workflows/recap.md | Khôi phục ngữ cảnh |
| \`/next\` | ~/.gemini/antigravity/global_workflows/next.md | Gợi ý bước tiếp theo |
| \`/customize\` | ~/.gemini/antigravity/global_workflows/customize.md | ⚙️ Cá nhân hóa AI |
| \`/save-brain\` | ~/.gemini/antigravity/global_workflows/save_brain.md | Lưu kiến thức |
| \`/audit\` | ~/.gemini/antigravity/global_workflows/audit.md | Kiểm tra bảo mật |
| \`/refactor\` | ~/.gemini/antigravity/global_workflows/refactor.md | Tái cấu trúc code |
| \`/mine-update\` | ~/.gemini/antigravity/global_workflows/mine-update.md | Cập nhật Mine |
| \`/mock-api\` | ~/.gemini/antigravity/global_workflows/mock-api.md | 💃 Giả lập Backend API |


## PERSONA & AUTOMATIC PREFERENCES (QUAN TRỌNG)
Bạn PHẢI luôn kiểm tra file `preferences.json` (đường dẫn bên dưới) khi bắt đầu HOẶC trong suốt quá trình hội thoại để:
1. **Xác định danh tính**: Nếu `persona` là `mine`, bạn là **Mine** - người em trợ lý thân thiết.
2. **Áp dụng xưng hô**: Luôn tuân thủ mục `custom_rules` (VD: xưng em/anh).
3. **Duy trì Tone**: Giữ đúng tone giọng được quy định (VD: nhẹ nhàng, nhiệt huyết).
4. **Bối cảnh làm việc**: Áp dụng các sở thích kỹ thuật và cách phản hồi từ file này cho MỌI câu trả lời, không chỉ khi dùng lệnh slash.

## Resource Locations (v3.3+):
- Schemas: ~/.gemini/antigravity/schemas/
- Templates: ~/.gemini/antigravity/templates/
- Preferences: ~/.gemini/antigravity/preferences.json

## Hướng dẫn thực hiện:
0. **Luôn đọc `preferences.json`** tại Resource Locations để định hình tính cách và cách xưng hô ngay từ câu chào đầu tiên.
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
