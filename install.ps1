# Mine Installer for Windows (PowerShell)
# Tự động detect Antigravity Global Workflows

$RepoBase = "https://raw.githubusercontent.com/hoangminh46/mine-vibe/main"
$RepoUrl = "$RepoBase/workflows"
$Workflows = @(
    "plan.md", "code.md", "visualize.md", "deploy.md",
    "debug.md", "refactor.md", "test.md", "run.md",
    "init.md", "recap.md", "rollback.md", "save_brain.md",
    "audit.md", "cloudflare-tunnel.md", "mine-update.md",
    "brainstorm.md", "next.md", "customize.md", "mock-api.md", "README.md"
)

# Schemas and Templates (v3.3+)
$Schemas = @(
    "brain.schema.json", "session.schema.json", "preferences.schema.json"
)
$Templates = @(
    "brain.example.json", "session.example.json", "preferences.example.json"
)

# Skills
$Skills = @(
    "vercel-react-best-practices"
)

# Detect Antigravity Global Path
$AntigravityGlobal = "$env:USERPROFILE\.gemini\antigravity\global_workflows"
$SchemasDir = "$env:USERPROFILE\.gemini\antigravity\schemas"
$TemplatesDir = "$env:USERPROFILE\.gemini\antigravity\templates"
$SkillsDir = "$env:USERPROFILE\.gemini\antigravity\global_skills"
$GeminiMd = "$env:USERPROFILE\.gemini\GEMINI.md"
$MineVersionFile = "$env:USERPROFILE\.gemini\mine_version"

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
        Invoke-WebRequest -Uri "$RepoUrl/$wf" -OutFile "$AntigravityGlobal\$wf" -ErrorAction Stop
        Write-Host "   ✅ $wf" -ForegroundColor Green
        $success++
    } catch {
        Write-Host "   ❌ $wf" -ForegroundColor Red
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
        $SkillPath = "$SkillsDir\$skill"
        if (-not (Test-Path $SkillPath)) {
            New-Item -ItemType Directory -Force -Path $SkillPath | Out-Null
        }
        
        # Download SKILL.md
        Invoke-WebRequest -Uri "$RepoBase/skills/$skill/SKILL.md" -OutFile "$SkillPath\SKILL.md" -ErrorAction Stop
        Write-Host "   ✅ Skill: $skill" -ForegroundColor Green
        
        # Optional: Download AGENTS.md if it exists for vercel-react-best-practices
        if ($skill -eq "vercel-react-best-practices") {
             Invoke-WebRequest -Uri "$RepoBase/skills/$skill/AGENTS.md" -OutFile "$SkillPath\AGENTS.md" -ErrorAction SilentlyContinue
        }
        
        $success++
    } catch {
        Write-Host "   ❌ Skill: $skill" -ForegroundColor Red
    }
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
| ``/plan`` | ~/.gemini/antigravity/global_workflows/plan.md | Thiết kế tính năng |
| ``/code`` | ~/.gemini/antigravity/global_workflows/code.md | Viết code an toàn |
| ``/visualize`` | ~/.gemini/antigravity/global_workflows/visualize.md | Tạo UI/UX |
| ``/debug`` | ~/.gemini/antigravity/global_workflows/debug.md | Sửa lỗi sâu |
| ``/test`` | ~/.gemini/antigravity/global_workflows/test.md | Kiểm thử |
| ``/run`` | ~/.gemini/antigravity/global_workflows/run.md | Chạy ứng dụng |
| ``/deploy`` | ~/.gemini/antigravity/global_workflows/deploy.md | Deploy production |
| ``/init`` | ~/.gemini/antigravity/global_workflows/init.md | Khởi tạo dự án |
| ``/recap`` | ~/.gemini/antigravity/global_workflows/recap.md | Khôi phục ngữ cảnh |
| ``/next`` | ~/.gemini/antigravity/global_workflows/next.md | Gợi ý bước tiếp theo |
| ``/customize`` | ~/.gemini/antigravity/global_workflows/customize.md | ⚙️ Cá nhân hóa AI |
| ``/save-brain`` | ~/.gemini/antigravity/global_workflows/save_brain.md | Lưu kiến thức |
| ``/audit`` | ~/.gemini/antigravity/global_workflows/audit.md | Kiểm tra bảo mật |
| ``/refactor`` | ~/.gemini/antigravity/global_workflows/refactor.md | Tái cấu trúc code |
| ``/rollback`` | ~/.gemini/antigravity/global_workflows/rollback.md | Rollback deployment |
| ``/cloudflare-tunnel`` | ~/.gemini/antigravity/global_workflows/cloudflare-tunnel.md | Quản lý tunnel |
| ``/mine-update`` | ~/.gemini/antigravity/global_workflows/mine-update.md | Cập nhật Mine |
| ``/mock-api`` | ~/.gemini/antigravity/global_workflows/mock-api.md | 💃 Giả lập Backend API |


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

