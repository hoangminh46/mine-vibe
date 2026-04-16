/**
 * format_essay.mjs — Format .docx files to academic standards (v2.0)
 *
 * Usage: node format_essay.mjs <input.docx> [output.docx] [--preview] [--config config.json]
 *
 * v2.0 enhancements:
 *   - Text justification (body text → justify)
 *   - Indentation normalization (fix excessive/insufficient indent)
 *   - Numbering font fix (numbering.xml → standard font)
 *   - Heading style formatting (bold, left-aligned, no indent)
 *   - TOC auto-update flag (settings.xml → updateFields)
 *
 * Flags:
 *   --preview              Analyze file and report issues without modifying
 *   --config <file.json>   Custom format config (font, size, margins, etc.)
 *                          If omitted, uses ĐH Giáo Dục defaults
 *
 * Principle: FORMAT ONLY — never modify text content
 */

import { readFileSync, writeFileSync, existsSync } from "fs";
import { basename, extname } from "path";
import JSZip from "jszip";
import { XMLParser, XMLBuilder } from "fast-xml-parser";

// ─── Default Format Standards (ĐH Giáo Dục) ────────────────────────────────────

const DEFAULT_STANDARD = {
  font: "Times New Roman",
  bodySize: 28,        // 14pt in half-points
  lineSpacing: 360,    // 1.5 line spacing
  lineRule: "auto",
  pageWidth: 11906,    // A4 210mm
  pageHeight: 16838,   // A4 297mm
  marginTop: 1134,     // 2cm
  marginBottom: 1134,  // 2cm
  marginLeft: 1701,    // 3cm
  marginRight: 1418,   // 2.5cm
};

// Active standard — overridden by config if provided
let STANDARD = { ...DEFAULT_STANDARD };

/**
 * Load custom config from JSON file.
 * Supports user-friendly units (pt, cm) and converts to OOXML values.
 */
function loadConfig(configPath) {
  if (!existsSync(configPath)) {
    console.error(`❌ Config file not found: ${configPath}`);
    process.exit(1);
  }

  let config;
  try {
    config = JSON.parse(readFileSync(configPath, "utf-8"));
  } catch (err) {
    console.error(`❌ Invalid JSON in config: ${err.message}`);
    process.exit(1);
  }

  const result = { ...DEFAULT_STANDARD };

  if (config.font) result.font = config.font;
  if (config.bodySize_pt) result.bodySize = Math.round(config.bodySize_pt * 2);

  if (config.lineSpacing) {
    const spacingMap = { 1: 240, 1.15: 276, 1.5: 360, 2: 480, 2.5: 600, 3: 720 };
    result.lineSpacing = spacingMap[config.lineSpacing] || Math.round(config.lineSpacing * 240);
  }

  if (config.pageSize) {
    const pageSizes = {
      A4: { w: 11906, h: 16838 },
      A5: { w: 8391, h: 11906 },
      Letter: { w: 12240, h: 15840 },
      Legal: { w: 12240, h: 20160 },
    };
    const size = pageSizes[config.pageSize];
    if (size) {
      result.pageWidth = size.w;
      result.pageHeight = size.h;
    } else {
      console.warn(`⚠️  Unknown page size "${config.pageSize}", keeping A4`);
    }
  }

  // 1cm = 567 twips
  if (config.marginTop_cm) result.marginTop = Math.round(config.marginTop_cm * 567);
  if (config.marginBottom_cm) result.marginBottom = Math.round(config.marginBottom_cm * 567);
  if (config.marginLeft_cm) result.marginLeft = Math.round(config.marginLeft_cm * 567);
  if (config.marginRight_cm) result.marginRight = Math.round(config.marginRight_cm * 567);

  return result;
}

// XML parser config — preserve attributes, CDATA, and order
const PARSER_OPTIONS = {
  ignoreAttributes: false,
  attributeNamePrefix: "@_",
  preserveOrder: true,
  cdataPropName: "__cdata",
  commentPropName: "__comment",
  trimValues: false,
  parseTagValue: false,
  numberParseOptions: { leadingZeros: false, hex: false },
};

const BUILDER_OPTIONS = {
  ignoreAttributes: false,
  attributeNamePrefix: "@_",
  preserveOrder: true,
  suppressEmptyNode: false,
  format: false,
};

// ─── CLI ────────────────────────────────────────────────────────────────────────

