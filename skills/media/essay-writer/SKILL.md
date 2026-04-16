---
name: essay-writer
description: Generate complete academic essays (.docx) for Trường Đại học Giáo dục (VNU University of Education) graduate programs. Use when the user needs to create, write, or generate a thesis/essay/tiểu luận document with proper formatting, cover page, table of contents, and academic structure. Triggers on requests involving: (1) Writing essays or tiểu luận, bài thu hoạch, bài cuối kì, (2) Creating .docx/.word academic documents, (3) Generating formatted thesis papers with cover page and TOC, (4) Any mention of "bài tiểu luận", "bài thu hoạch", "chuyên đề", "viết bài", "xuất docx", "tạo file word" for ĐH Giáo Dục programs.
---

# Essay Writer - Trường ĐH Giáo Dục

Generate complete academic essays as .docx files with proper formatting for VNU University of Education graduate programs.

## Workflow

### Step 1: Gather Required Information

Collect from user (skip fields they want to fill later):

```
Required:
- topic: Essay topic/title (tên chủ đề)
- subject_name: Course name (tên học phần)
- subject_code: Course code (mã học phần)

Optional (can be placeholder):
- student_name: Full name (họ và tên)
- student_id: Student ID (MSHV)  
- birth_date: Date of birth
- cohort: Graduate cohort (khóa cao học, e.g. "QH-2025S")
- class_name: Class name
- major: Major/specialization (ngành)
- instructor: Instructor name + title
- page_count: Target pages (ask user, no fixed default)
```

### Step 2: Generate Essay Content

Before writing content, read these references:
- **Content structure & word count targets**: See [references/content-guidelines.md](references/content-guidelines.md)
- **Input JSON contract**: See [references/input-schema.json](references/input-schema.json)

Structure the content following this exact outline:

```
PAGE 1: Cover Page (Trang bìa)
PAGE 2: Table of Contents (Mục lục)  
PAGE 3: Preface (Lời mở đầu)
PAGE 4+: Main Content:
  1. Tên chủ đề
  2. Đặt vấn đề (~1/2 page)
  3. Mục đích viết chủ đề (~1/2 page)
  4. Phương pháp hoàn thiện chuyên đề (~1/2 page)
  5. Nội dung
     5.1. Nội dung chủ đề (main body, expand to meet page target)
     5.2. Kết luận / Định hướng
  6. Tài liệu tham khảo (≥3 sources, sorted alphabetically by author last name)
```

### Step 3: Execution and Creation of DOCX File (STRICT ISOLATION)

When running the essay creation process, you MUST observe the following strict constraints to keep the workspace clean:
1. **Isolated Working Directory**: Create a temporary folder named `essay_temp` at the root of the current project workspace.
2. **Intermediate Files**: All generated `data.json`, `input.json`, and `.mjs` builder files MUST be written and executed exclusively inside this `essay_temp` folder.
3. **Output Location**: Output the final `.docx` file DIRECTLY to the root of the project workspace (at the same level as the `essay_temp` folder).
4. **Cleanup**: The script will automatically self-cleanup the `essay_temp` folder after generating the `.docx`. If the script fails, manually delete the folder.

#### Running the Script

```bash
# Full generation
node generate_essay.mjs <input.json> <output.docx>

# Validate input + estimate word count without generating .docx
node generate_essay.mjs <input.json> --dry-run
```

Use `--dry-run` first to verify the input JSON is valid and estimate page count before the full build.

## Important Rules

- Total essay length: determined by user's `page_count` (excluding cover + TOC). Always ask user how many pages they need.
- Font: Times New Roman, 14pt for body text
- Line spacing: 1.5
- Margins: Left 3cm, Right 2.5cm, Top 2cm, Bottom 2cm
- Cover page follows the template in [references/cover-template.md](references/cover-template.md)
- Full format spec in [references/format-spec.md](references/format-spec.md)
- All headings bold, section numbers use format: 1., 1.1., 1.1.1.
- Body text alignment: Justify
- Heading alignment: Left (section headings), Center (cover page)

## Error Recovery

### Script crash (non-zero exit code)
1. Read the error message from stderr — the script provides descriptive error messages
2. Fix the `input.json` based on the error (missing field, invalid type, etc.)
3. Re-run the script. Do NOT regenerate the entire content.

### JSON too large for single generation
1. Split generation into 2-3 batches (each covering a subset of sections)
2. Each batch must be a valid JSON array of section objects
3. Merge all arrays into one `input.json` before running the script
4. Ensure section numbering remains consistent across batches

### Generated DOCX has formatting issues
1. Re-read `references/format-spec.md` to verify compliance
2. Re-generate only the affected section in `input.json`
3. Re-run the script

### Validation fails on dry-run
1. The script will list all validation errors with field paths
2. Fix only the reported fields
3. Re-run `--dry-run` until all errors are resolved
4. Then run the full generation
