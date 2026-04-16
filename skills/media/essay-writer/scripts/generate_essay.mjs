/**
 * generate_essay.mjs — Tạo file .docx tiểu luận theo format ĐH Giáo Dục
 *
 * Usage: node generate_essay.mjs <input.json> <output.docx> [--dry-run]
 *
 * Flags:
 *   --dry-run  Validate input and estimate word count without generating .docx
 *
 * input.json schema: See references/input-schema.json
 */

import { readFileSync, writeFileSync, rmSync } from "fs";
import { dirname } from "path";
import {
  Document,
  Packer,
  Paragraph,
  TextRun,
  AlignmentType,
  HeadingLevel,
  PageBreak,
  Footer,
  PageNumber,
  NumberFormat,
  LineRuleType,
  SectionType,
  TableOfContents,
} from "docx";

const FONT = "Times New Roman";
const BODY_SIZE = 28; // 14pt in half-points
const LINE_SPACING = 360; // 1.5 spacing
const WORDS_PER_PAGE = 300; // At 14pt/1.5 spacing

// Twips conversion: 1cm = 567 twips
const MARGINS = {
  top: 1134,    // 2cm
  bottom: 1134, // 2cm
  left: 1701,   // 3cm
  right: 1418,  // 2.5cm
};

// A4: 210mm x 297mm
const PAGE_WIDTH = 11906;  // 210mm in twips
const PAGE_HEIGHT = 16838; // 297mm in twips

// ─── CLI ────────────────────────────────────────────────────────────────────────

function parseArgs() {
  const args = process.argv.slice(2);
  const dryRun = args.includes("--dry-run");
  const positional = args.filter((a) => a !== "--dry-run");

  if (positional.length < 1 || (!dryRun && positional.length < 2)) {
    console.error("Usage: node generate_essay.mjs <input.json> <output.docx> [--dry-run]");
    process.exit(1);
  }
  return { inputPath: positional[0], outputPath: positional[1], dryRun };
}

function loadInput(inputPath) {
  let raw;
  try {
    raw = readFileSync(inputPath, "utf-8");
  } catch (err) {
    console.error(`❌ Cannot read input file: ${inputPath}`);
    console.error(`   ${err.message}`);
    process.exit(1);
  }

  try {
    return JSON.parse(raw);
  } catch (err) {
    console.error(`❌ Invalid JSON in: ${inputPath}`);
    console.error(`   ${err.message}`);
    process.exit(1);
  }
}

// ─── Input Validation ───────────────────────────────────────────────────────────

function validateInput(data) {
  const errors = [];

  if (!data.meta || typeof data.meta !== "object") {
    errors.push('Missing or invalid "meta" object');
  } else {
    if (!data.meta.subject_name) errors.push('meta.subject_name is required');
    if (!data.meta.subject_code) errors.push('meta.subject_code is required');
  }

  if (!data.title || typeof data.title !== "string") {
    errors.push('Missing or invalid "title" string');
  }

  if (data.assignment_type &&
      !["TIỂU LUẬN CUỐI KÌ", "BÀI THI HẾT HỌC PHẦN"].includes(data.assignment_type)) {
    errors.push('"assignment_type" must be "TIỂU LUẬN CUỐI KÌ" or "BÀI THI HẾT HỌC PHẦN"');
  }

  if (!Array.isArray(data.sections) || data.sections.length === 0) {
    errors.push('"sections" must be a non-empty array');
  } else {
    data.sections.forEach((s, i) => {
      if (!s.heading) errors.push(`sections[${i}]: missing "heading"`);
      if (![1, 2, 3].includes(s.level)) errors.push(`sections[${i}]: "level" must be 1, 2, or 3`);
    });
  }

  if (data.references !== undefined) {
    if (!Array.isArray(data.references)) {
      errors.push('"references" must be an array');
    } else if (data.references.length < 3) {
      errors.push('"references" must have at least 3 entries');
    } else {
      data.references.forEach((r, i) => {
        if (!r.author) errors.push(`references[${i}]: missing "author"`);
        if (!r.title) errors.push(`references[${i}]: missing "title"`);
        if (!r.publisher) errors.push(`references[${i}]: missing "publisher"`);
        if (r.year === undefined) errors.push(`references[${i}]: missing "year"`);
      });
    }
  }

  if (errors.length > 0) {
    console.error("❌ Input validation failed:");
    errors.forEach((e) => console.error(`   • ${e}`));
    process.exit(1);
  }

  console.log("✅ Input validation passed");
}