function parseArgs() {
  const args = process.argv.slice(2);
  const preview = args.includes("--preview");

  let configPath = null;
  const configIdx = args.indexOf("--config");
  if (configIdx !== -1 && args[configIdx + 1]) {
    configPath = args[configIdx + 1];
  }

  const positional = args.filter((a, i) =>
    a !== "--preview" && a !== "--config" && (configIdx === -1 || i !== configIdx + 1)
  );

  if (positional.length < 1) {
    console.error("Usage: node format_essay.mjs <input.docx> [output.docx] [--preview] [--config config.json]");
    process.exit(1);
  }

  const inputPath = positional[0];
  const ext = extname(inputPath).toLowerCase();
  if (ext !== ".docx") {
    console.error(`❌ Only .docx files are supported. Got: ${ext}`);
    process.exit(1);
  }

  const defaultOutput = inputPath.replace(/\.docx$/i, "_formatted.docx");
  const outputPath = positional[1] || defaultOutput;

  if (configPath) {
    STANDARD = loadConfig(configPath);
    console.log(`⚙️  Using custom config: ${basename(configPath)}`);
  } else {
    console.log("⚙️  Using default: ĐH Giáo Dục standard");
  }

  console.log(`   Font: ${STANDARD.font} | Size: ${STANDARD.bodySize / 2}pt | Spacing: ${(STANDARD.lineSpacing / 240).toFixed(1)}x`);
  console.log(`   Page: ${STANDARD.pageWidth === 11906 ? "A4" : "Custom"} | Margins: T${(STANDARD.marginTop / 567).toFixed(1)}/B${(STANDARD.marginBottom / 567).toFixed(1)}/L${(STANDARD.marginLeft / 567).toFixed(1)}/R${(STANDARD.marginRight / 567).toFixed(1)} cm`);

  return { inputPath, outputPath, preview };
}

// ─── Utility Functions ──────────────────────────────────────────────────────────

function twipsToMm(twips) {
  return (twips / 567).toFixed(1);
}

function twipsToCm(twips) {
  return (twips / 567).toFixed(1);
}

function halfPointsToPt(hp) {
  return (hp / 2).toFixed(1);
}

/**
 * Recursively find all nodes matching a tag name within an ordered XML tree.
 */
function findNodes(nodes, tagName) {
  const results = [];
  if (!Array.isArray(nodes)) return results;

  for (const node of nodes) {
    if (node[tagName] !== undefined) {
      results.push(node);
    }
    for (const key of Object.keys(node)) {
      if (key.startsWith("@_") || key === ":@" || key === "#text") continue;
      if (Array.isArray(node[key])) {
        results.push(...findNodes(node[key], tagName));
      }
    }
  }
  return results;
}

function getAttr(node, attrName) {
  if (node[":@"] && node[":@"][`@_${attrName}`] !== undefined) {
    return node[":@"][`@_${attrName}`];
  }
  return undefined;
}

function setAttr(node, attrName, value) {
  if (!node[":@"]) node[":@"] = {};
  node[":@"][`@_${attrName}`] = String(value);
}

function removeAttr(node, attrName) {
  if (node[":@"]) {
    delete node[":@"][`@_${attrName}`];
  }
}

function findChild(parentChildren, tagName) {
  if (!Array.isArray(parentChildren)) return null;
  return parentChildren.find((c) => c[tagName] !== undefined) || null;
}

function ensureChild(parentChildren, tagName) {
  let child = findChild(parentChildren, tagName);
  if (!child) {
    child = { [tagName]: [] };
    parentChildren.push(child);
  }
  return child;
}

/**
 * Remove a child node by tag name from parent children array.
 */
function removeChild(parentChildren, tagName) {
  if (!Array.isArray(parentChildren)) return;
  const idx = parentChildren.findIndex((c) => c[tagName] !== undefined);
  if (idx !== -1) parentChildren.splice(idx, 1);
}

// ─── Paragraph Helpers ──────────────────────────────────────────────────────────

function getParaStyleId(para) {
  const pChildren = para["w:p"];
  if (!pChildren) return null;
  const pPr = findChild(pChildren, "w:pPr");
  if (!pPr) return null;
  const pPrChildren = pPr["w:pPr"];
  if (!pPrChildren) return null;
  const pStyle = findChild(pPrChildren, "w:pStyle");
  if (!pStyle) return null;
  return getAttr(pStyle, "w:val");
}

function isHeadingStyleId(styleId) {
  if (!styleId) return false;
  return /^Heading\d+$/i.test(styleId);
}

function getHeadingLevel(styleId) {
  if (!styleId) return 0;
  const match = styleId.match(/^Heading(\d+)$/i);
  return match ? parseInt(match[1]) : 0;
}

function isTOCStyleId(styleId) {
  if (!styleId) return false;
  return /^(TOC\d+|TOCHeading|TableofFigures)$/i.test(styleId);
}

function hasNumbering(para) {
  const pChildren = para["w:p"];
  if (!pChildren) return false;
  const pPr = findChild(pChildren, "w:pPr");
  if (!pPr) return false;
  const pPrChildren = pPr["w:pPr"];
  if (!pPrChildren) return false;
  return findChild(pPrChildren, "w:numPr") !== null;
}

// ─── Analyzers ──────────────────────────────────────────────────────────────────

