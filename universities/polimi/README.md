# academicthesis-polimi

> The same manual as a PDF: compile `academicthesis-polimi-doc.tex` in this
> folder with pdfLaTeX (twice, for the table of contents), or open
> `academicthesis-polimi-doc.pdf`.

Politecnico di Milano plugin for the `academicthesis` class. It reproduces the
three official thesis layouts of the School of Industrial and Information
Engineering (Scuola 3I, template revision October 2021), plus the PoliMi
doctoral dissertation:

| Format | What it is | Built on | Showcase |
| --- | --- | --- | --- |
| `classical` (default) | The full thesis as a book: cover page, abstracts, chapters | `book`, 12pt, two-sided, A4 | `showcases/example-polimi-classical.tex` |
| `article` | The thesis as a paper: header block with abstract on page 1, sections | `article`, 11pt, A4 | `showcases/example-polimi-article.tex` |
| `summary` | The Executive Summary: two columns, blue page header | `article`, 11pt, A4, two columns | `showcases/example-polimi-summary.tex` |
| `phd` | The doctoral dissertation (degree `phd`) | `book`, 10pt, two-sided, 17×24cm (or A4) | `showcases/example-polimi-phd.tex` |

You only choose `university=polimi` and a format; the package picks the right
base class, page layout, colours, cover and headings.

---

## 1. Quick start

```latex
\documentclass[university=polimi, master, format=classical, language=english]{academicthesis}

\thesissetup{
  title         = {Title},
  candidate     = {Name Surname},
  idnumber      = {000000},
  degree        = {Xxxxxxx Engineering - Ingegneria Xxxxxxx},
  supervisor    = {Prof. Name Surname},
  cosupervisors = {Name Surname, Name Surname},
  academicyear  = {2025-26},
}

\begin{document}
\frontpage

\frontmatter
\begin{abstractthesis}[keywords = {first, second, third}]
  English abstract.
\end{abstractthesis}
\begin{abstractthesis}[language = italian, keywords = {primo, secondo, terzo}]
  Abstract in italiano.
\end{abstractthesis}
\tableofcontents

\mainmatter
\chapter{Introduction}
...
\end{document}
```

The showcases in `showcases/` are complete, compilable examples of each
format; copying one is the fastest way to start.

---

## 2. Class options

All options go in `\documentclass[...]{academicthesis}`.

| Option | Values | Notes |
| --- | --- | --- |
| `university` | `polimi` | Loads this package. |
| degree | `bachelor`, `master`, `phd` | Bachelor/master print "Bachelor's / Master's Thesis in" (English) or "Tesi di Laurea Triennale / Magistrale in" (Italian). `phd` goes with `format=phd`. |
| `format` | `classical` (default), `article`, `summary`, `phd` | `phd` is the default when the degree is `phd`, and needs that degree. Any other value is an error that names the formats. |
| `language` | `english`, `italian`, ... | Main language of the thesis and of every label. |
| `other-languages` | e.g. `{french}` | Extra languages for blocks written in another language. English and Italian are always loaded for PoliMi, so the second abstract needs nothing here. |
| `secondpage` / `no-secondpage` | | PoliMi has no examination-commission / copyright page, so it is **off** by default; `secondpage` adds the core one. |
| `11pt`, `oneside`, ... | | Standard class options still work and win over the format's defaults (e.g. `11pt` in classical). |

---

## 3. Thesis data (`\thesissetup`)

PoliMi uses the **core names** of the class unchanged; only the printed
labels follow PoliMi's wording.

| Key | PoliMi meaning | Printed as (English / Italian) | classical | article | summary |
| --- | --- | --- | :-: | :-: | :-: |
| `title` | Title | | required | required | required |
| `subtitle` | Subtitle (optional) | | if set | if set | if set |
| `candidate` | Author | Author / Candidato | required | required | required |
| `idnumber` | Student ID (matricola) | Student ID / Matricola | required | required | not shown |
| `degree` | Study programme ("course") | after "Master's Thesis in" | required | required | required |
| `supervisor` or `supervisors` | Advisor(s) | Advisor(s) / Relatore, Relatori | required | required | required |
| `cosupervisor` or `cosupervisors` | Co-advisor(s), comma-separated | Co-advisor(s) / Correlatore, Correlatori | if set | if set | if set |
| `academicyear` | Academic year | Academic Year / Anno Accademico | required | required | required |
| `abstract` | English abstract printed on page 1 | Abstract | | **required** | |
| `keywords` | Keywords of that abstract | Keywords / Parole chiave | | in the blue box | |
| `gender` | `male` / `female` | Candidato / Candidata (Italian) | | | |

For `format=phd` the cover uses different data:

