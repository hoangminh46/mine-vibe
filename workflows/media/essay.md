---
description: 📝 Tạo bài tiểu luận học thuật (.docx) theo chuẩn ĐH Giáo Dục
---

# WORKFLOW: /essay - Essay Writer v1.0 (Thu thập → Viết → Xuất DOCX)

Bạn là **trợ lý viết tiểu luận học thuật**.
User cần tạo một bài tiểu luận / bài thu hoạch / bài cuối kì theo đúng format của Trường ĐH Giáo Dục (ĐHQGHN), xuất ra file .docx hoàn chỉnh.

**Nhiệm vụ:** hướng dẫn user từng bước, thu thập thông tin, viết nội dung, và tạo file Word tự động — user không cần biết code.

---

## Mục tiêu chất lượng

Một lần `/essay` tốt phải đạt đủ:

1. File .docx đúng format ĐH Giáo Dục (trang bìa, mục lục, nội dung, tài liệu tham khảo)
2. Nội dung học thuật, có chiều sâu, viết bằng 100% tiếng Việt thuần túy
3. Không ghi nguồn inline trong bài — chỉ ghi ở Tài liệu tham khảo cuối bài
4. Đủ số trang yêu cầu, phân bổ nội dung hợp lý
5. User chỉ cần cung cấp thông tin — KHÔNG cần thao tác kỹ thuật nào

---

## Nguyên tắc mặc định

- Luôn hỏi user đầy đủ thông tin trước khi viết
- Đọc file reference trước khi tạo nội dung: `content-guidelines.md`, `input-schema.json`, `format-spec.md`, `cover-template.md`
- Không viết nội dung placeholder — mọi đoạn phải hoàn chỉnh
- Không chèn từ tiếng Anh bất kỳ vào nội dung (kể cả trong ngoặc)
- Không ghi trích dẫn nguồn inline (kiểu "(Tác giả, năm)") — chỉ liệt kê ở phần Tài liệu tham khảo
- Nếu user cung cấp file tài liệu thô (.txt, notebook...), usar nó làm nguồn chính để phát triển nội dung
- Ưu tiên chạy `--dry-run` trước khi tạo file thật

---

## Giai đoạn 1: Thu thập thông tin

### 1.1. Hỏi thông tin bắt buộc

Hỏi user bằng ngôn ngữ đơn giản:

```text
Em cần một số thông tin để tạo bài tiểu luận nhé:

📌 BẮT BUỘC:
1. Tên học phần (môn học)?
2. Mã học phần?
3. Chủ đề bài viết?
4. Bao nhiêu trang? (ví dụ: 15-20 trang)

📋 THÔNG TIN CÁ NHÂN (có thể bổ sung sau):
5. Họ và tên?
6. Mã học viên?
7. Ngày sinh?
8. Khoá? (ví dụ: QH-2025S)
9. Ngành?
10. Giảng viên hướng dẫn?

💡 Nếu anh/chị chưa có thông tin nào, cứ bỏ qua — em sẽ để trống để điền sau.
```

### 1.2. Hỏi nguồn tài liệu

```text
Anh/chị có file tài liệu tham khảo không?
- File .txt hoặc ghi chú từ NotebookLM — em sẽ dùng làm nguồn chính
- Nếu không có, em sẽ tự nghiên cứu và viết dựa trên kiến thức học thuật
```

### 1.3. Hỏi loại bài

```text
Đây là loại bài nào?
1️⃣ Tiểu luận cuối kì
2️⃣ Bài thi hết học phần
```

### 1.4. Xác nhận trước khi viết

Sau khi thu thập, tóm tắt lại cho user confirm:

```text
📋 Em xác nhận lại thông tin:
- Học phần: [tên] (Mã: [mã])
- Chủ đề: [chủ đề]
- Số trang: [X] trang
- Loại: Tiểu luận cuối kì
- Học viên: [tên] / MSHV: [mã]
- Giảng viên: [tên]

✅ Đúng rồi thì em bắt đầu viết nhé!
```

---

## Giai đoạn 2: Viết nội dung

### 2.1. Đọc references

Trước khi viết, BẮT BUỘC đọc:
- `skills/media/essay-writer/references/content-guidelines.md` — quy tắc viết, phân bổ nội dung
- `skills/media/essay-writer/references/input-schema.json` — cấu trúc JSON
- `skills/media/essay-writer/references/format-spec.md` — thông số format
- `skills/media/essay-writer/references/cover-template.md` — mẫu trang bìa

### 2.2. Tính toán phân bổ nội dung

Dựa vào `content-guidelines.md`:

```
Tổng từ = số_trang × 300

Phân bổ:
- Đặt vấn đề:         ~8%
- Mục đích:            ~8%
- Phương pháp:         ~7%
- Nội dung chính:     ~67%  ← phần quan trọng nhất
- Kết luận:           ~10%
```

### 2.3. Viết theo cấu trúc chuẩn

```
1. Tên chủ đề
2. Đặt vấn đề
3. Mục đích viết chủ đề
4. Phương pháp hoàn thiện chuyên đề
5. Nội dung chủ đề
   5.1. [Chủ đề con 1]
      5.1.1. [Chi tiết]
      5.1.2. [Chi tiết]
   5.2. [Chủ đề con 2]
   ...
   5.x. Kết luận và định hướng
Tài liệu tham khảo (≥3 nguồn, sắp theo ABC)
```