function analyzePageSetup(docParsed) {
  const issues = [];
  const sectPrs = findNodes(docParsed, "w:sectPr");

  for (const sectPr of sectPrs) {
    const children = sectPr["w:sectPr"];
    if (!children) continue;

    const pgSz = findChild(children, "w:pgSz");
    if (pgSz) {
      const w = parseInt(getAttr(pgSz, "w:w") || "0");
      const h = parseInt(getAttr(pgSz, "w:h") || "0");
      if (w !== STANDARD.pageWidth || h !== STANDARD.pageHeight) {
        issues.push({
          type: "page_size",
          current: `${twipsToMm(w)}×${twipsToMm(h)}mm`,
          expected: `${twipsToMm(STANDARD.pageWidth)}×${twipsToMm(STANDARD.pageHeight)}mm`,
        });
      }
    } else {
      issues.push({ type: "page_size", current: "Not set", expected: "A4" });
    }

    const pgMar = findChild(children, "w:pgMar");
    if (pgMar) {
      const margins = {
        top: parseInt(getAttr(pgMar, "w:top") || "0"),
        bottom: parseInt(getAttr(pgMar, "w:bottom") || "0"),
        left: parseInt(getAttr(pgMar, "w:left") || "0"),
        right: parseInt(getAttr(pgMar, "w:right") || "0"),
      };
      if (margins.left !== STANDARD.marginLeft) {
        issues.push({ type: "margin_left", current: `${twipsToCm(margins.left)}cm`, expected: `${twipsToCm(STANDARD.marginLeft)}cm` });
      }
      if (margins.right !== STANDARD.marginRight) {
        issues.push({ type: "margin_right", current: `${twipsToCm(margins.right)}cm`, expected: `${twipsToCm(STANDARD.marginRight)}cm` });
      }
      if (margins.top !== STANDARD.marginTop) {
        issues.push({ type: "margin_top", current: `${twipsToCm(margins.top)}cm`, expected: `${twipsToCm(STANDARD.marginTop)}cm` });
      }
      if (margins.bottom !== STANDARD.marginBottom) {
        issues.push({ type: "margin_bottom", current: `${twipsToCm(margins.bottom)}cm`, expected: `${twipsToCm(STANDARD.marginBottom)}cm` });
      }
    }
  }

  return issues;
}

function analyzeTypography(docParsed) {
  const issues = [];
  const fonts = new Set();
  const sizes = new Set();
  let singleSpacingCount = 0;
  let totalParagraphs = 0;

  const runs = findNodes(docParsed, "w:r");
  for (const run of runs) {
    const rChildren = run["w:r"];
    if (!rChildren) continue;

    const rPr = findChild(rChildren, "w:rPr");
    if (rPr) {
      const rPrChildren = rPr["w:rPr"];
      if (rPrChildren) {
        const rFonts = findChild(rPrChildren, "w:rFonts");
        if (rFonts) {
          const ascii = getAttr(rFonts, "w:ascii");
          const hAnsi = getAttr(rFonts, "w:hAnsi");
          const eastAsia = getAttr(rFonts, "w:eastAsia");
          if (ascii) fonts.add(ascii);
          if (hAnsi && hAnsi !== ascii) fonts.add(hAnsi);
          if (eastAsia && eastAsia !== ascii) fonts.add(eastAsia);
        }
        const sz = findChild(rPrChildren, "w:sz");
        if (sz) {
          const val = getAttr(sz, "w:val");
          if (val) sizes.add(parseInt(val));
        }
      }
    }
  }

  const paragraphs = findNodes(docParsed, "w:p");
  totalParagraphs = paragraphs.length;
  for (const para of paragraphs) {
    const pChildren = para["w:p"];
    if (!pChildren) continue;
    const pPr = findChild(pChildren, "w:pPr");
    if (pPr) {
      const pPrChildren = pPr["w:pPr"];
      if (pPrChildren) {
        const spacing = findChild(pPrChildren, "w:spacing");
        if (spacing) {
          const line = parseInt(getAttr(spacing, "w:line") || "0");
          if (line > 0 && line < STANDARD.lineSpacing) {
            singleSpacingCount++;
          }
        }
      }
    }
  }

  const nonStandardFonts = [...fonts].filter((f) => f !== STANDARD.font);
  if (nonStandardFonts.length > 0) {
    issues.push({
      type: "fonts",
      current: `Found ${fonts.size} font(s): ${[...fonts].join(", ")}`,
      expected: STANDARD.font,
    });
  }

  const nonStandardSizes = [...sizes].filter((s) => s !== STANDARD.bodySize);
  if (nonStandardSizes.length > 0) {
    issues.push({
      type: "sizes",
      current: `Found sizes: ${[...sizes].map((s) => `${s / 2}pt`).join(", ")}`,
      expected: `${STANDARD.bodySize / 2}pt`,
    });
  }

  if (singleSpacingCount > 0) {
    issues.push({
      type: "line_spacing",
      current: `${singleSpacingCount}/${totalParagraphs} paragraphs have tight spacing`,
      expected: `${(STANDARD.lineSpacing / 240).toFixed(1)}x line spacing`,
    });
  }

  return { issues, stats: { fonts: [...fonts], sizes: [...sizes], totalParagraphs } };
}