| Key | PoliMi PhD meaning | Printed as (English / Italian) | Required |
| --- | --- | --- | :-: |
| `title`, `subtitle` | Title (subtitle optional) | | title |
| `candidate` | Author | under "Doctoral Dissertation of" / "Tesi di Dottorato di" | yes |
| `department` | Department, as printed (e.g. `Department of Electronics, Information and Bioengineering`) | | yes |
| `phdtitle` | Doctoral programme, as printed (e.g. `Doctoral Program in Information Technology`) | | yes |
| `supervisor(s)` | Supervisor(s) | Supervisor(s) / Relatore, Relatori | yes |
| `tutor(s)` | Tutor(s) | Tutor(s) / Tutor | if set |
| `coordinator` | Chair of the doctoral programme | The Chair of the Doctoral Program / Il Coordinatore del Dottorato | if set |
| `academicyear`, `cycle` | Bottom line, e.g. "2025--2026 -- Cycle XXXVIII" | Cycle / Ciclo | yes |

Write "Prof." in the names yourself, as in the other formats.

A missing required key stops the compilation with a message that names it
and shows an example.

---

## 4. PoliMi options (`\polimithesissetup`)

```latex
\polimithesissetup{ logo-file = mylogo, watermark = false }
```

| Key | Default | Effect |
| --- | --- | --- |
| `logo-file` | `logopolimi3i` (Scuola 3I logo); `logopolimiseal` (round seal) for `phd` | Logo on the cover / first page. |
| `watermark` | `true` | The "raggiera" in the background (cover, first page, blank pages). Not used by `phd`. |
| `paper` | `17x24` | `phd` only: `17x24` (17×24cm, as in the template) or `a4`. |

---

## 5. Front-matter blocks

These come from the core class and work in every format; PoliMi only
changes their look.

| Block | Options | classical | article / summary |
| --- | --- | --- | --- |
| `\begin{abstractthesis}...` | `language`, `keywords`, `title` | Unnumbered chapter in the ToC; keywords as a bold line | Unnumbered section; keywords in a blue box |
| `\begin{originality}...` (statement of originality) | `language`, `title` | Unnumbered chapter | Unnumbered section |
| `\begin{acknowledgements}...` | `language`, `title` | Unnumbered chapter, upright text | Unnumbered section |
| `\dedication[language=..]{text}` | `language` | Own page, right-aligned italic | same |

`language=` switches the heading and the "Keywords" label to that language
(e.g. "Abstract in lingua italiana", "Parole chiave") and its hyphenation.
Without it, the main language is used.

---

## 6. The formats in detail

### 6.1 `classical`

What you get, as in `Thesis_classical_format`:

- **Page**: A4, 12pt, two-sided; inner margin 3cm, outer 2cm, top/bottom
  2.5cm; 1.5 line spacing; no paragraph indent, space between paragraphs.
- **Cover** (`\frontpage`): Scuola 3I logo, title in blue, "Master's Thesis
  in <degree>", "Author: <name>", and at the bottom Student ID, Advisor,
  Co-advisors, Academic Year. Raggiera at the top right.
- **Chapters**: big blue number and bar, "**1|** Chapter title". Starred
  chapters (`\chapter*{Introduction}`) are added to the table of contents
  and to the running header.
- **Running header**: page number outside, "1| Chapter title" inside, no
  rules. Chapter opening pages show only the page number, on the right.
- **Sections**: blue, numbered "1.1.", "1.1.1.".
- **Blank pages** left before a new chapter carry the raggiera; `\blankpage`
  inserts one by hand.
- **Front matter** in roman numbers (`\frontmatter`), main text in arabic
  (`\mainmatter`).

Typical order: `\frontpage`, `\frontmatter`, English and Italian abstracts,
`\tableofcontents`, `\mainmatter`, chapters, bibliography, `\appendix`,
lists of figures/tables, acknowledgements.

### 6.2 `article`

What you get, as in `Thesis_article_format`:

- **Page**: A4, 11pt, 2cm margins, no indent; page number centred at the
  bottom, no header.
- **Page 1** (`\frontpage`): no separate cover. A header block with logo,
  title, "Master's Thesis in <degree>", "<author>, <student ID>", a rule,
  then a narrow column (Advisor, Co-advisors, Academic Year) next to the
  **abstract**, and the **keywords** in a blue box. The text starts right
  after it on the same page.
- **Sections** instead of chapters: blue, "1.", "1.1.".

How to write it:

```latex
\documentclass[university=polimi, master, format=article]{academicthesis}
\thesissetup{
  ...,
  abstract = {The English abstract, printed on page 1.},
  keywords = {here, the keywords},
}
\begin{document}
\frontpage
\section{Introduction}
...
\appendix
\section{Appendix A}
\clearpage
\begin{abstractthesis}[language=italian, keywords={qui, le parole chiave}]
  Abstract in lingua italiana.
\end{abstractthesis}
\begin{acknowledgements} ... \end{acknowledgements}
\end{document}
```