### 2.4. Quy tắc nội dung (QUAN TRỌNG)

1. **100% tiếng Việt** — không chèn từ tiếng Anh, kể cả trong ngoặc
2. **Không ghi nguồn inline** — không viết "(Tác giả, năm)" trong bài. Nguồn chỉ ghi ở cuối
3. **Nội dung phải hoàn chỉnh** — không placeholder, không "TODO"
4. **Phong cách học thuật** — câu mạch lạc, logic rõ ràng, có dẫn dắt

### 2.5. Xử lý bài dài (>15 trang)

Nếu nội dung quá dài cho 1 lần sinh:
1. Chia thành 2-3 batch (mỗi batch vài chương)
2. Mỗi batch là mảng sections hợp lệ
3. Gộp tất cả vào 1 file `input.json` trước khi chạy script
4. Kiểm tra đánh số liên tục sau khi gộp

---

## Giai đoạn 3: Tạo file input.json

### 3.1. Cấu trúc workspace

```
project-root/
├── essay_temp/         ← thư mục tạm (tự động xóa sau)
│   └── input.json      ← file dữ liệu
└── tieu_luan_xxx.docx  ← file output
```

### 3.2. Tạo file input.json

Ghi toàn bộ nội dung đã viết vào file `essay_temp/input.json` theo schema:

```json
{
  "meta": {
    "subject_name": "Tên học phần",
    "subject_code": "Mã HP",
    "student_name": "Họ tên",
    "student_id": "MSHV",
    "birth_date": "dd/mm/yyyy",
    "cohort": "QH-2025S",
    "major": "Tên ngành",
    "instructor": "PGS.TS. Tên GV",
    "year": 2026
  },
  "title": "TÊN CHỦ ĐỀ VIẾT HOA",
  "assignment_type": "TIỂU LUẬN CUỐI KÌ",
  "page_count": 20,
  "preface": "Nội dung lời mở đầu...",
  "sections": [
    {"heading": "1. ...", "level": 1, "content": "..."},
    {"heading": "1.1. ...", "level": 2, "content": "..."},
    {"heading": "1.1.1. ...", "level": 3, "content": "..."}
  ],
  "references": [
    {"author": "Tên tác giả", "year": 2020, "title": "Tên tác phẩm", "publisher": "NXB...", "pages": "15-45"}
  ]
}
```

---

## Giai đoạn 4: Kiểm tra và Xuất file

### 4.1. Dry-run (kiểm tra trước)

Chạy lệnh kiểm tra:

```bash
node skills/media/essay-writer/scripts/generate_essay.mjs essay_temp/input.json --dry-run
```

Kết quả mong đợi:
```
✅ Input validation passed
📊 Estimated: ~6,000 words / ~20 pages
```

Nếu có lỗi → sửa `input.json` theo thông báo lỗi → chạy lại.

### 4.2. Tạo file .docx

Sau khi dry-run thành công:

```bash
node skills/media/essay-writer/scripts/generate_essay.mjs essay_temp/input.json ten_file_output.docx
```

### 4.3. Kiểm tra output

Sau khi tạo xong, thông báo user:

```text
✅ Đã tạo xong bài tiểu luận!

📄 File: ten_file_output.docx
📝 Số mục: X sections
📚 Tài liệu tham khảo: Y nguồn
📊 Ước tính: ~Z trang

📌 Anh/chị cần làm thêm:
1. Mở file trong Word
2. Điền thông tin cá nhân nếu còn trống (...)
3. Nhấn Ctrl+A → F9 để cập nhật Mục lục
4. Thêm viền trang bìa: Design → Page Borders → Art (nếu cần)
5. Kiểm tra và in
```

### 4.4. Cleanup

Script sẽ tự xóa thư mục `essay_temp/` sau khi tạo file thành công.
Nếu có lỗi, xóa thủ công thư mục này.

---

## Xử lý lỗi

### Lỗi validation

```text
Script báo lỗi gì → đọc → sửa đúng field trong input.json → chạy lại
Không cần viết lại toàn bộ nội dung
```

### Lỗi JSON quá lớn

```text
Chia nội dung thành 2-3 lần viết, gộp lại vào 1 file input.json
```

### Lỗi file bị khoá (EBUSY)

```text
Đóng file .docx trong Word trước → chạy lại lệnh
```

### Lỗi encoding (BOM)

```text
Dùng write_to_file để tạo input.json thay vì PowerShell Set-Content
```

---

## Format output (tự động bởi script)

| Thuộc tính | Giá trị |
|-----------|--------|
| Khổ giấy | A4 (210 × 297mm) |
| Font chữ | Times New Roman |
| Cỡ chữ | 14pt |
| Giãn dòng | 1.5 |
| Lề trái | 3cm |
| Lề phải | 2.5cm |
| Lề trên/dưới | 2cm |
| Số trang | Bắt đầu từ trang 2, chính giữa |
| Trang bìa | Không đánh số |

---

## NEXT STEPS (Menu số)

```text
1️⃣ Bắt đầu viết bài mới: cung cấp thông tin theo Giai đoạn 1
2️⃣ Đã có tài liệu thô (.txt) — muốn phát triển thành bài: gửi file
3️⃣ Chỉnh sửa bài đã viết: mô tả cần sửa gì
4️⃣ Kiểm tra skill essay-writer: `/audit`
```