function analyzeAlignment(docParsed) {
  let nonJustified = 0;
  let total = 0;
  const paragraphs = findNodes(docParsed, "w:p");

  for (const para of paragraphs) {
    const styleId = getParaStyleId(para);
    // Headings and TOC entries have their own alignment rules
    if (isHeadingStyleId(styleId) || isTOCStyleId(styleId)) continue;

    total++;
    const pChildren = para["w:p"];
    if (!pChildren) { nonJustified++; continue; }
    const pPr = findChild(pChildren, "w:pPr");
    if (!pPr) { nonJustified++; continue; }
    const pPrChildren = pPr["w:pPr"];
    if (!pPrChildren) { nonJustified++; continue; }
    const jc = findChild(pPrChildren, "w:jc");
    if (!jc) { nonJustified++; continue; }
    const val = getAttr(jc, "w:val");
    if (val !== "both") nonJustified++;
  }

  return { nonJustified, total };
}

function analyzeIndentation(docParsed) {
  let excessive = 0;
  const paragraphs = findNodes(docParsed, "w:p");

  for (const para of paragraphs) {
    const styleId = getParaStyleId(para);
    if (isTOCStyleId(styleId)) continue;
    if (hasNumbering(para)) continue;

    const pChildren = para["w:p"];
    if (!pChildren) continue;
    const pPr = findChild(pChildren, "w:pPr");
    if (!pPr) continue;
    const pPrChildren = pPr["w:pPr"];
    if (!pPrChildren) continue;

    const ind = findChild(pPrChildren, "w:ind");
    if (ind) {
      const left = parseInt(getAttr(ind, "w:left") || "0");
      const firstLine = parseInt(getAttr(ind, "w:firstLine") || "0");
      // Flag paragraphs with excessive indent (>2cm left or >2cm firstLine)
      if (left > 1134 || firstLine > 1134) excessive++;
    }
  }

  return excessive;
}

function analyzeNumberingFonts(numberingParsed) {
  if (!numberingParsed) return { nonStandard: 0, fonts: [] };

  let nonStandard = 0;
  const fonts = new Set();

  const rFontsNodes = findNodes(numberingParsed, "w:rFonts");
  for (const rFonts of rFontsNodes) {
    const ascii = getAttr(rFonts, "w:ascii");
    if (ascii) {
      fonts.add(ascii);
      if (ascii !== STANDARD.font) nonStandard++;
    }
    const hAnsi = getAttr(rFonts, "w:hAnsi");
    if (hAnsi && hAnsi !== ascii) {
      fonts.add(hAnsi);
      if (hAnsi !== STANDARD.font) nonStandard++;
    }
  }

  return { nonStandard, fonts: [...fonts] };
}

// ─── Fixers ─────────────────────────────────────────────────────────────────────

function fixPageSetup(docParsed) {
  let fixed = 0;
  const sectPrs = findNodes(docParsed, "w:sectPr");

  for (const sectPr of sectPrs) {
    const children = sectPr["w:sectPr"];
    if (!children) continue;

    const pgSz = ensureChild(children, "w:pgSz");
    setAttr(pgSz, "w:w", STANDARD.pageWidth);
    setAttr(pgSz, "w:h", STANDARD.pageHeight);
    fixed++;

    const pgMar = ensureChild(children, "w:pgMar");
    setAttr(pgMar, "w:top", STANDARD.marginTop);
    setAttr(pgMar, "w:bottom", STANDARD.marginBottom);
    setAttr(pgMar, "w:left", STANDARD.marginLeft);
    setAttr(pgMar, "w:right", STANDARD.marginRight);
    setAttr(pgMar, "w:header", "720");
    setAttr(pgMar, "w:footer", "720");
    fixed++;
  }

  return fixed;
}

function fixRunFormatting(docParsed) {
  let fixed = 0;
  const runs = findNodes(docParsed, "w:r");

  for (const run of runs) {
    const rChildren = run["w:r"];
    if (!rChildren) continue;

    const rPr = ensureChild(rChildren, "w:rPr");
    const rPrChildren = rPr["w:rPr"];

    const rFonts = ensureChild(rPrChildren, "w:rFonts");
    setAttr(rFonts, "w:ascii", STANDARD.font);
    setAttr(rFonts, "w:hAnsi", STANDARD.font);
    setAttr(rFonts, "w:cs", STANDARD.font);

    const sz = ensureChild(rPrChildren, "w:sz");
    setAttr(sz, "w:val", STANDARD.bodySize);
    const szCs = ensureChild(rPrChildren, "w:szCs");
    setAttr(szCs, "w:val", STANDARD.bodySize);

    fixed++;
  }

  return fixed;
}

