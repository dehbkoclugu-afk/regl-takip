# Bundled fonts

Nunito is the existing app font. The additional Noto fonts provide offline
Arabic, Devanagari and Simplified Chinese glyph coverage for the UI and PDF
reports. Each font's SIL Open Font License is included alongside it.

Sources (Google Fonts repository, retrieved 2026-10-23):
- https://github.com/google/fonts/tree/main/ofl/notosansarabic
- https://github.com/google/fonts/tree/main/ofl/notosansdevanagari
- https://github.com/google/fonts/tree/main/ofl/notosanssc

Noto Sans SC was instantiated at `wght=400` with fontTools 4.67.0 to reduce
bundle size while retaining the complete source character map. Arabic and
Devanagari use their original variable TTF files. Fonts are bundled without
runtime downloads. Glyph coverage alone does not guarantee correct Indic
shaping in the PDF library; visually check complex Hindi report text before
store release.