The `article` class has no chapters. A `\chapter` still compiles (it is set
as a section, with one warning) so that a classical document can be
switched over, but use `\section` in this format.

### 6.3 `summary` (Executive Summary)

What you get, as in `Executive_Summary`:

- **Page**: A4, 11pt, two columns 30pt apart, 2cm side margins, no indent.
- **Page 1** (`\frontpage`): a full-width block across both columns with
  logo, "Executive Summary of the Thesis", title, "Master's Thesis in
  <degree>", Author, Advisor, Co-advisor(s), Academic Year and a rule; the
  two columns start right after it. Raggiera at the top right.
- **Following pages**: a blue box at the top with "Executive summary" on the
  left and the author on the right; page number centred at the bottom.
- **Sections**: blue, with tighter spacing than the article format.

The student ID is not printed, so it is not required here. As in the
template, the summary normally ends with a short essential bibliography.

### 6.4 `phd` (doctoral dissertation)

What you get, as in the PoliMi PhD template (`phdthesis.sty`, `phdtitle.sty`):

- **Page**: 10pt, two-sided, chapters on right-hand pages; 17×24cm with 2cm
  margins (top 2.3cm, 0.4cm binding offset), or A4 with
  `\polimithesissetup{paper=a4}`. Times for text, Helvetica for headings.
- **Cover** (`\frontpage`): PoliMi seal, "Politecnico di Milano", department
  and doctoral programme in small caps, a rule, the title, "Doctoral
  Dissertation of: <author>" on the right, then Supervisor, Tutor and Chair
  of the Doctoral Program on the left, and "<academic year> -- Cycle <cycle>"
  at the bottom.
- **Chapters**: fncychap "Sonny" style ("CHAPTER" and a big number, the
  title between two rules on the right).
- **Sections**: bold sans-serif with a rule underneath.
- **Running headers**: chapter on even pages, section on odd pages, bold
  sans-serif, with a rule; page numbers centred at the bottom. Blank pages
  are completely empty.
- **Front matter** in capital Roman numbers (`\frontmatter`).
- Captions with a bold label and italic text; a `defn` (Definition)
  environment numbered by chapter; grey three-line drop caps with
  `\lettrine`.

```latex
\documentclass[university=polimi, phd, format=phd]{academicthesis}
\thesissetup{
  title = {Title}, candidate = {Name Surname},
  department = {Department XXX}, phdtitle = {Doctoral Programme in YXYX},
  supervisor = {Prof. Name}, tutor = {Prof. Name}, coordinator = {Prof. Name},
  academicyear = {2025--2026}, cycle = {XXXVIII},
}
```

Not taken over from the template, on purpose: `psboxit` (not in TeX Live;
it only served commented-out page-number boxes), `fancybox` (unused), and
the template's `glossaries` setup (its `\glossarystyle` command no longer
exists). Load `glossaries`, `bnf`, `crop` (printer marks), `listings` and so on
yourself if you need them.

---

## 7. Colours, theorems and other commands

- `bluepoli` (CMYK 0.4, 0.1, 0, 0.4) is defined in every format; in
  `article` and `summary` it is also available as `bluePoli`, the name used
  by the official templates. Use it freely, e.g. `\rowcolor{bluepoli!40}`
  (needs `colortbl`).
- `theorem` and `proposition` environments are ready, with blue bold heads
  and italic text, numbered by chapter (classical) or section (article,
  summary). Further `\newtheorem`s use the same style.
- Figure and table caption labels are blue (bold in classical).
- `\blankpage` (classical): an empty page with the raggiera, not counted.

---

## 8. What the package loads, and what is up to you

Only what the layout needs is loaded, to avoid clashes:

| Format | Packages loaded |
| --- | --- |
| classical | titlesec, caption, setspace, eso-pic, transparent, amsthm |
| article | titlesec, caption, eso-pic, transparent, amsthm |
| summary | titlesec, caption, eso-pic, transparent, amsthm |
| phd | caption, amsthm, fncychap, titlesec, tocloft (fonts: Times / Helvetica / Courier, TeX Gyre clones with LuaLaTeX) |

The blue boxes (keywords, summary header) are drawn with `\colorbox`, so
tcolorbox and TikZ are not loaded; load them yourself if your text uses
them.

(The core class adds graphicx, geometry, fancyhdr, xcolor, amsmath,
lettrine, babel, and biblatex.)

Left to you, as in the official templates' "add your packages" section:
`hyperref` / `cleveref` (the layout works with or without them),
`amssymb`, `bm`, `float`, `colortbl`, `subfig`, `tikz`, `algorithm`,
`enumitem`, and the **bibliography**: the package sets no style, so
configure it in your preamble (e.g. `biblatex-options={style=numeric-comp}`
as a class option, then `\addbibresource{...}` and `\printbibliography`).