function fixParagraphSpacing(docParsed) {
  let fixed = 0;
  const paragraphs = findNodes(docParsed, "w:p");

  for (const para of paragraphs) {
    const pChildren = para["w:p"];
    if (!pChildren) continue;

    const pPr = ensureChild(pChildren, "w:pPr");
    const pPrChildren = pPr["w:pPr"];

    const spacing = ensureChild(pPrChildren, "w:spacing");
    setAttr(spacing, "w:line", STANDARD.lineSpacing);
    setAttr(spacing, "w:lineRule", STANDARD.lineRule);

    fixed++;
  }

  return fixed;
}

function fixStyles(stylesParsed) {
  let fixed = 0;
  if (!stylesParsed) return fixed;

  const styles = findNodes(stylesParsed, "w:style");
  for (const style of styles) {
    const styleChildren = style["w:style"];
    if (!styleChildren) continue;

    const styleType = getAttr(style, "w:type");
    const styleId = getAttr(style, "w:styleId");
    const headingLevel = getHeadingLevel(styleId);

    if (styleType === "paragraph") {
      // Step 1: Fix run properties (font, size) for all paragraph styles
      const rPr = ensureChild(styleChildren, "w:rPr");
      const rPrChildren = rPr["w:rPr"];

      const rFonts = ensureChild(rPrChildren, "w:rFonts");
      setAttr(rFonts, "w:ascii", STANDARD.font);
      setAttr(rFonts, "w:hAnsi", STANDARD.font);
      setAttr(rFonts, "w:cs", STANDARD.font);

      const sz = ensureChild(rPrChildren, "w:sz");
      setAttr(sz, "w:val", STANDARD.bodySize);
      const szCs = ensureChild(rPrChildren, "w:szCs");
      setAttr(szCs, "w:val", STANDARD.bodySize);

      // Step 2: Fix paragraph properties
      const pPr = ensureChild(styleChildren, "w:pPr");
      const pPrChildren = pPr["w:pPr"];

      // Line spacing for all paragraph styles
      const spacing = ensureChild(pPrChildren, "w:spacing");
      setAttr(spacing, "w:line", STANDARD.lineSpacing);
      setAttr(spacing, "w:lineRule", STANDARD.lineRule);

      // Step 3: Style-specific formatting
      if (headingLevel > 0) {
        // Heading styles: left-aligned, no indent, bold
        const jc = ensureChild(pPrChildren, "w:jc");
        setAttr(jc, "w:val", "left");

        // No indentation on headings
        const ind = findChild(pPrChildren, "w:ind");
        if (ind) {
          setAttr(ind, "w:left", "0");
          setAttr(ind, "w:firstLine", "0");
          removeAttr(ind, "w:hanging");
        }

        // Bold on all headings
        ensureChild(rPrChildren, "w:b");
        ensureChild(rPrChildren, "w:bCs");

        // Heading 3+: add italic
        if (headingLevel >= 3) {
          ensureChild(rPrChildren, "w:i");
          ensureChild(rPrChildren, "w:iCs");
        }
      } else if (!isTOCStyleId(styleId)) {
        // Body text styles: justified
        const jc = ensureChild(pPrChildren, "w:jc");
        setAttr(jc, "w:val", "both");
      }

      fixed++;
    }

    if (styleType === "character") {
      const rPr = findChild(styleChildren, "w:rPr");
      if (rPr) {
        const rPrChildren = rPr["w:rPr"];
        const rFonts = ensureChild(rPrChildren, "w:rFonts");
        setAttr(rFonts, "w:ascii", STANDARD.font);
        setAttr(rFonts, "w:hAnsi", STANDARD.font);
        setAttr(rFonts, "w:cs", STANDARD.font);

        fixed++;
      }
    }
  }

  // Fix document defaults
  const docDefaults = findNodes(stylesParsed, "w:docDefaults");
  for (const dd of docDefaults) {
    const ddChildren = dd["w:docDefaults"];
    if (!ddChildren) continue;

    const rPrDefault = findChild(ddChildren, "w:rPrDefault");
    if (rPrDefault) {
      const rPrDefaultChildren = rPrDefault["w:rPrDefault"];
      if (rPrDefaultChildren) {
        const rPr = ensureChild(rPrDefaultChildren, "w:rPr");
        const rPrChildren = rPr["w:rPr"];

        const rFonts = ensureChild(rPrChildren, "w:rFonts");
        setAttr(rFonts, "w:ascii", STANDARD.font);
        setAttr(rFonts, "w:hAnsi", STANDARD.font);
        setAttr(rFonts, "w:cs", STANDARD.font);
        setAttr(rFonts, "w:eastAsia", STANDARD.font);

        const sz = ensureChild(rPrChildren, "w:sz");
        setAttr(sz, "w:val", STANDARD.bodySize);
        const szCs = ensureChild(rPrChildren, "w:szCs");
        setAttr(szCs, "w:val", STANDARD.bodySize);

        fixed++;
      }
    }

    const pPrDefault = findChild(ddChildren, "w:pPrDefault");
    if (pPrDefault) {
      const pPrDefaultChildren = pPrDefault["w:pPrDefault"];
      if (pPrDefaultChildren) {
        const pPr = ensureChild(pPrDefaultChildren, "w:pPr");
        const pPrChildren = pPr["w:pPr"];

        const spacing = ensureChild(pPrChildren, "w:spacing");
        setAttr(spacing, "w:line", STANDARD.lineSpacing);
        setAttr(spacing, "w:lineRule", STANDARD.lineRule);

        // Default body text: justify
        const jc = ensureChild(pPrChildren, "w:jc");
        setAttr(jc, "w:val", "both");

        fixed++;
      }
    }
  }

  return fixed;
}