// ─── Word Count ─────────────────────────────────────────────────────────────────

function estimateWordCount(data) {
  let count = 0;
  if (data.preface) count += data.preface.split(/\s+/).filter(Boolean).length;
  if (data.sections) {
    for (const s of data.sections) {
      if (s.content) count += s.content.split(/\s+/).filter(Boolean).length;
    }
  }
  return count;
}

function reportWordCount(data) {
  const wordCount = estimateWordCount(data);
  const estimatedPages = Math.round(wordCount / WORDS_PER_PAGE);
  const targetPages = data.page_count || null;

  console.log(`📊 Estimated: ~${wordCount.toLocaleString()} words / ~${estimatedPages} pages`);

  if (targetPages && estimatedPages < targetPages) {
    console.warn(`⚠️  Warning: Content may be under target (${targetPages} pages). Estimated: ${estimatedPages} pages.`);
    console.warn(`   Consider expanding "Nội dung chủ đề" section with more sub-sections.`);
  }

  return { wordCount, estimatedPages };
}

// ─── Utility ────────────────────────────────────────────────────────────────────

/** Normalize Vietnamese text to NFC form to prevent encoding issues from PDF copy-paste */
function normalizeVietnamese(text) {
  return typeof text === "string" ? text.normalize("NFC") : text;
}

function createEmptyParagraph(size = BODY_SIZE) {
  return new Paragraph({
    spacing: { after: 0, line: LINE_SPACING, lineRule: LineRuleType.AUTO },
    children: [new TextRun({ font: FONT, size, text: "" })],
  });
}

// ─── Document Builders ──────────────────────────────────────────────────────────

function buildCoverPage(data) {
  const meta = data.meta || {};
  const year = meta.year || new Date().getFullYear();
  const assignmentType = data.assignment_type || "TIỂU LUẬN CUỐI KÌ";

  const paragraphs = [
    // ĐẠI HỌC QUỐC GIA HÀ NỘI
    new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { after: 0, line: LINE_SPACING, lineRule: LineRuleType.AUTO },
      children: [
        new TextRun({ font: FONT, size: 31, text: "ĐẠI HỌC QUỐC GIA HÀ NỘI" }),
      ],
    }),
    // TRƯỜNG ĐẠI HỌC GIÁO DỤC
    new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { after: 0, line: LINE_SPACING, lineRule: LineRuleType.AUTO },
      children: [
        new TextRun({ font: FONT, size: 31, bold: true, text: "TRƯỜNG ĐẠI HỌC GIÁO DỤC" }),
      ],
    }),

    createEmptyParagraph(),
    createEmptyParagraph(),
    createEmptyParagraph(),

    // Assignment type title
    new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { after: 0, line: LINE_SPACING, lineRule: LineRuleType.AUTO },
      children: [
        new TextRun({ font: FONT, size: 40, bold: true, text: assignmentType }),
      ],
    }),
    // Subject name
    new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { after: 0, line: LINE_SPACING, lineRule: LineRuleType.AUTO },
      children: [
        new TextRun({
          font: FONT,
          size: 36,
          bold: true,
          text: normalizeVietnamese(meta.subject_name || "TÊN HỌC PHẦN").toUpperCase(),
        }),
      ],
    }),
    // Subject code
    new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { after: 0, line: LINE_SPACING, lineRule: LineRuleType.AUTO },
      children: [
        new TextRun({
          font: FONT, size: BODY_SIZE, bold: true,
          text: `Mã học phần: ${meta.subject_code || "..."}`,
        }),
      ],
    }),

    createEmptyParagraph(),
    createEmptyParagraph(),
    createEmptyParagraph(),
    createEmptyParagraph(),
  ];

  // Info block — only render fields that have real values
  const infoLines = [
    { label: "Giảng viên", value: meta.instructor },
    { label: "Học viên", value: meta.student_name },
    { label: "Ngày sinh", value: meta.birth_date },
    { label: "Mã học viên", value: meta.student_id },
    { label: "Khoá", value: meta.cohort },
    { label: "Ngành", value: meta.major },
  ];

  for (const info of infoLines) {
    const displayValue = info.value || ".........................";
    paragraphs.push(
      new Paragraph({
        alignment: AlignmentType.LEFT,
        spacing: { after: 0, line: LINE_SPACING, lineRule: LineRuleType.AUTO },
        indent: { left: 2268 }, // ~4cm indent
        children: [
          new TextRun({ font: FONT, size: BODY_SIZE, bold: true, text: `${info.label}: ` }),
          new TextRun({ font: FONT, size: BODY_SIZE, bold: true, text: normalizeVietnamese(displayValue) }),
        ],
      })
    );
  }

  paragraphs.push(createEmptyParagraph());
  paragraphs.push(createEmptyParagraph());
  paragraphs.push(createEmptyParagraph());

  // Hà Nội – Year
  paragraphs.push(
    new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { after: 0, line: LINE_SPACING, lineRule: LineRuleType.AUTO },
      children: [
        new TextRun({ font: FONT, size: BODY_SIZE, bold: true, text: `Hà Nội – ${year}` }),
      ],
    })
  );

  return paragraphs;
}