---

## 9. Languages and labels

The labels come from string files, so a thesis in Italian gets Italian
labels and one in English gets English labels:

| String | English | Italian |
| --- | --- | --- |
| Author | Author | Candidato / Candidata |
| Student ID | Student ID | Matricola |
| Advisor(s) | Advisor(s) | Relatore / Relatori |
| Co-advisor(s) | Co-advisor(s) | Correlatore / Correlatori |
| Thesis type | Bachelor's / Master's Thesis in | Tesi di Laurea Triennale / Magistrale in |
| Abstract heading | Abstract | Abstract in lingua italiana |
| Keywords | Keywords | Parole chiave |
| Summary line | Executive Summary of the Thesis | Executive Summary della Tesi |
| Theorem, Proposition | Theorem, Proposition | Teorema, Proposizione |
| PhD cover | Doctoral Dissertation of, Supervisor, Tutor, The Chair of the Doctoral Program | Tesi di Dottorato di, Relatore, Tutor, Il Coordinatore del Dottorato |
| Definition | Definition | Definizione |

To change a wording, edit `academicthesis-polimi-<language>.ldf` (or add a
file for a new language with the same keys).

---

## 10. Common errors

| Message | Cause | Fix |
| --- | --- | --- |
| `Unknown format 'classic' for university 'polimi'` | Typo in `format=` | Use `classical`, `article` or `summary`. |
| `Missing required thesis metadata: 'abstract'` | `format=article` without the abstract | Add `abstract={...}` (and `keywords={...}`) to `\thesissetup`. |
| `Missing required thesis metadata: 'idnumber'` | No student ID (classical, article) | Add `idnumber={...}`. |
| `format=phd is the PoliMi doctoral dissertation: use the 'phd' degree` | `format=phd` with `bachelor`/`master` | Use the `phd` degree option. |
| `No front page registered for university 'polimi', degree 'phd'` | `phd` degree with another format | Use `format=phd` (or leave `format` out). |
| `Missing required thesis metadata: 'department'` (or `phdtitle`, `cycle`) | PhD cover data missing | Add it to `\thesissetup`. |
| Warning: `The base class 'article' has no chapters` | `\chapter` in article or summary | Use `\section`. |
| Warning: `'french' ... was not loaded by babel` | A block with `language=french` | Add `other-languages={french}`. |

Compile with pdfLaTeX (the default). In Texifier/Texpad, set the typesetter
to TeX Live (pdfLaTeX), not the built-in engine.

---

## 11. For maintainers: how the package is organised

| File | Role |
| --- | --- |
| `academicthesis-polimi.cfg` | Read by the class **before** it loads its base class. Declares the formats (`\DeclareThesisFormats`), the base class and default options of each format, no second page, and English + Italian as extra languages. |
| `academicthesis-polimi.sty` | `\polimithesissetup`, required metadata, loads the packages of the chosen format, then reads that format's `.def`. |
| `academicthesis-polimi-classical.def` | Classical layout. |
| `academicthesis-polimi-article.def` | Article layout. |
| `academicthesis-polimi-summary.def` | Executive summary layout. |
| `academicthesis-polimi-phd.def` | PhD dissertation layout. |
| `academicthesis-polimi-english.ldf`, `-italian.ldf` | PoliMi wording of the core labels, plus PoliMi-only strings. |
| `logopolimi3i.pdf`, `raggierapolimi.pdf` | Logo and background, converted from the template's EPS. |
| `logopolimiseal.png` | Round PoliMi seal for the PhD cover. |

Rules to keep in mind when editing:

- The `.def` files are written in **normal LaTeX syntax** (they are read with
  document catcodes), so spaces and blank lines behave as usual. The `.sty`
  and `.cfg` use LaTeX3 syntax, where spaces are ignored (write `~`).
- **Never load a package from a `.def` file**: when that package ends, LaTeX
  switches LaTeX3 syntax back on and every following space is lost. Add the
  package to the format's list in the `.sty` instead.
- Each `.def` registers its own front page with
  `\DeclareThesisFrontPage{polimi}{bachelor|master}{...}` and changes core
  pieces (page styles, acknowledgements, keywords) directly: the core has
  defined them before loading this package.
- Pieces shared by classical, article and summary (colour, theorem style,
  section headings, watermark, blue box) live in
  `academicthesis-polimi-common.def`, read before the format's file.
- Metadata is read with the core accessors `\thesismeta{key}`,
  `\IfThesisMetaEmptyTF`, `\IfThesisListEmptyTF`, `\IfThesisDegreeTF`, and
  labels with `\thesisstring{Key}`.

Adding a format: add it to `\DeclareThesisFormats` and to the base-class
switch in the `.cfg`, list its packages in the `.sty`, and write
`academicthesis-polimi-<format>.def`.
