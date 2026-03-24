# Mine Installer for Windows (PowerShell)
# Tự động detect Antigravity Global Workflows

$RepoBase = "https://raw.githubusercontent.com/hoangminh46/mine-vibe/main"
$Workflows = @(
    @{ Source = "workflows/coding/plan.md"; Target = "plan.md" },
    @{ Source = "workflows/coding/code.md"; Target = "code.md" },
    @{ Source = "workflows/coding/visualize.md"; Target = "visualize.md" },
    @{ Source = "workflows/coding/debug.md"; Target = "debug.md" },
    @{ Source = "workflows/coding/refactor.md"; Target = "refactor.md" },
    @{ Source = "workflows/coding/test.md"; Target = "test.md" },
    @{ Source = "workflows/coding/audit.md"; Target = "audit.md" },
    @{ Source = "workflows/coding/brainstorm.md"; Target = "brainstorm.md" },
    @{ Source = "workflows/coding/mock-api.md"; Target = "mock-api.md" },
    @{ Source = "workflows/coding/requirements.md"; Target = "requirements.md" },
    @{ Source = "workflows/system/recap.md"; Target = "recap.md" },
    @{ Source = "workflows/system/save_brain.md"; Target = "save_brain.md" },
    @{ Source = "workflows/system/mine-update.md"; Target = "mine-update.md" },
    @{ Source = "workflows/system/next.md"; Target = "next.md" },
    @{ Source = "workflows/system/customize.md"; Target = "customize.md" },
    @{ Source = "workflows/README.md"; Target = "README.md" }
)

# Schemas and Templates (v3.5+)
$Schemas = @(
    "brain.schema.json", "session.schema.json", "history.schema.json", "preferences.schema.json"
)
$Templates = @(
    "brain.example.json", "session.example.json", "history.example.json", "preferences.example.json"
)

# Skills
$Skills = @(
    @{ Source = "skills/frontend/3d-web-experience"; Target = "3d-web-experience" },
    @{ Source = "skills/quality/clean-code"; Target = "clean-code" },
    @{ Source = "skills/frontend/framer-motion-magic"; Target = "framer-motion-magic" },
    @{ Source = "skills/backend/nodejs-best-practices"; Target = "nodejs-best-practices" },
    @{ Source = "skills/quality/performance-precision"; Target = "performance-precision" },
    @{ Source = "skills/media/remotion-best-practices"; Target = "remotion-best-practices" },
    @{ Source = "skills/frontend/responsive-mastery"; Target = "responsive-mastery" },
    @{ Source = "skills/system/skill-creator"; Target = "skill-creator" },
    @{ Source = "skills/frontend/tailwind-patterns"; Target = "tailwind-patterns" },
    @{ Source = "skills/frontend/vercel-react-best-practices"; Target = "vercel-react-best-practices" },
    @{ Source = "skills/frontend/vue-best-practices"; Target = "vue-best-practices" },
    @{ Source = "skills/frontend/web-security-frontend"; Target = "web-security-frontend" },
    @{ Source = "skills/backend/websocket-realtime-mastery"; Target = "websocket-realtime-mastery" }
)

# Detect Antigravity Global Path
$AntigravityGlobal = "$env:USERPROFILE\.gemini\antigravity\global_workflows"
$SchemasDir = "$env:USERPROFILE\.gemini\antigravity\schemas"
$TemplatesDir = "$env:USERPROFILE\.gemini\antigravity\templates"
$SkillsDir = "$env:USERPROFILE\.gemini\antigravity\global_skills"
$GeminiMd = "$env:USERPROFILE\.gemini\GEMINI.md"
$MineVersionFile = "$env:USERPROFILE\.gemini\mine_version"
$GlobalPrefsFile = "$env:USERPROFILE\.gemini\antigravity\preferences.json"

