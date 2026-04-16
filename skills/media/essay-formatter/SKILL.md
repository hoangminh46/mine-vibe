---
name: essay-formatter
description: Format existing .docx files to ĐH Giáo Dục academic standards without modifying content. Use when the user has an existing Word document that needs formatting corrections (wrong font, spacing, margins, etc.) but the content should remain untouched. Triggers on requests involving: (1) Format/định dạng lại file Word, (2) Sửa format tiểu luận, (3) Chỉnh font/lề/giãn dòng cho file docx, (4) "format cho đúng chuẩn", "chỉnh lại định dạng", "sửa format bài", (5) Any mention of fixing document formatting without changing content.
---

# Essay Formatter - Format .docx theo chuẩn ĐH Giáo Dục

Nhận file .docx chưa format → trả về file .docx đã format đúng chuẩn, **không sửa nội dung**.

## Khi nào dùng Skill này?

- User có file .docx với format lộn xộn (font sai, cỡ chữ không đều, giãn dòng sai, lề sai)
- User muốn "chỉnh lại format cho đúng chuẩn"
- User KHÔNG muốn thay đổi nội dung, chỉ cần format

## Nguyên tắc vàng

> **CHỈ FORMAT — KHÔNG SỬA NỘI DUNG**

Script xử lý ở tầng XML formatting attributes, không bao giờ đụng tới text content.

## Workflow

### Step 1: Nhận file từ user

Hỏi user cung cấp file .docx:
```text
Anh/chị gửi file .docx cần format nhé!
Lưu ý: Em chỉ chỉnh format (font, cỡ chữ, giãn dòng, lề) — nội dung giữ nguyên 100%.
```

### Step 2: Copy file vào workspace

Copy file .docx của user vào thư mục tạm trong workspace:
```
essay_temp/input.docx
```

### Step 3: Preview (khuyến khích)

Chạy preview trước để xem cần sửa gì:
```bash
node skills/media/essay-formatter/scripts/format_essay.mjs essay_temp/input.docx --preview
```

Báo cáo kết quả cho user trước khi sửa.

### Step 4: Apply fixes

```bash
node skills/media/essay-formatter/scripts/format_essay.mjs essay_temp/input.docx output_formatted.docx
```

### Step 5: Thông báo kết quả

```text
✅ Đã format xong!

📄 File: output_formatted.docx
🔧 Đã sửa:
   - Font → Times New Roman 14pt
   - Giãn dòng → 1.5
   - Lề trang → T2/D2/L3/P2.5 cm
   - Khổ giấy → A4
📝 Nội dung: KHÔNG THAY ĐỔI ✓
```

## Chuẩn format áp dụng

| Thuộc tính | Giá trị |
|-----------|--------|
| Khổ giấy | A4 (210 × 297mm) |
| Font | Times New Roman |
| Cỡ chữ | 14pt |
| Giãn dòng | 1.5 |
| Lề trái | 3cm |
| Lề phải | 2.5cm |
| Lề trên | 2cm |
| Lề dưới | 2cm |
| Căn lề body | Justify |

## Dependencies

Script cần 2 thư viện trong `package.json`:
- `jszip`: mở file .docx (ZIP format)
- `fast-xml-parser`: parse và rebuild XML

Chạy `npm install` trong thư mục `skills/media/essay-formatter/` nếu chưa cài.

## Error Recovery

### File không phải .docx
```
Script sẽ từ chối và báo lỗi rõ ràng.
```

### File bị corrupt
```
jszip sẽ báo lỗi "Invalid ZIP". Yêu cầu user gửi lại file.
```

### File .docm (có macro)
```
Rename thành .docx trước hoặc từ chối xử lý.
```

## So sánh với essay-writer

| | essay-writer | essay-formatter |
|---|---|---|
| Input | JSON nội dung | .docx có sẵn |
| Output | .docx mới | .docx format lại |
| Nội dung | AI viết | Giữ nguyên |
| Use case | Viết bài từ đầu | Có bài rồi, cần format |
