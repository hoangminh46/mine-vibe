# Mine Uninstaller for Windows (PowerShell)
# Gỡ bỏ toàn bộ Antigravity Global Workflows và cấu hình

$AntigravityDir = "$env:USERPROFILE\.gemini\antigravity"
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

# 2. Xoá thư mục antigravity (Workflows, Schemas, Templates, Skills)
if (Test-Path $AntigravityDir) {
    Remove-Item -Path $AntigravityDir -Recurse -Force
    Write-Host "   ✅ Đã xoá thư mục dữ liệu: $AntigravityDir" -ForegroundColor Green
}

# 3. Xoá file phiên bản
if (Test-Path $MineVersionFile) {
    Remove-Item -Path $MineVersionFile -Force
    Write-Host "   ✅ Đã xoá file version." -ForegroundColor Green
}

# 4. Dọn dẹp GEMINI.md (Xoá phần quy tắc của Mine)
if (Test-Path $GeminiMd) {
    $content = Get-Content $GeminiMd -Raw -ErrorAction SilentlyContinue
    if ($null -ne $content) {
        $mineMarker = "# Mine - Antigravity Workflow Framework"
        $markerIndex = $content.IndexOf($mineMarker)
        if ($markerIndex -ge 0) {
            $cleanedContent = $content.Substring(0, $markerIndex).TrimEnd()
            if ([string]::IsNullOrWhiteSpace($cleanedContent)) {
                Remove-Item -Path $GeminiMd -Force
                Write-Host "   ✅ Đã xoá file GEMINI.md (vì không còn nội dung khác)." -ForegroundColor Green
            } else {
                Set-Content -Path $GeminiMd -Value $cleanedContent -Encoding UTF8
                Write-Host "   ✅ Đã gỡ bỏ quy tắc Mine khỏi GEMINI.md." -ForegroundColor Green
            }
        }
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "🎉 Đã gỡ bỏ toàn bộ Mine khỏi hệ thống của anh!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Enter to exit..." -ForegroundColor Gray
Read-Host