function buildTOC(data) {
  const paragraphs = [
    new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { before: 240, after: 240, line: LINE_SPACING, lineRule: LineRuleType.AUTO },
      children: [
        new TextRun({ font: FONT, size: BODY_SIZE, bold: true, text: "MỤC LỤC" }),
      ],
    }),
    new TableOfContents("", {
      hyperlink: true,
      headingStyleRange: "1-3",
    }),
  ];
  return paragraphs;
}

function buildPreface(data) {
  const paragraphs = [
    new Paragraph({
      heading: HeadingLevel.HEADING_1,
      alignment: AlignmentType.CENTER,
      spacing: { before: 240, after: 240, line: LINE_SPACING, lineRule: LineRuleType.AUTO },
      children: [
        new TextRun({ text: "LỜI MỞ ĐẦU" }),
      ],
    }),
  ];

  const prefaceText = normalizeVietnamese(data.preface || "");
  const prefaceParagraphs = prefaceText.split("\n").filter((p) => p.trim());

  for (const para of prefaceParagraphs) {
    paragraphs.push(
      new Paragraph({
        alignment: AlignmentType.JUSTIFIED,
        spacing: { after: 0, line: LINE_SPACING, lineRule: LineRuleType.AUTO },
        indent: { firstLine: 720 }, // First line indent ~1.27cm
        children: [new TextRun({ font: FONT, size: BODY_SIZE, text: para.trim() })],
      })
    );
  }

  return paragraphs;
}

function buildContent(data) {
  const paragraphs = [];

  // Title: NỘI DUNG TIỂU LUẬN
  paragraphs.push(
    new Paragraph({
      heading: HeadingLevel.HEADING_1,
      alignment: AlignmentType.CENTER,
      spacing: { before: 240, after: 240, line: LINE_SPACING, lineRule: LineRuleType.AUTO },
      children: [
        new TextRun({ text: "NỘI DUNG TIỂU LUẬN" }),
      ],
    })
  );

  if (!data.sections) return paragraphs;

  for (const section of data.sections) {
    const isH1 = section.level === 1;
    const isH2 = section.level === 2;

    // Section heading
    const headingLvl = isH1 ? HeadingLevel.HEADING_1 : isH2 ? HeadingLevel.HEADING_2 : HeadingLevel.HEADING_3;
    paragraphs.push(
      new Paragraph({
        heading: headingLvl,
        alignment: AlignmentType.LEFT,
        spacing: {
          before: isH1 ? 240 : isH2 ? 120 : 60,
          after: isH1 ? 120 : 60,
          line: LINE_SPACING,
          lineRule: LineRuleType.AUTO,
        },
        children: [
          new TextRun({ text: normalizeVietnamese(section.heading) }),
        ],
      })
    );

    // Section content paragraphs
    if (section.content) {
      const normalizedContent = normalizeVietnamese(section.content);
      const contentParagraphs = normalizedContent.split("\n").filter((p) => p.trim());
      for (const para of contentParagraphs) {
        paragraphs.push(
          new Paragraph({
            alignment: AlignmentType.JUSTIFIED,
            spacing: { after: 0, line: LINE_SPACING, lineRule: LineRuleType.AUTO },
            indent: { firstLine: 720 },
            children: [new TextRun({ font: FONT, size: BODY_SIZE, text: para.trim() })],
          })
        );
      }
    }
  }

  return paragraphs;
}

