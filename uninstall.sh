#!/bin/bash
# Mine Uninstaller for Mac/Linux
# Gỡ bỏ toàn bộ Antigravity Global Workflows và cấu hình

ANTIGRAVITY_BASE="$HOME/.gemini/antigravity"
SUB_DIRS=("global_workflows" "schemas" "templates" "global_skills")
PREFS_FILE="$HOME/.gemini/antigravity/preferences.json"
GEMINI_MD="$HOME/.gemini/GEMINI.md"
MINE_VERSION_FILE="$HOME/.gemini/mine_version"

echo ""
echo -e "\033[0;31m╔══════════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[0;31m║           🗑️  Mine - Uninstaller (Mac/Linux)            ║\033[0m"
echo -e "\033[0;31m╚══════════════════════════════════════════════════════════╝\033[0m"
echo ""

# 1. Xác nhận từ người dùng
read -p "❓ Anh có chắc chắn muốn gỡ bỏ Mine và toàn bộ cài đặt? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo -e "\033[0;33m❌ Đã hủy bỏ quá trình gỡ cài đặt.\033[0m"
    exit 0
fi

echo -e "\033[0;36m⏳ Đang gỡ bỏ...\033[0m"

# 2. Xoá các thư mục và file cấu hình cụ thể
echo -e "\033[0;36m⏳ Đang xoá các thành phần của Mine...\033[0m"

for dir in "${SUB_DIRS[@]}"; do
    path="$ANTIGRAVITY_BASE/$dir"
    if [ -d "$path" ]; then
        rm -rf "$path"
        echo -e "\033[0;32m   ✅ Đã xoá: $dir\033[0m"
    fi
done

if [ -f "$PREFS_FILE" ]; then
    rm "$PREFS_FILE"
    echo -e "\033[0;32m   ✅ Đã xoá config: preferences.json\033[0m"
fi

# 3. Xoá file phiên bản
if [ -f "$MINE_VERSION_FILE" ]; then
    rm "$MINE_VERSION_FILE"
    echo -e "\033[0;32m   ✅ Đã xoá file version.\033[0m"
fi

# 4. Làm rỗng GEMINI.md (Không xoá hẳn)
if [ -f "$GEMINI_MD" ]; then
    > "$GEMINI_MD"
    echo -e "\033[0;32m   ✅ Đã làm rỗng file GEMINI.md.\033[0m"
fi

echo ""
echo -e "\033[0;90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\033[0;33m🎉 Đã gỡ bỏ toàn bộ Mine khỏi hệ thống của anh!\033[0m"
echo ""
read -p "Press Enter to exit..."
