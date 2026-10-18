# Politecnico di Milano (PoliMi) package: design report

Status: **classical format implemented** (2026-10-10), following the
decisions below. `article` and `summary` are declared but give a
"not implemented yet" error.

## Article format (2026-10-18)

Implemented on the real `article` class (11pt, A4), chosen in
`academicthesis-polimi.cfg` when `format=article`. The core was made
class-aware instead of emulating article on book: front-matter headings
use `\section*` when there is no `\chapter`, `\frontmatter`/`\mainmatter`/
`\backmatter` get light versions under article, and keywords go through
the `\thesiskeywords` hook. LUISS and PoliMi classical showcases were
compared pixel by pixel before and after: identical.

Layout (`academicthesis-polimi-article.def`, after the official
`Thesis_article_format`): 2cm margins, no indentation, page number centred
in the footer, blue section/subsection titles, caption labels and theorem
heads (numbered by section), raggiera top right of page 1 at 40%.
`\frontpage` prints a header block on page 1 (logo, title, programme,
"author, ID", advisor/co-advisors/academic year beside the abstract, and
the keywords in a `bluepoli!60` box); the text follows on the same page.
The English abstract is metadata (`\thesissetup{abstract=..., keywords=...}`,
required for this format); the Italian abstract is
`\begin{abstractthesis}[language=italian, keywords=...]`, rendered as a
section with the same keywords box. Not reproduced: the template's
`enumitem` list settings and table/algorithm helpers (user's choice, as
for classical).

## Decisions taken (supersede the proposals further down)

- **Second page**: core option `secondpage` / `no-secondpage`; each
  university sets its default in its `.cfg` (`\DeclareThesisSecondPage`).
  LUISS: on by default. PoliMi: off by default.
- **Base class**: no longer fixed in the core. Each university declares it
  in `academicthesis-<uni>.cfg`, read before `\LoadClass`
  (`\DeclareThesisBaseClass`). LUISS: `book`. PoliMi: `book` for classical
  (12pt, twoside, a4paper), `article` later for article/summary.
- **Format**: core `format=` option + `\DeclareThesisFormats`.
- **Names**: PoliMi uses the core metadata names unchanged (`candidate`,
  `idnumber`, `degree`, `supervisors`, `cosupervisors`, `academicyear`).
  PoliMi wording ("Advisor", "Student ID", "Author") only changes string
  text, through `academicthesis-polimi-<lang>.ldf` using the core keys.
- **Degrees**: bachelor ("Tesi di Laurea Triennale" / "Bachelor's Thesis")
  and master ("Tesi di Laurea Magistrale" / "Master's Thesis"); PhD later.
- **Strings**: Italian in Italian, English in English (including the
  cover line).