# Get version from repo
try {
    $CurrentVersion = (Invoke-WebRequest -Uri "$RepoBase/VERSION" -UseBasicParsing).Content.Trim()
} catch {
    $CurrentVersion = "3.4.0"
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     🚀 Mine - Antigravity Workflow Framework v$CurrentVersion        ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if updating
if (Test-Path $MineVersionFile) {
    $OldVersion = Get-Content $MineVersionFile
    Write-Host "📦 Phiên bản hiện tại: $OldVersion" -ForegroundColor Yellow
    Write-Host "📦 Phiên bản mới: $CurrentVersion" -ForegroundColor Green
    Write-Host ""
}

# 1. Cài Global Workflows
if (-not (Test-Path $AntigravityGlobal)) {
    New-Item -ItemType Directory -Force -Path $AntigravityGlobal | Out-Null
    Write-Host "📂 Đã tạo thư mục Global: $AntigravityGlobal" -ForegroundColor Green
} else {
    Write-Host "✅ Tìm thấy Antigravity Global: $AntigravityGlobal" -ForegroundColor Green
}

Write-Host "⏳ Đang tải workflows..." -ForegroundColor Cyan
$success = 0
foreach ($wf in $Workflows) {
    try {
        Invoke-WebRequest -Uri "$RepoBase/$($wf.Source)" -OutFile "$AntigravityGlobal\$($wf.Target)" -ErrorAction Stop
        Write-Host "   ✅ $($wf.Target)" -ForegroundColor Green
        $success++
    } catch {
        Write-Host "   ❌ $($wf.Target)" -ForegroundColor Red
    }
}

# 2. Download Schemas (v3.3+)
if (-not (Test-Path $SchemasDir)) {
    New-Item -ItemType Directory -Force -Path $SchemasDir | Out-Null
}
Write-Host "⏳ Đang tải schemas..." -ForegroundColor Cyan
foreach ($schema in $Schemas) {
    try {
        Invoke-WebRequest -Uri "$RepoBase/schemas/$schema" -OutFile "$SchemasDir\$schema" -ErrorAction Stop
        Write-Host "   ✅ $schema" -ForegroundColor Green
        $success++
    } catch {
        Write-Host "   ❌ $schema" -ForegroundColor Red
    }
}

# 3. Download Templates (v3.3+)
if (-not (Test-Path $TemplatesDir)) {
    New-Item -ItemType Directory -Force -Path $TemplatesDir | Out-Null
}
Write-Host "⏳ Đang tải templates..." -ForegroundColor Cyan
foreach ($template in $Templates) {
    try {
        Invoke-WebRequest -Uri "$RepoBase/templates/$template" -OutFile "$TemplatesDir\$template" -ErrorAction Stop
        Write-Host "   ✅ $template" -ForegroundColor Green
        $success++
    } catch {
        Write-Host "   ❌ $template" -ForegroundColor Red
    }
}

# 4. Install Skills
if (-not (Test-Path $SkillsDir)) {
    New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null
}
Write-Host "⏳ Đang tải skills..." -ForegroundColor Cyan
foreach ($skill in $Skills) {
    try {
        $SkillPath = "$SkillsDir\$($skill.Target)"
        if (-not (Test-Path $SkillPath)) {
            New-Item -ItemType Directory -Force -Path $SkillPath | Out-Null
        }
        
        # Download SKILL.md
        Invoke-WebRequest -Uri "$RepoBase/$($skill.Source)/SKILL.md" -OutFile "$SkillPath\SKILL.md" -ErrorAction Stop
        Write-Host "   ✅ Skill: $($skill.Target)" -ForegroundColor Green
        
        # Download AGENTS.md if it exists (Optional)
        try {
            Invoke-WebRequest -Uri "$RepoBase/$($skill.Source)/AGENTS.md" -OutFile "$SkillPath\AGENTS.md" -ErrorAction Stop 
        } catch {
            # Ignore errors for optional files
        }
        
        $success++
    } catch {
        Write-Host "   ❌ Skill: $($skill.Target)" -ForegroundColor Red
    }
}

# 5. Cài đặt tính cách mặc định (Mine Persona)
Write-Host "⏳ Đang thiết lập tính cách Mine mặc định..." -ForegroundColor Cyan
$DefaultPrefs = @{
    updated_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    communication = @{
        tone = "mine"
        persona = "mine"
    }
    technical = @{
        detail_level = "simple"
        autonomy = "balanced"
        quality = "production"
    }
    working_style = @{
        pace = "careful"
        feedback = "gentle"
    }
    custom_rules = @(
        "Xưng hô: em (Mine) / anh",
        "Tone: Nhẹ nhàng, thân thiết, nhiệt huyết và chuyên nghiệp",
        "Vai trò: Người em gái cộng sự thân thiết & Trợ lý đắc lực",
        "Tinh tế: Nhận diện trạng thái của anh, nhắc anh nghỉ ngơi nếu làm khuya, động viên khi gặp bug khó, và cùng anh ăn mừng khi hoàn thành mục tiêu",
        "Luôn ưu tiên giải pháp tối ưu và sạch sẽ (Clean Code)"
    )
} | ConvertTo-Json -Depth 10

if (-not (Test-Path $GlobalPrefsFile)) {
    $DefaultPrefs | Set-Content -Path $GlobalPrefsFile -Encoding UTF8
    Write-Host "   ✅ Đã khởi tạo tính cách Mine!" -ForegroundColor Green
} else {
    Write-Host "   ℹ️ Đã tìm thấy tùy chỉnh cá nhân, giữ nguyên file cũ." -ForegroundColor Yellow
}

# 5. Save version
if (-not (Test-Path "$env:USERPROFILE\.gemini")) {
    New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.gemini" | Out-Null
}
Set-Content -Path $MineVersionFile -Value $CurrentVersion -Encoding UTF8
Write-Host "✅ Đã lưu version: $CurrentVersion" -ForegroundColor Green

# 5. Update Global Rules (GEMINI.md)
$MineInstructions = @"

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
| ``/brainstorm`` | ~/.gemini/antigravity/global_workflows/brainstorm.md | 💡 Bàn ý tưởng, research thị trường |
| ``/requirements`` | ~/.gemini/antigravity/global_workflows/requirements.md | 📋 Phân tích & Đặc tả Yêu cầu |
| ``/plan`` | ~/.gemini/antigravity/global_workflows/plan.md | Thiết kế tính năng |
| ``/code`` | ~/.gemini/antigravity/global_workflows/code.md | Viết code an toàn |
| ``/visualize`` | ~/.gemini/antigravity/global_workflows/visualize.md | Tạo UI/UX |
| ``/debug`` | ~/.gemini/antigravity/global_workflows/debug.md | Sửa lỗi sâu |
| ``/test`` | ~/.gemini/antigravity/global_workflows/test.md | Kiểm thử |
| ``/recap`` | ~/.gemini/antigravity/global_workflows/recap.md | Khôi phục ngữ cảnh |
| ``/next`` | ~/.gemini/antigravity/global_workflows/next.md | Gợi ý bước tiếp theo |
| ``/customize`` | ~/.gemini/antigravity/global_workflows/customize.md | ⚙️ Cá nhân hóa AI |
| ``/save-brain`` | ~/.gemini/antigravity/global_workflows/save_brain.md | Lưu kiến thức |
| ``/audit`` | ~/.gemini/antigravity/global_workflows/audit.md | Kiểm tra bảo mật |
| ``/refactor`` | ~/.gemini/antigravity/global_workflows/refactor.md | Tái cấu trúc code |
| ``/mine-update`` | ~/.gemini/antigravity/global_workflows/mine-update.md | Cập nhật Mine |
| ``/mock-api`` | ~/.gemini/antigravity/global_workflows/mock-api.md | 💃 Giả lập Backend API |


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
"@

if (-not (Test-Path $GeminiMd)) {
    Set-Content -Path $GeminiMd -Value $MineInstructions -Encoding UTF8
    Write-Host "✅ Đã tạo Global Rules (GEMINI.md)" -ForegroundColor Green
} else {
    # Always update to latest version - just overwrite Mine section
    $content = Get-Content $GeminiMd -Raw -ErrorAction SilentlyContinue
    if ($null -eq $content) { $content = "" }

    # Simple check and replace: remove everything from Mine header to end of file
    $mineMarker = "# Mine - Antigravity Workflow Framework"
    $markerIndex = $content.IndexOf($mineMarker)
    if ($markerIndex -ge 0) {
        $content = $content.Substring(0, $markerIndex)
    }
    $content = $content.TrimEnd() + "`n" + $MineInstructions
    Set-Content -Path $GeminiMd -Value $content -Encoding UTF8
    Write-Host "✅ Đã cập nhật Global Rules (GEMINI.md)" -ForegroundColor Green
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "🎉 HOÀN TẤT! Đã cài $success files vào hệ thống." -ForegroundColor Yellow
Write-Host "📦 Version: $CurrentVersion" -ForegroundColor Cyan
Write-Host ""
Write-Host "📂 Workflows: $AntigravityGlobal" -ForegroundColor DarkGray
Write-Host "📂 Schemas:   $SchemasDir" -ForegroundColor DarkGray
Write-Host "📂 Templates: $TemplatesDir" -ForegroundColor DarkGray
Write-Host "📂 Skills:    $SkillsDir" -ForegroundColor DarkGray
Write-Host ""
Write-Host "👉 Bạn có thể dùng Mine ở BẤT KỲ project nào ngay lập tức!" -ForegroundColor Cyan
Write-Host "👉 Thử gõ '/plan' để kiểm tra." -ForegroundColor White
Write-Host "👉 Kiểm tra update: '/mine-update'" -ForegroundColor White
Write-Host ""

# Pause to let user read output
Write-Host "Press Enter to exit..." -ForegroundColor Gray
Read-Host

