# Format Rules — Essay Formatter

## Quy tắc format chuẩn ĐH Giáo Dục (ĐHQGHN)

### Page Setup (OOXML twips)
| Property | Value | OOXML |
|---|---|---|
| Page size | A4 (210mm × 297mm) | w:w="11906" w:h="16838" |
| Left margin | 3cm | 1701 twips |
| Right margin | 2.5cm | 1418 twips |
| Top margin | 2cm | 1134 twips |
| Bottom margin | 2cm | 1134 twips |

### Typography
| Property | Value | OOXML |
|---|---|---|
| Font | Times New Roman | w:ascii, w:hAnsi, w:cs |
| Body size | 14pt | w:val="28" (half-points) |
| Line spacing | 1.5 | w:line="360" w:lineRule="auto" |
| Body alignment | Justify | w:jc w:val="both" |

### Heading Styles
| Level | Size | Weight | Alignment |
|-------|------|--------|-----------|
| Heading 1 | 14pt | Bold | Left |
| Heading 2 | 14pt | Bold | Left |
| Heading 3 | 14pt | Bold + Italic | Left |

## Nguyên tắc "Không sửa nội dung"

Script CHỈ thay đổi các XML attributes sau:
- `<w:rFonts>` — tên font
- `<w:sz>`, `<w:szCs>` — cỡ chữ
- `<w:spacing>` — giãn dòng
- `<w:pgSz>` — kích thước trang
- `<w:pgMar>` — lề trang

Script KHÔNG BAO GIỜ đụng:
- `<w:t>` — nội dung text
- `<w:drawing>` — hình ảnh
- `<w:tbl>` — bảng
- `<w:footnote>` — chú thích
- `<w:comment>` — comment