function buildReferences(data) {
  const paragraphs = [
    new Paragraph({
      heading: HeadingLevel.HEADING_1,
      alignment: AlignmentType.CENTER,
      spacing: { before: 360, after: 240, line: LINE_SPACING, lineRule: LineRuleType.AUTO },
      children: [
        new TextRun({ text: "TÀI LIỆU THAM KHẢO" }),
      ],
    }),
  ];

  if (!data.references) return paragraphs;

  // Sort by author name alphabetically
  const sorted = [...data.references].sort((a, b) =>
    (a.author || "").localeCompare(b.author || "", "vi")
  );

  sorted.forEach((ref, idx) => {
    const stt = idx + 1;
    paragraphs.push(
      new Paragraph({
        alignment: AlignmentType.JUSTIFIED,
        spacing: { after: 60, line: LINE_SPACING, lineRule: LineRuleType.AUTO },
        indent: { left: 567, hanging: 567 }, // Hanging indent for reference entries
        children: [
          new TextRun({ font: FONT, size: BODY_SIZE, text: `[${stt}]. ` }),
          new TextRun({ font: FONT, size: BODY_SIZE, text: `${normalizeVietnamese(ref.author)} ` }),
          new TextRun({ font: FONT, size: BODY_SIZE, text: `(${ref.year}). ` }),
          new TextRun({ font: FONT, size: BODY_SIZE, italics: true, text: `${normalizeVietnamese(ref.title)}` }),
          new TextRun({ font: FONT, size: BODY_SIZE, text: `. ${normalizeVietnamese(ref.publisher)}` }),
          new TextRun({
            font: FONT,
            size: BODY_SIZE,
            text: ref.pages ? `, tr. ${ref.pages}.` : ".",
          }),
        ],
      })
    );
  });

  return paragraphs;
}

// ─── Cleanup ────────────────────────────────────────────────────────────────────

function selfCleanup(inputPath) {
  const tempDir = dirname(inputPath);
  // Safety check: only delete if the directory name matches the expected temp folder
  if (tempDir.endsWith("essay_temp")) {
    try {
      rmSync(tempDir, { recursive: true, force: true });
      console.log(`🧹 Cleaned up temp directory: ${tempDir}`);
    } catch (cleanupErr) {
      console.warn(`⚠️  Could not clean up ${tempDir}: ${cleanupErr.message}`);
    }
  }
}

// ─── Main ───────────────────────────────────────────────────────────────────────