/**
 * v2.0: Set body text paragraphs to justified alignment.
 * Headings stay left-aligned. Centered text (titles) stays centered.
 */
function fixJustification(docParsed) {
  let fixed = 0;
  const paragraphs = findNodes(docParsed, "w:p");

  for (const para of paragraphs) {
    const pChildren = para["w:p"];
    if (!pChildren) continue;

    const styleId = getParaStyleId(para);

    // Headings → left-aligned (handled by fixStyles), skip here
    if (isHeadingStyleId(styleId)) continue;
    // TOC entries keep their own alignment
    if (isTOCStyleId(styleId)) continue;

    const pPr = ensureChild(pChildren, "w:pPr");
    const pPrChildren = pPr["w:pPr"];

    // Preserve center alignment (titles, headers)
    const existingJc = findChild(pPrChildren, "w:jc");
    const currentAlign = existingJc ? getAttr(existingJc, "w:val") : null;
    if (currentAlign === "center") continue;

    // Set body text to justified
    const jc = ensureChild(pPrChildren, "w:jc");
    setAttr(jc, "w:val", "both");
    fixed++;
  }

  return fixed;
}

/**
 * v2.0: Normalize excessive indentation on body text.
 * - Headings: no indent (left=0, firstLine=0)
 * - Body text: cap excessive indent, normalize to reasonable values
 * - Skip: TOC entries, numbered paragraphs (controlled by numbering definition)
 */
function fixIndentation(docParsed) {
  let fixed = 0;
  const paragraphs = findNodes(docParsed, "w:p");

  for (const para of paragraphs) {
    const pChildren = para["w:p"];
    if (!pChildren) continue;

    const styleId = getParaStyleId(para);

    // TOC entries have specific indentation per level — leave alone
    if (isTOCStyleId(styleId)) continue;
    // Numbered paragraphs get indent from numbering definition
    if (hasNumbering(para)) continue;

    const pPr = findChild(pChildren, "w:pPr");
    if (!pPr) continue;
    const pPrChildren = pPr["w:pPr"];
    if (!pPrChildren) continue;

    const ind = findChild(pPrChildren, "w:ind");
    if (!ind) continue;

    const left = parseInt(getAttr(ind, "w:left") || "0");
    const firstLine = parseInt(getAttr(ind, "w:firstLine") || "0");

    let needFix = false;

    if (isHeadingStyleId(styleId)) {
      // Headings: zero all indentation
      if (left > 0 || firstLine > 0) {
        setAttr(ind, "w:left", "0");
        setAttr(ind, "w:firstLine", "0");
        removeAttr(ind, "w:hanging");
        needFix = true;
      }
    } else {
      // Body text: normalize excessive indentation
      // >2cm left indent is almost certainly wrong for body text
      if (left > 1134) {
        setAttr(ind, "w:left", "0");
        needFix = true;
      }
      // >2cm first-line indent is excessive — cap at 1.27cm (720 twips)
      if (firstLine > 1134) {
        setAttr(ind, "w:firstLine", "720");
        needFix = true;
      }
    }

    if (needFix) fixed++;
  }

  return fixed;
}

/**
 * v2.0: Fix fonts in numbering.xml (heading numbers, list bullets).
 * This is why heading numbers stayed in Arial — numbering definitions
 * have their own font settings separate from paragraph/run formatting.
 */