- **No school option**: the 3I look is the PoliMi standard.
- **Logos**: shipped in `universities/polimi/` (PDF, converted from the
  template's EPS).
- **Bibliography**: nothing in the PoliMi package; the user configures it.
- **Acknowledgements** (D6): redefined by the PoliMi package.
- **hyperref** (D7): not loaded; the layout only uses `\phantomsection` when
  the user loads hyperref.
- **Extra packages** (D9): left to the user. PoliMi loads only what its
  layout needs: titlesec, caption, setspace, eso-pic, transparent, amsthm.

Reference used: the official School 3I templates in
`~/Desktop/Formati Tesi Scuola 3i - Latex/` (October 2021 revision):

| Folder | What it is | Base class |
| --- | --- | --- |
| `Thesis_classical_format/` | Classical MSc thesis (`PoliMi3i_thesis.cls` + `config.tex`) | `book`, 12pt, twoside |
| `Thesis_article_format/` | Article-style MSc thesis | `article`, 11pt, 2cm margins |
| `Executive_Summary/` | Executive summary | `article`, 11pt, `twocolumn` |

Target user interface:

```latex
\documentclass[university=polimi, master, format=classical, language=english]{academicthesis}
\polimithesissetup{ school = 3i }            % optional, 3i is the default
\thesissetup{
  title        = {Title},
  candidate    = {Name Surname},
  idnumber     = {000000},
  degree       = {Xxxxxxx Engineering - Ingegneria Xxxxxxx},  % PoliMi "course"
  supervisor   = {Prof. Name Surname},                         % PoliMi "advisor"
  cosupervisors= {Name Surname, Name Surname},                 % PoliMi "co-advisors"
  academicyear = {20XX-XX},
}
\begin{document}
\frontpage
\frontmatter
\begin{abstractthesis}[keywords = {here, the keywords}] ... \end{abstractthesis}
\begin{abstractthesis}[language = italian, keywords = {qui, le parole chiave}] ... \end{abstractthesis}
\tableofcontents
\mainmatter
\chapter{Chapter one} ...
\end{document}
```

---

## 1. What the classical format actually does

Read from `PoliMi3i_thesis.cls`, `config.tex`, `Thesis.tex` and the compiled `Thesis.pdf`.

**Page and text**
- `book`, **12pt**, **twoside**, A4. Geometry `inner=3cm, outer=2cm, top=2.5cm, bottom=2.5cm, includehead, headheight=0.6cm`.
- `\onehalfspacing` (setspace) from `\startpreamble` on; `parskip` with `\parindent=0pt`; `\raggedbottom`.
- Captions: label bold and `bluepoli` (figure, table, algorithm), 1.5 spacing.

**Colour**
- `\definecolor{bluepoli}{cmyk}{0.4,0.1,0,0.4}`. Used for: chapter number and bar, section/subsection/subsubsection titles, caption labels, theorem heads, header bar, title-page title and course line, and optionally `\rowcolor{bluepoli!40}` in tables.

**Headings**
- Chapter: `hang` shape, huge bold number in `bluepoli`, then a `bluepoli` vertical bar `|`, then the title in `\huge\bfseries` `bluepoli` (rendered as **"1| Chapter one"**).
- Section/subsection/subsubsection: `bluepoli`, bold, number followed by a dot (`1.1.`), with custom `\titlespacing`.
- Theorems: style `colored` (head `bluepoli` bold, body italic), `theorem` and `proposition` numbered by chapter.

**Running headers** (fancyhdr, no rules)
- Outer side: page number. Inner side: bold `"<num>| <chapter title>"`, with the bar in `bluepoli`; starred chapters show `"| <title>"`.
- Every chapter is preceded by `\cleardoublepage` + `\phantomsection`; starred chapters are added to the ToC.

**Watermark ("raggiera")**
- `raggiera_polimi.eps` drawn with eso-pic at 40% opacity (`transparent`).
- Cover: top-right, 70% of paper width.
- Every **blank verso page** produced by `\cleardoublepage`: centred, 85% of paper width (the template redefines `\cleardoublepage` for this).

**Title page** (`\puttitle{...}`)
- School logo (`02_ING_IND_INFORMAZIONE_COL_POSITIVO.eps`, i.e. School 3I), left-aligned, 70% width.
- Title `\huge\bfseries` `bluepoli`; then small caps `bluepoli` "Tesi di Laurea Magistrale in <course>" (always Italian); then "Author: **Name**".
- Bottom block, plain text lines: `Student ID`, `Advisor`, `Co-advisors` (comma list), `Academic Year`.
- No second page (no commission, no copyright page).

**Front matter**: roman numbering; Abstract (English) + "Abstract in lingua italiana", each ending with bold `Keywords:` / `Parole chiave:`; ToC. **Back matter**: bibliography (natbib, numeric, square, sort&compress, `abbrvnat`), appendices, list of figures/tables, list of symbols, acknowledgements (plain unstarred `\chapter*` at the very end).

**Article format** (for later, from the uploaded `config.tex` / `title_page.tex`): 2cm margins, `bluePoli` (same CMYK), coloured section/subsection titles, caption labels and theorem heads, raggiera at 40%, `\parindent 0pt`, centred page number in the footer, no rules; title page with logo, `bluePoli` title, "Tesi di Laurea Magistrale in \course", author + ID, then two columns (advisor/co-advisors/academic year | abstract) and a `bluePoli!60` tcolorbox with the keywords. The executive summary is the same idea in `twocolumn`.

---

## 2. How PoliMi maps onto the core

| PoliMi template | Core today | Mapping |
| --- | --- | --- |
| `title` | `title` | same |
| `name` | `candidate` | same meaning |
| `ID` | `idnumber` | same |
| `course` | `degree` | reuse `degree` (core already requires it for `master`) |
| `advisor` | `supervisor(s)` list | reuse; label string becomes "Advisor" via PoliMi strings |
| `coadvisor` | `cosupervisor(s)` list | reuse; printed comma-joined with `\academicthesislist[, ]{cosupervisors}` |
| `academicyear` | `academicyear` | same |
| `\puttitle` | `\frontpage` | register with `\DeclareThesisFrontPage{polimi}{master}{...}` |
| Abstract + keywords | `abstractthesis` env (no keywords) | needs a keywords option (see §4) |
| Italian abstract | none | needs a language option on `abstractthesis` (see §4) |
| Colours, headings, headers, captions, theorems | not in core | PoliMi package (or core "accent colour", §4) |
| Raggiera watermark | not in core | PoliMi package (or core "watermark", §4) |
| `natbib` numeric | biblatex + `\DeclareThesisBibDefaults` | `\DeclareThesisBibDefaults{polimi}{style=numeric-comp, sorting=none, backend=biber}` (closest biblatex match) |
| Acknowledgements | core `acknowledgements` env (italic, own page style) | use the core env; see doubt D6 |

What fits without touching the core: metadata, front-page registration, requirements, bib defaults, colours, `titlesec`/`caption`/`thmtools` setup, page styles (redefined with `\AtEndOfClass` because, see below, the core defines its styles *after* loading the plugin), watermark.

What does **not** fit without a core change (these are blockers for a faithful classical format):

1. **The second page is always printed.** `\frontpage` always calls `\__academicthesis_secondpage:` (commission + copyright). PoliMi has no such page. Needs an opt-out the plugin can set.
2. **The plugin cannot set the base class options.** The plugin loads *after* `\LoadClass{book}`, so it cannot make 12pt the default (the core only forwards what the user typed). Today the user would have to write `12pt` themselves. The same seam is what the `article` format needs (different base class), so it is worth solving once.
3. **No `format` option exists.** Passing `format=classical` today falls into the `unknown` handler and is forwarded to `book` as an unused option.
4. **Core definitions come after the plugin.** Page styles (`Thesis`, `plain`, `acknowledgments`), `abstractthesis`, `\thesisfrontchapter`, the `\frontmatter`/`\mainmatter` hooks are all defined in sections 9 to 10, after the plugin is loaded in section 5, so a plugin override made at load time is silently overwritten. Workable with `\AtEndOfClass`, but it should be a documented hook.

---

## 3. The `format` option

### Proposal: a generic core key, validated by the plugin

```latex
\documentclass[university=polimi, master, format=classical]{academicthesis}
```

- **Core** (`academicthesis.cls`): new key `format .tl_gset:N = \g__academicthesis_format_tl`, empty by default. The core does not interpret it; it only stores it (like `university`).
- **Kernel**: new registry
  `\DeclareThesisFormats{<uni>}{<available formats>}{<default>}`.
  The kernel fills in the default when the user gives none, and raises a clear error for an unknown value ("format 'foo' is not offered by academicthesis-polimi; available: classical").
- **Plugin**: declares `\DeclareThesisFormats{polimi}{classical, article, summary}{classical}` and, for the two not yet implemented, raises a specific error: "PoliMi format 'article' is not implemented yet".
- **Code layout in the plugin folder**: one file per format, loaded by the main package:
  `academicthesis-polimi.sty` (shared: colour, metadata, strings, logos, watermark) +
  `academicthesis-polimi-classical.def` (+ later `-article.def`, `-summary.def`).
  This keeps the classical work independent of the later article work.

Why a core key rather than a PoliMi-only key: other universities also have more than one official layout (e.g. "compilativa" vs "sperimentale", short vs long PhD formats), and the core needs to know the format *before* `\LoadClass` to pick the base class for `article`/`summary`.

### What `article` and `summary` will need later (not in this round)
- Base class `article` instead of `book` (and `twocolumn` for summary), chosen before `\LoadClass` from university+format.
- Core helpers that assume `book` (`\chapter*` in `\thesisfrontchapter`, `\frontmatter`/`\mainmatter`/`\backmatter`, the `acknowledgements` env) must degrade to `\section*` and no-ops.
- A front-page variant that includes the abstract and the keywords box, so the abstract is metadata or a box, not only a chapter.

---

## 4. PoliMi features worth making generic core features

Ordered by how many universities would plausibly use them.

| # | Feature | Generic design | Used by PoliMi for |
| --- | --- | --- | --- |
| G1 | **Second page opt-out** | Kernel registry `\DeclareThesisSecondPage{<uni>}{none \| default \| <cs>}`; core `\frontpage` dispatches like the front page. | No commission/copyright page. Blocker. |
| G2 | **Early university defaults** | A tiny `academicthesis-<uni>.cfg` read *before* `\LoadClass` (only `\PassOptionsToClass`, base-class choice per format, defaults). Main `.sty` still loads after. | 12pt + twoside default; later `article` base class. Blocker for faithful classical. |
| G3 | **Format option** | §3. | classical / article / summary. |
| G4 | **University accent colour** | `\DeclareThesisAccentColor{<uni>}{<model>}{<spec>}` defines colour `thesisaccent`; core options `accent-headings`, `accent-captions`, `accent-theorems` (bool keys) apply it through `titlesec`, `caption`, `thmtools`. LUISS could use it too (it already colours the title and lettrine with `BlueLuiss`). | `bluepoli` on headings, captions, theorem heads. |
| G5 | **Background watermark** | `\thesiswatermark[<opacity>, width, position = center\|top-right\|...]{<image>}` on top of eso-pic + transparent, plus a key "on blank pages" that decorates pages produced by `\cleardoublepage`. | Raggiera on cover (top-right) and blank verso pages (centred). |
| G6 | **Abstract with keywords and language** | `abstractthesis` gains an optional key list: `keywords = {...}`, `language = italian` (switches the heading string and the "Keywords" string; uses babel `otherlanguage`), `keywords-style = line \| box` (box = tcolorbox in accent colour, for the article format). | English + Italian abstracts with keywords, later the keywords box. |
| G7 | **Advisor / co-advisor lists with labels** | Already mostly there (`supervisors`, `cosupervisors`, `\supervisorlabel`, `\cosupervisorlabel`). Add a separator option and a terminology switch (`supervisor` vs `advisor` strings) instead of hard-coding "Supervisor". | "Advisor:", "Co-advisors: A, B". |
| G8 | **Per-university strings** | Kernel loads `academicthesis-<uni>-<lang>.ldf` after the generic `.ldf` when it exists (the English `.ldf` header already suggests this). | "Tesi di Laurea Magistrale in", "Advisor", "Author", "Student ID", "Keywords" / "Parole chiave". |
| G9 | **Chapter heading style presets** | Optional core key `chapter-style = default \| bar \| ...` where `bar` is the PoliMi "1\| Title" look; headers can follow the same preset. | Chapter look and running headers. Lower priority: could stay PoliMi-only. |

My recommendation for this round: do **G1, G2, G3** in the core (they are blockers or the seam for `article`), and **G6 (keywords + language)** and **G8** because they are small and the classical format needs them. Implement G4, G5, G7, G9 *inside the PoliMi package* now, written so they can be lifted into the core later without changing the user interface.

---

## 5. Differences from LUISS

| Aspect | LUISS | PoliMi classical |
| --- | --- | --- |
| Degrees | bachelor, master, phd | master only ("Tesi di Laurea Magistrale"); School 3I |
| Formats | one | three (classical / article / summary) |
| Scope of styling | front page only (+ lettrine colour) | whole document: headings, headers, captions, theorems, blank pages |
| Base options | user's choice | 12pt, twoside, inner 3cm / outer 2cm |
| Second page | commission + copyright (core default) | none |
| Front page | logo, course + chair, title, three name columns, academic year | school logo, title, "Tesi di Laurea Magistrale in ...", author, bottom list (ID, advisor, co-advisors, A.Y.) |
| Watermark | none | raggiera on cover and blank pages |
| Labels | Supervisor / Co-Supervisor / Candidate | Advisor / Co-advisors / Author / Student ID |
| Abstract | one, no keywords | English + Italian, both with keywords |
| Required fields | degree + chair (bachelor/master); cycle, department, phdtitle (phd) | degree (course), idnumber, supervisor |
| Bibliography | authoryear | numeric, compressed, order of citation |
| Paragraphs | indented | no indent + `parskip`, 1.5 spacing |
| Customisation command | `\luissthesissetup{...}` (alignments, logo) | `\polimithesissetup{school, logo-file, watermark=true/false}` |

---

## 6. Implementation plan for classical (after your go)

1. Core/kernel: G1 (second-page registry), G2 (`academicthesis-<uni>.cfg` read before `\LoadClass`), G3 (`format` key + `\DeclareThesisFormats`), G6 (keywords + language on `abstractthesis`), G8 (per-university `.ldf`). LUISS keeps working unchanged (its default second page is "default").
2. `universities/polimi/`: `academicthesis-polimi.cfg`, `academicthesis-polimi.sty`, `academicthesis-polimi-classical.def`, `academicthesis-polimi-english.ldf`, `academicthesis-polimi-italian.ldf`, and PDF assets converted from the template's EPS (`raggiera_polimi.pdf`, school 3I logo).
3. Showcase `showcases/example-polimi-classical.tex` mirroring the official `Thesis.tex` (cover, two abstracts, ToC, chapter with sections/figure/table/theorem, bibliography, appendix), plus a `{../universities/polimi/}` line in `academicthesis-repo-paths.tex`.
4. Compile both showcases (LUISS must stay identical) and compare the PoliMi output page by page with the official `Thesis.pdf`.
5. Update `doc/ARCHITECTURE.md` and the README.

**LaTeX3 pitfall.** Under `\ExplSyntaxOn`, spaces are ignored and blank lines do not end paragraphs, which is what lost spaces in the LUISS package. Rule for the PoliMi files: expl3 only for logic (keys, registries, dispatch); everything that typesets text (title page, `\titleformat`, page styles, caption/theorem setup) goes in a normal-catcode section (`\ExplSyntaxOff`, `\makeatletter`) and reads metadata through small 2e wrappers such as `\polimi@meta{title}`. Strings come only from `.ldf` files, which the kernel already reads with document catcodes.

---

## 7. Open doubts (need your input)

- **D1. Core changes in this round.** Do G1, G2, G3, G6, G8 in the core now (my recommendation), or keep the core untouched and accept workarounds (user types `12pt` and the extra page is suppressed by a hack inside the plugin)?
- **D2. Degrees.** Register only `master` (the template says "Laurea Magistrale"), or also `bachelor` with "Tesi di Laurea Triennale"? 3I bachelor theses ("prova finale") use a different template. Default: master only, clear error otherwise.
- **D3. Schools.** The template is School 3I (Ingegneria Industriale e dell'Informazione). Other PoliMi schools (AUIC, Design, ICAT) use other logos and possibly other rules. Default: a `school` key with only `3i` implemented and `logo-file` override.
- **D4. Logos and licence.** The PoliMi logos and raggiera are PoliMi's property (template marked "NC-BY"). Ship them in the repo (as LUISS does) or require the user to provide them? Default: ship them, as for LUISS, and note it in the README.
- **D5. Bibliography backend.** The template uses natbib + `abbrvnat`. The core prefers biblatex. Default: biblatex `numeric-comp`, which looks very close; natbib only if biblatex is missing (existing core fallback).
- **D6. Acknowledgements.** The core env is italic with its own header; PoliMi's is a plain `\chapter*` at the end. Default: keep the core env but let the plugin make it upright for PoliMi.
- **D7. hyperref/cleveref.** `doc/ARCHITECTURE.md` says the core loads hyperref last (section 7), but `academicthesis.cls` does not load it, nor `titlesec`, `setspace`, `microtype` which the doc also lists. PoliMi needs hyperref (black links) and `\phantomsection`. Default: load hyperref in the core with black links (benefits LUISS too) and fix the doc.
- **D8. Language.** The cover line "Tesi di Laurea Magistrale in" is Italian even in English theses, while labels ("Advisor", "Author") are English. Default: reproduce exactly that, with Italian labels when `language=italian`.
- **D9. Extra template commands.** The template also defines `\T`/`\B` table struts, `algsubstates`, `\blankpage`, and loads many packages (algorithm, empheq, subfig, tikz, longtable...). Default: provide `\blankpage` and the theorem/proposition envs; leave the other packages to the user's preamble, as the core does for LUISS.
