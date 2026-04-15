---
name: essay-writer
description: Generate complete academic essays (.docx) for Trường Đại học Giáo dục (VNU University of Education) graduate programs. Use when the user needs to create, write, or generate a thesis/essay/tiểu luận document with proper formatting, cover page, table of contents, and academic structure. Triggers on requests involving: (1) Writing essays or tiểu luận, (2) Creating .docx academic documents, (3) Generating formatted thesis papers, (4) Any mention of "bài tiểu luận", "bài thu hoạch", "chuyên đề" for ĐH Giáo dục.
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
- page_count: Target pages (default: 20+)
```

### Step 2: Generate Essay Content

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
4. **Cleanup**: As soon as the `.docx` file is generated successfully, you MUST strictly run a command to delete the entire `essay_temp` folder. Ensure absolutely NO residual intermediate files remain in the workspace; only the final `.docx` file should be left at the root of the project.

## Content Guidelines

- Write in Vietnamese academic style
- Cite real, verifiable Vietnamese academic sources
- Each section must have substantive content (no placeholders)
- "Đặt vấn đề" must explain relevance and urgency
- "Nội dung chủ đề" is the core section — expand with sub-headings as needed
- References must follow format: STT, Author, Year, Title, Publisher, Pages
- Sort references alphabetically by author's first name (Vietnamese convention)
- **STRICT RULE: PURE VIETNAMESE ONLY**. When generating the content, absolutely DO NOT use English terms in parentheses next to Vietnamese terms (e.g., do NOT write "Siêu nhận thức (Metacognition)" or "Mô hình 5E (Engage - Explore...)"). You MUST translate everything fully into Vietnamese and omit the English terms entirely.
- When the user provides a NotebookLM outline, use it as the definitive factual source but strictly apply the "NO ENGLISH" rule above when expanding into the full essay.

### Achieving 20+ Pages (Critical)

Each page ≈ 300 words at 14pt/1.5 spacing → 20 pages ≈ 6,000 words minimum.

Target word count per section:
- Đặt vấn đề: ~500 words (1-1.5 pages)
- Mục đích viết chủ đề: ~500 words (1-1.5 pages)
- Phương pháp hoàn thiện: ~400 words (1 page)
- Nội dung chủ đề (5.1 → 5.x): ~4,000-5,000 words (13-16 pages) — THIS IS THE CORE
- Kết luận / Định hướng: ~600 words (2 pages)

Strategy for the "Nội dung" section:
1. Create at least 5-7 sub-sections (5.1, 5.2, ..., 5.7)
2. Each sub-section should have 2-3 sub-sub-sections (5.1.1, 5.1.2, etc.)
3. Include theoretical frameworks, practical examples, case studies
4. Add analysis of Vietnamese educational context
5. Include comparison with international practices

If input JSON is too large for a single generation, split content creation across multiple writes and merge into one JSON before running the script.

## Important Rules

- Total essay length: minimum 20 pages (excluding cover + TOC)
- Font: Times New Roman, 14pt for body text
- Line spacing: 1.5
- Margins: Left 3cm, Right 2.5cm, Top 2cm, Bottom 2cm
- Cover page follows the template in references/cover-template.md
- All headings bold, section numbers use format: 1., 1.1., 1.1.1.
- Body text alignment: Justify
- Heading alignment: Left (section headings), Center (cover page)