function fixNumberingFonts(numberingParsed) {
  if (!numberingParsed) return 0;
  let fixed = 0;

  // Fix all w:rFonts in numbering definitions
  const rFontsNodes = findNodes(numberingParsed, "w:rFonts");
  for (const node of rFontsNodes) {
    const ascii = getAttr(node, "w:ascii");
    const hAnsi = getAttr(node, "w:hAnsi");

    if ((ascii && ascii !== STANDARD.font) || (hAnsi && hAnsi !== STANDARD.font)) {
      setAttr(node, "w:ascii", STANDARD.font);
      setAttr(node, "w:hAnsi", STANDARD.font);
      setAttr(node, "w:cs", STANDARD.font);
      fixed++;
    }
  }

  // Fix font sizes in numbering definitions
  const szNodes = findNodes(numberingParsed, "w:sz");
  for (const node of szNodes) {
    const val = getAttr(node, "w:val");
    if (val && parseInt(val) !== STANDARD.bodySize) {
      setAttr(node, "w:val", STANDARD.bodySize);
      fixed++;
    }
  }

  const szCsNodes = findNodes(numberingParsed, "w:szCs");
  for (const node of szCsNodes) {
    const val = getAttr(node, "w:val");
    if (val && parseInt(val) !== STANDARD.bodySize) {
      setAttr(node, "w:val", STANDARD.bodySize);
      fixed++;
    }
  }

  return fixed;
}

/**
 * v2.0: Set updateFields flag in settings.xml.
 * This makes Word prompt to update TOC (and other fields) on file open.
 */
function enableTOCUpdate(settingsParsed) {
  if (!settingsParsed) return 0;

  const settings = findNodes(settingsParsed, "w:settings");
  if (settings.length === 0) return 0;

  const settingsChildren = settings[0]["w:settings"];
  if (!settingsChildren) return 0;

  const updateFields = ensureChild(settingsChildren, "w:updateFields");
  setAttr(updateFields, "w:val", "true");

  return 1;
}

// ─── Report ─────────────────────────────────────────────────────────────────────

function printReport(pageIssues, typoResult, alignResult, indentResult, numResult) {
  console.log("\n📊 FORMAT ANALYSIS:");
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

  // Page Setup
  console.log("\nPage Setup:");
  const pageProblems = pageIssues.filter((i) => i.type);
  if (pageProblems.length === 0) {
    console.log("  ✅ Page setup is correct");
  } else {
    for (const issue of pageProblems) {
      console.log(`  ❌ ${issue.type}: ${issue.current} → should be ${issue.expected}`);
    }
  }

  // Typography
  console.log("\nTypography:");
  const { issues: typoIssues, stats } = typoResult;
  if (typoIssues.length === 0) {
    console.log("  ✅ Typography is correct");
  } else {
    for (const issue of typoIssues) {
      console.log(`  ❌ ${issue.type}: ${issue.current}`);
      console.log(`     → Will normalize to: ${issue.expected}`);
    }
  }

  // Alignment (v2.0)
  console.log("\nAlignment:");
  if (alignResult.nonJustified === 0) {
    console.log("  ✅ Body text is justified");
  } else {
    console.log(`  ❌ justify: ${alignResult.nonJustified}/${alignResult.total} body paragraphs not justified`);
    console.log(`     → Will set to: justify (both)`);
  }

  // Indentation (v2.0)
  console.log("\nIndentation:");
  if (indentResult === 0) {
    console.log("  ✅ Indentation is consistent");
  } else {
    console.log(`  ❌ indent: ${indentResult} paragraph(s) have excessive indentation`);
    console.log(`     → Will normalize indentation`);
  }

  // Numbering fonts (v2.0)
  console.log("\nNumbering:");
  if (numResult.nonStandard === 0) {
    console.log("  ✅ Numbering fonts are correct");
  } else {
    console.log(`  ❌ numbering_fonts: ${numResult.nonStandard} definition(s) use non-standard fonts`);
    console.log(`     Fonts found: ${numResult.fonts.join(", ")}`);
    console.log(`     → Will normalize to: ${STANDARD.font}`);
  }

  // Structure
  console.log(`\nStructure:`);
  console.log(`  📄 Total paragraphs: ${stats.totalParagraphs}`);

  const totalIssues = pageProblems.length + typoIssues.length
    + (alignResult.nonJustified > 0 ? 1 : 0)
    + (indentResult > 0 ? 1 : 0)
    + (numResult.nonStandard > 0 ? 1 : 0);

  console.log("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  if (totalIssues === 0) {
    console.log("✅ Document already meets format standards!");
  } else {
    console.log(`🔧 Found ${totalIssues} issue(s) to fix.`);
  }

  return totalIssues;
}

// ─── Main ───────────────────────────────────────────────────────────────────────

