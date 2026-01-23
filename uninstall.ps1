# Mine Uninstaller for Windows (PowerShell)
# Gỡ bỏ toàn bộ Antigravity Global Workflows và cấu hình

$AntigravityBase = "$env:USERPROFILE\.gemini\antigravity"
$SubDirs = @("global_workflows", "schemas", "templates", "global_skills")
$PrefsFile = "$env:USERPROFILE\.gemini\antigravity\preferences.json"
$GeminiMd = "$env:USERPROFILE\.gemini\GEMINI.md"
$MineVersionFile = "$env:USERPROFILE\.gemini\mine_version"

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "║           🗑️  Mine - Uninstaller (Windows)              ║" -ForegroundColor Red
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Red
Write-Host ""

# 1. Xác nhận từ người dùng
$Confirm = Read-Host "❓ Anh có chắc chắn muốn gỡ bỏ Mine và toàn bộ cài đặt? (y/n)"
if ($Confirm -ne "y") {
    Write-Host "❌ Đã hủy bỏ quá trình gỡ cài đặt." -ForegroundColor Yellow
    exit
}

Write-Host "⏳ Đang gỡ bỏ..." -ForegroundColor Cyan

# 2. Xoá các thư mục và file cấu hình cụ thể
Write-Host "⏳ Đang xoá các thành phần của Mine..." -ForegroundColor Cyan

foreach ($dir in $SubDirs) {
    $Path = Join-Path $AntigravityBase $dir
    if (Test-Path $Path) {
        Remove-Item -Path $Path -Recurse -Force
        Write-Host "   ✅ Đã xoá: $dir" -ForegroundColor Green
    }
}

if (Test-Path $PrefsFile) {
    Remove-Item -Path $PrefsFile -Force
    Write-Host "   ✅ Đã xoá config: preferences.json" -ForegroundColor Green
}

# 3. Xoá file phiên bản
if (Test-Path $MineVersionFile) {
    Remove-Item -Path $MineVersionFile -Force
    Write-Host "   ✅ Đã xoá file version." -ForegroundColor Green
}

# 4. Làm rỗng GEMINI.md (Không xoá hẳn)
if (Test-Path $GeminiMd) {
    Clear-Content -Path $GeminiMd
    Write-Host "   ✅ Đã làm rỗng file GEMINI.md." -ForegroundColor Green
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "🎉 Đã gỡ bỏ toàn bộ Mine khỏi hệ thống của anh!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Enter to exit..." -ForegroundColor Gray
Read-Host
