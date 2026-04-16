# Content Guidelines — Essay Writer

## Writing Style

- Write in Vietnamese academic style
- Cite real, verifiable Vietnamese academic sources
- Each section must have substantive content (no placeholders)
- "Đặt vấn đề" must explain relevance and urgency
- "Nội dung chủ đề" is the core section — expand with sub-headings as needed
- References must follow format: STT, Author, Year, Title, Publisher, Pages
- Sort references alphabetically by author's first name (Vietnamese convention)
- **STRICT RULE: PURE VIETNAMESE ONLY**. When generating the content, absolutely DO NOT use English terms in parentheses next to Vietnamese terms (e.g., do NOT write "Siêu nhận thức (Metacognition)" or "Mô hình 5E (Engage - Explore...)"). You MUST translate everything fully into Vietnamese and omit the English terms entirely.
- When the user provides a NotebookLM outline, use it as the definitive factual source but strictly apply the "NO ENGLISH" rule above when expanding into the full essay.
- **STRICT RULE: NO INLINE CITATIONS**. Do NOT include any inline citations, parenthetical references, or source attributions within the essay body content. Examples of what is FORBIDDEN in the content:
  - ❌ `(Trần Văn Tính, 2020)`
  - ❌ `(Tèo, 2022)`
  - ❌ `Theo nghiên cứu của Hoàng Thị Ngà (2021)`
  - ❌ `[1]`, `[Nguồn: ...]`
  Sources must ONLY appear in the "Tài liệu tham khảo" (References) section at the end of the essay. The body text should read naturally without any citation markers. When referencing ideas from sources, weave them into the text seamlessly without attributing by name/year inline.

## Page Target (Dynamic)

The target page count is set by the user via `page_count` in `input.json`. There is no fixed default — ask the user how many pages they need.

Each page ≈ 300 words at 14pt/1.5 spacing.

### Formula

```
target_words = page_count × 300
```

### Word Count Distribution (proportional to target)

| Section | % of total | Example: 10 pages | Example: 20 pages |
|---------|-----------|--------------------|--------------------|
| Đặt vấn đề | ~8% | ~240 words | ~480 words |
| Mục đích viết chủ đề | ~8% | ~240 words | ~480 words |
| Phương pháp hoàn thiện | ~7% | ~210 words | ~420 words |
| Nội dung chủ đề (5.1 → 5.x) | ~67% | ~2,000 words | ~4,000 words |
| Kết luận / Định hướng | ~10% | ~300 words | ~600 words |

### Strategy for "Nội dung" Section (the core — ~67% of total)

Scale the depth based on target page count:

| Target | Sub-sections | Sub-sub-sections per sub |
|--------|-------------|--------------------------|
| 5-10 pages | 3-4 (5.1 → 5.4) | 1-2 |
| 10-15 pages | 4-5 (5.1 → 5.5) | 2-3 |
| 15-20 pages | 5-6 (5.1 → 5.6) | 2-3 |
| 20+ pages | 5-7 (5.1 → 5.7) | 2-3 |

General enrichment techniques (use more for longer essays):
1. Theoretical frameworks and definitions
2. Practical examples and case studies
3. Analysis of Vietnamese educational context
4. Comparison with international practices
5. Data, statistics, and research findings

## Handling Large Content

If input JSON is too large for a single generation, split content creation across multiple writes and merge into one JSON before running the script.

### Merge Strategy

1. Generate `sections` in 2-3 batches (e.g., sections 1-3, then 4-7)
2. Each batch must be valid JSON array of section objects
3. Concatenate arrays before writing final `input.json`
4. Verify section numbering continuity after merge
