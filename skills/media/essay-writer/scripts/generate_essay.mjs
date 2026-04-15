/**
 * generate_essay.mjs — Tạo file .docx tiểu luận theo format ĐH Giáo Dục
 *
 * Usage: node generate_essay.mjs <input.json> <output.docx>
 *
 * input.json schema:
 * {
 *   "meta": { "student_name", "student_id", "birth_date", "cohort", "class_name", "major", "instructor", "subject_name", "subject_code", "year" },
 *   "title": "Tên chủ đề",
 *   "assignment_type": "TIỂU LUẬN CUỐI KÌ" | "BÀI THI HẾT HỌC PHẦN",
 *   "preface": "Lời mở đầu...",
 *   "sections": [
 *     { "heading": "...", "level": 1, "content": "..." },
 *     { "heading": "...", "level": 2, "content": "..." }
 *   ],
 *   "references": [
 *     { "stt": 1, "author": "...", "year": 2020, "title": "...", "publisher": "...", "pages": "..." }
 *   ]
 * }
 */

import { readFileSync, writeFileSync } from "fs";
import {
  Document,
  Packer,
  Paragraph,
  TextRun,
  AlignmentType,
  HeadingLevel,
  PageBreak,
  Header,
  Footer,
  PageNumber,
  NumberFormat,
  LineRuleType,
  TabStopPosition,
  TabStopType,
  SectionType,
  TableOfContents,
} from "docx";

const FONT = "Times New Roman";
const BODY_SIZE = 28; // 14pt in half-points
const LINE_SPACING = 360; // 1.5 spacing

// Twips conversion: 1cm = 567 twips
const MARGINS = {
  top: 1134,    // 2cm
  bottom: 1134, // 2cm
  left: 1701,   // 3cm
  right: 1418,  // 2.5cm
};

const PAGE_WIDTH = 12240;
const PAGE_HEIGHT = 15840;

function parseArgs() {
  const args = process.argv.slice(2);
  if (args.length < 2) {
    console.error("Usage: node generate_essay.mjs <input.json> <output.docx>");
    process.exit(1);
  }
  return { inputPath: args[0], outputPath: args[1] };
}

function loadInput(inputPath) {
  const raw = readFileSync(inputPath, "utf-8");
  return JSON.parse(raw);
}

function createEmptyParagraph(size = BODY_SIZE) {
  return new Paragraph({
    spacing: { after: 0, line: LINE_SPACING, lineRule: LineRuleType.AUTO },
    children: [new TextRun({ font: FONT, size, text: "" })],
  });
}

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
          text: (meta.subject_name || "TÊN HỌC PHẦN").toUpperCase(),
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

  // Info block (left aligned)
  const infoLines = [
    { label: "Giảng viên", value: meta.instructor || "........................." },
    { label: "Học viên", value: meta.student_name || "........................." },
    { label: "Ngày sinh", value: meta.birth_date || "........................." },
    { label: "Mã học viên", value: meta.student_id || "........................." },
    { label: "Khoá", value: meta.cohort || "........................." },
    { label: "Ngành", value: meta.major || "........................." },
  ];

  for (const info of infoLines) {
    paragraphs.push(
      new Paragraph({
        alignment: AlignmentType.LEFT,
        spacing: { after: 0, line: LINE_SPACING, lineRule: LineRuleType.AUTO },
        indent: { left: 2268 }, // ~4cm indent
        children: [
          new TextRun({ font: FONT, size: BODY_SIZE, bold: true, text: `${info.label}: ` }),
          new TextRun({ font: FONT, size: BODY_SIZE, bold: true, text: info.value }),
        ],
      })
    );
  }

  paragraphs.push(createEmptyParagraph());
  paragraphs.push(createEmptyParagraph());
  paragraphs.push(createEmptyParagraph());

  // Footer: Hà Nội – Year
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

  const prefaceText = data.preface || "";
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
    const isH3 = section.level === 3;

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
          new TextRun({ text: section.heading }),
        ],
      })
    );

    // Section content paragraphs
    if (section.content) {
      const contentParagraphs = section.content.split("\n").filter((p) => p.trim());
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
          new TextRun({ font: FONT, size: BODY_SIZE, text: `${ref.author} ` }),
          new TextRun({ font: FONT, size: BODY_SIZE, text: `(${ref.year}). ` }),
          new TextRun({ font: FONT, size: BODY_SIZE, italics: true, text: `${ref.title}` }),
          new TextRun({ font: FONT, size: BODY_SIZE, text: `. ${ref.publisher}` }),
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

async function main() {
  const { inputPath, outputPath } = parseArgs();
  const data = loadInput(inputPath);

  const coverChildren = buildCoverPage(data);
  const tocChildren = buildTOC(data);
  const prefaceChildren = buildPreface(data);
  const contentChildren = buildContent(data);
  const refChildren = buildReferences(data);

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

  const buffer = await Packer.toBuffer(doc);
  writeFileSync(outputPath, buffer);
  console.log(`Essay generated: ${outputPath}`);
}

main().catch((err) => {
  console.error("Error generating essay:", err.message);
  process.exit(1);
});