async function main() {
  const { inputPath, outputPath, dryRun } = parseArgs();

  console.log(`📖 Reading input: ${inputPath}`);
  const data = loadInput(inputPath);

  // Step 1: Validate
  validateInput(data);

  // Step 2: Word count estimation
  const { wordCount, estimatedPages } = reportWordCount(data);

  // Dry-run exits here
  if (dryRun) {
    console.log("\n🔍 Dry run complete — no .docx generated.");
    console.log(`   Sections: ${data.sections?.length || 0}`);
    console.log(`   References: ${data.references?.length || 0}`);
    console.log(`   Words: ~${wordCount.toLocaleString()}`);
    console.log(`   Est. Pages: ~${estimatedPages}`);
    return;
  }

  try {
    // Step 3: Build document sections
    console.log("📄 Building cover page...");
    const coverChildren = buildCoverPage(data);

    console.log("📑 Building table of contents...");
    const tocChildren = buildTOC(data);

    console.log("✏️  Building preface...");
    const prefaceChildren = buildPreface(data);

    console.log(`📝 Building content (${data.sections?.length || 0} sections)...`);
    const contentChildren = buildContent(data);

    console.log(`📚 Building references (${data.references?.length || 0} sources)...`);
    const refChildren = buildReferences(data);

    // Step 4: Assemble document
    console.log("📦 Packaging document...");

    const sectionProperties = {
      page: {
        size: { width: PAGE_WIDTH, height: PAGE_HEIGHT },
        margin: MARGINS,
      },
    };

    const doc = new Document({
      styles: {
        default: {
          document: {
            run: { font: FONT, size: BODY_SIZE },
            paragraph: {
              spacing: { line: LINE_SPACING, lineRule: LineRuleType.AUTO },
            },
          },
        },
        paragraphStyles: [
          {
            id: "Heading1",
            name: "Heading 1",
            basedOn: "Normal",
            next: "Normal",
            quickFormat: true,
            run: { size: BODY_SIZE, bold: true, font: FONT, color: "000000" },
            paragraph: { spacing: { before: 240, after: 120, line: LINE_SPACING, lineRule: LineRuleType.AUTO } },
          },
          {
            id: "Heading2",
            name: "Heading 2",
            basedOn: "Normal",
            next: "Normal",
            quickFormat: true,
            run: { size: BODY_SIZE, bold: true, font: FONT, color: "000000" },
            paragraph: { spacing: { before: 120, after: 60, line: LINE_SPACING, lineRule: LineRuleType.AUTO } },
          },
          {
            id: "Heading3",
            name: "Heading 3",
            basedOn: "Normal",
            next: "Normal",
            quickFormat: true,
            run: { size: BODY_SIZE, bold: true, italics: true, font: FONT, color: "000000" },
            paragraph: { spacing: { before: 60, after: 60, line: LINE_SPACING, lineRule: LineRuleType.AUTO } },
          },
          {
            id: "TOC1",
            name: "toc 1",
            basedOn: "Normal",
            next: "Normal",
            run: { size: BODY_SIZE, font: FONT, bold: false },
            paragraph: { spacing: { after: 60, line: 276, lineRule: LineRuleType.AUTO } },
          },
          {
            id: "TOC2",
            name: "toc 2",
            basedOn: "Normal",
            next: "Normal",
            run: { size: BODY_SIZE, font: FONT, bold: false },
            paragraph: { indent: { left: 567 }, spacing: { after: 60, line: 276, lineRule: LineRuleType.AUTO } },
          },
          {
            id: "TOC3",
            name: "toc 3",
            basedOn: "Normal",
            next: "Normal",
            run: { size: BODY_SIZE, font: FONT, bold: false },
            paragraph: { indent: { left: 1134 }, spacing: { after: 60, line: 276, lineRule: LineRuleType.AUTO } },
          }
        ],
      },
      sections: [
        // Section 1: Cover page — no page number
        {
          properties: {
            ...sectionProperties,
            page: {
              ...sectionProperties.page,
              pageNumbers: { formatType: NumberFormat.DECIMAL },
            },
            type: SectionType.NEXT_PAGE,
          },
          children: coverChildren,
        },
        // Section 2: TOC + Preface + Content + References — with page numbers
        {
          properties: {
            ...sectionProperties,
            page: {
              ...sectionProperties.page,
              pageNumbers: { start: 2, formatType: NumberFormat.DECIMAL },
            },
            type: SectionType.NEXT_PAGE,
          },
          footers: {
            default: new Footer({
              children: [
                new Paragraph({
                  alignment: AlignmentType.CENTER,
                  children: [
                    new TextRun({
                      font: FONT,
                      size: BODY_SIZE,
                      children: [PageNumber.CURRENT],
                    }),
                  ],
                }),
              ],
            }),
          },
          children: [
            ...tocChildren,
            // Page break after TOC
            new Paragraph({ children: [new PageBreak()] }),
            ...prefaceChildren,
            // Page break after preface
            new Paragraph({ children: [new PageBreak()] }),
            ...contentChildren,
            ...refChildren,
          ],
        },
      ],
    });

    // Step 5: Write to file
    const buffer = await Packer.toBuffer(doc);
    writeFileSync(outputPath, buffer);

    console.log(`\n✅ Essay generated successfully!`);
    console.log(`   📄 Output: ${outputPath}`);
    console.log(`   📝 Sections: ${data.sections?.length || 0}`);
    console.log(`   📚 References: ${data.references?.length || 0}`);
    console.log(`   📊 ~${wordCount.toLocaleString()} words / ~${estimatedPages} pages`);
  } finally {
    // Self-cleanup: always attempt to clean essay_temp regardless of success/failure
    selfCleanup(inputPath);
  }
}

main().catch((err) => {
  console.error("❌ Error generating essay:", err.message);
  process.exit(1);
});