async function main() {
  const { inputPath, outputPath, preview } = parseArgs();

  console.log(`📖 Reading: ${basename(inputPath)}`);

  let buffer;
  try {
    buffer = readFileSync(inputPath);
  } catch (err) {
    console.error(`❌ Cannot read file: ${err.message}`);
    process.exit(1);
  }

  let zip;
  try {
    zip = await JSZip.loadAsync(buffer);
  } catch (err) {
    console.error(`❌ Invalid .docx file (not a valid ZIP): ${err.message}`);
    process.exit(1);
  }

  const parser = new XMLParser(PARSER_OPTIONS);

  // Step 1: Parse all needed XML files
  const docXml = await zip.file("word/document.xml")?.async("string");
  if (!docXml) {
    console.error("❌ No word/document.xml found — not a valid .docx");
    process.exit(1);
  }
  const docParsed = parser.parse(docXml);

  const stylesXml = await zip.file("word/styles.xml")?.async("string");
  const stylesParsed = stylesXml ? parser.parse(stylesXml) : null;

  // v2.0: Parse numbering.xml (heading numbers, list bullets)
  const numberingXml = await zip.file("word/numbering.xml")?.async("string");
  const numberingParsed = numberingXml ? parser.parse(numberingXml) : null;

  // v2.0: Parse settings.xml (for TOC update flag)
  const settingsXml = await zip.file("word/settings.xml")?.async("string");
  const settingsParsed = settingsXml ? parser.parse(settingsXml) : null;

  // Step 2: Analyze all aspects
  console.log("🔍 Analyzing format...");

  const pageIssues = analyzePageSetup(docParsed);
  const typoResult = analyzeTypography(docParsed);
  const alignResult = analyzeAlignment(docParsed);
  const indentResult = analyzeIndentation(docParsed);
  const numResult = analyzeNumberingFonts(numberingParsed);

  const totalIssues = printReport(pageIssues, typoResult, alignResult, indentResult, numResult);

  if (preview) {
    if (totalIssues > 0) {
      console.log(`\n💡 Run without --preview to apply fixes.`);
    }
    return;
  }

  if (totalIssues === 0) {
    console.log("\n✨ No changes needed.");
    return;
  }

  // Step 3: Apply all fixes
  console.log("\n⏳ Applying fixes...");

  const pageFixed = fixPageSetup(docParsed);
  console.log(`  ✅ Page setup: ${pageFixed} section(s) fixed`);

  let stylesFixed = 0;
  if (stylesParsed) {
    stylesFixed = fixStyles(stylesParsed);
    console.log(`  ✅ Styles: ${stylesFixed} style(s) updated`);
  }

  const runsFixed = fixRunFormatting(docParsed);
  console.log(`  ✅ Font/size: ${runsFixed} text run(s) normalized`);

  const parasFixed = fixParagraphSpacing(docParsed);
  console.log(`  ✅ Spacing: ${parasFixed} paragraph(s) fixed`);

  // v2.0 fixes
  const justifyFixed = fixJustification(docParsed);
  console.log(`  ✅ Justify: ${justifyFixed} paragraph(s) aligned`);

  const indentFixed = fixIndentation(docParsed);
  console.log(`  ✅ Indent: ${indentFixed} paragraph(s) normalized`);

  let numFixed = 0;
  if (numberingParsed) {
    numFixed = fixNumberingFonts(numberingParsed);
    console.log(`  ✅ Numbering: ${numFixed} definition(s) fixed`);
  }

  let tocFixed = 0;
  if (settingsParsed) {
    tocFixed = enableTOCUpdate(settingsParsed);
    if (tocFixed > 0) {
      console.log(`  ✅ TOC: Set auto-update flag`);
    }
  }

  // Step 4: Build and save all modified XML
  const builder = new XMLBuilder(BUILDER_OPTIONS);

  zip.file("word/document.xml", builder.build(docParsed));

  if (stylesParsed) {
    zip.file("word/styles.xml", builder.build(stylesParsed));
  }

  if (numberingParsed) {
    zip.file("word/numbering.xml", builder.build(numberingParsed));
  }

  if (settingsParsed) {
    zip.file("word/settings.xml", builder.build(settingsParsed));
  }

  console.log("📦 Saving...");
  const outputBuffer = await zip.generateAsync({ type: "nodebuffer" });
  writeFileSync(outputPath, outputBuffer);

  const totalFixed = pageFixed + stylesFixed + runsFixed + parasFixed + justifyFixed + indentFixed + numFixed;
  console.log(`\n✅ Formatted successfully!`);
  console.log(`   📄 Output: ${outputPath}`);
  console.log(`   🔧 Fixed: ${totalFixed} items`);
  console.log(`   📝 Content: UNTOUCHED ✓`);

  if (tocFixed > 0) {
    console.log(`\n📌 Khi mở file trong Word → Word sẽ hỏi cập nhật Mục lục.`);
    console.log(`   Chọn "Yes" để mục lục tự cập nhật theo heading mới.`);
  }
}

main().catch((err) => {
  console.error("❌ Error:", err.message);
  process.exit(1);
});
