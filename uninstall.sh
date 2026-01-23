#!/bin/bash
# Mine Uninstaller for Mac/Linux
# Gỡ bỏ toàn bộ Antigravity Global Workflows và cấu hình

ANTIGRAVITY_DIR="$HOME/.gemini/antigravity"
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

# 2. Xoá thư mục antigravity
if [ -d "$ANTIGRAVITY_DIR" ]; then
    rm -rf "$ANTIGRAVITY_DIR"
    echo -e "\033[0;32m   ✅ Đã xoá thư mục dữ liệu: $ANTIGRAVITY_DIR\033[0m"
fi

# 3. Xoá file phiên bản
if [ -f "$MINE_VERSION_FILE" ]; then
    rm "$MINE_VERSION_FILE"
    echo -e "\033[0;32m   ✅ Đã xoá file version.\033[0m"
fi

# 4. Dọn dẹp GEMINI.md
if [ -f "$GEMINI_MD" ]; then
    # Tìm dòng bắt đầu của Mine section
    marker="# Mine - Antigravity Workflow Framework"
    if grep -q "$marker" "$GEMINI_MD"; then
        # Xoá từ marker đến hết file
        sed -i "/$marker/,\$d" "$GEMINI_MD"
        
        # Nếu file trống thì xoá luôn
        if [ ! -s "$GEMINI_MD" ]; then
            rm "$GEMINI_MD"
            echo -e "\033[0;32m   ✅ Đã xoá file GEMINI.md (vì không còn nội dung khác).\033[0m"
        else
            echo -e "\033[0;32m   ✅ Đã gỡ bỏ quy tắc Mine khỏi GEMINI.md.\033[0m"
        fi
    fi
fi

echo ""
echo -e "\033[0;90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\033[0;33m🎉 Đã gỡ bỏ toàn bộ Mine khỏi hệ thống của anh!\033[0m"
echo ""
read -p "Press Enter to exit..."
