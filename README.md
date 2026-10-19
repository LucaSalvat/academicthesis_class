# academicthesis

A modular LaTeX class for university theses. You pick your university,
your degree and, where there is a choice, the format; you write the data
of your thesis once; the class prints the cover page and the layout that
your university expects.

```latex
\documentclass[university=luiss, master, language=english]{academicthesis}
```

The project is a **collection of packages**: one core shared by everyone,
and one small package per university. You only need the core and the
package of your own university.

**Contents**

- [Universities](#universities)
  - [LUISS Guido Carli](#luiss-guido-carli)
  - [Politecnico di Milano](#politecnico-di-milano)
  - [Università Bocconi](#università-bocconi)
- [Quick start](#quick-start)
- [Repository layout](#repository-layout)
- [Compiling](#compiling)
- [Features shared by every university](#features-shared-by-every-university)
- [Adding a university](#adding-a-university)
- [License](#license)

---

## Universities

Each university has its own **user guide** (PDF, with the LaTeX source
next to it). Part I explains how to write a thesis with the package;
Part II explains the code, for those who want to change it.

| University | Degrees | Formats | User guide |
| --- | --- | --- | --- |
| [LUISS Guido Carli](#luiss-guido-carli) | bachelor, master, PhD | one | [PDF](userguides/academicthesis-luiss-guide.pdf) |
| [Politecnico di Milano](#politecnico-di-milano) | bachelor, master, PhD | classical, article, summary, phd | [PDF](userguides/academicthesis-polimi-guide.pdf) |
| [Università Bocconi](#università-bocconi) | bachelor, master | one, with or without a printed front page | [PDF](userguides/academicthesis-bocconi-guide.pdf) |

### LUISS Guido Carli

```latex
\documentclass[university=luiss, master, language=english]{academicthesis}
```

- **Package folder:** [`universities/luiss/`](universities/luiss/)
- **User guide:** [academicthesis-luiss-guide.pdf](userguides/academicthesis-luiss-guide.pdf)
  ([LaTeX source](userguides/academicthesis-luiss-guide.tex))
- **Examples:** [`example-luiss-bachelor.tex`](showcases/example-luiss-bachelor.tex),
  [`example-luiss-phd.tex`](showcases/example-luiss-phd.tex)
- **What you get:** the LUISS cover for bachelor's, master's and PhD
  theses, and a second page with the examination committee and copyright
  notice (switch it off with `no-secondpage`).

### Politecnico di Milano

```latex
\documentclass[university=polimi, master, format=classical]{academicthesis}
```

- **Package folder:** [`universities/polimi/`](universities/polimi/)
- **User guide:** [academicthesis-polimi-guide.pdf](userguides/academicthesis-polimi-guide.pdf)
  ([LaTeX source](userguides/academicthesis-polimi-guide.tex))
- **Examples:** [`classical`](showcases/example-polimi-classical.tex),
  [`article`](showcases/example-polimi-article.tex),
  [`summary`](showcases/example-polimi-summary.tex),
  [`phd`](showcases/example-polimi-phd.tex)
- **Formats:**

  | `format=` | What it is |
  | --- | --- |
  | `classical` (default) | The full thesis as a book |
  | `article` | The thesis as a paper, with the abstract on page 1 |
  | `summary` | The Executive Summary, in two columns |
  | `phd` | The doctoral dissertation (default for the `phd` degree) |

> **Credit.** The PoliMi layouts are not original work of this project.
> They reproduce the official LaTeX templates provided by Politecnico di
> Milano: the thesis templates of the School of Industrial and Information
> Engineering (Scuola 3I, October 2021 revision: classical format, article
> format, Executive Summary) and the PoliMi doctoral dissertation template
> by J. Stevens and L. Fossati. Their design, logos and graphic elements
> belong to Politecnico di Milano and to the templates' authors.
> For this reason the PoliMi package has its own licence,
> [LICENSE-POLIMI.md](LICENSE-POLIMI.md) (CC BY-NC), separate from the
> LPPL of the rest of the repository.

### Università Bocconi

```latex
\documentclass[university=bocconi, master, simil_frontpages=true]{academicthesis}
```

- **Package folder:** [`universities/bocconi/`](universities/bocconi/)
- **User guide:** [academicthesis-bocconi-guide.pdf](userguides/academicthesis-bocconi-guide.pdf)
  ([LaTeX source](userguides/academicthesis-bocconi-guide.tex))
- **Examples:** [`example-bocconi-bachelor.tex`](showcases/example-bocconi-bachelor.tex),
  [`example-bocconi-simil.tex`](showcases/example-bocconi-simil.tex)
- **What you get:** the opening pages of a Bocconi thesis. By default, two
  blank pages for the official front page that the university adds, then
  the dedication page. With `simil_frontpages=true`, a printed copy of the
  front page instead. The Bocconi logos are not included: put the official
  files next to your thesis, or the page prints text placeholders.

---

## Quick start

1. Copy the example of your university from [`showcases/`](showcases/).
2. Fill in your data in `\thesissetup{...}`:

   ```latex
   \thesissetup{
     title        = {Title of the Thesis},
     candidate    = {Name Surname},
     degree       = {Economics and Management},
     supervisor   = {Prof. Name Surname},
     academicyear = {2025/2026},
   }
   ```

3. Compile it from the `showcases/` folder:

   ```sh
   cd showcases
   latexmk -pdf my-thesis.tex
   ```

If a field your university needs is missing, compilation stops with a
message that names it. The user guide of your university lists every
field.

---

## Repository layout

| Folder | Contents |
| --- | --- |
| [`core/`](core/) | The core class, `academicthesis.cls`, and its shared API, `academicthesis-kernel.sty` |
| [`universities/`](universities/) | One folder per university: its package, labels and logos |
| [`languages/`](languages/) | The printed words, one file per language (English, Italian, French) |
| [`userguides/`](userguides/) | One user and developer guide per university, in LaTeX and PDF |
| [`showcases/`](showcases/) | Example theses that compile straight from the repository |
| [`doc/`](doc/) | [Architecture notes](doc/ARCHITECTURE.md) for developers |
| [`reports/`](reports/) | Design notes |

---

## Compiling

The packages find each other **by file name**, never by folder, so they can
be installed separately. Inside the repository, three ways work:

- **latexmk** (recommended): the root `latexmkrc` adds the source folders
  to TeX's search path.

  ```sh
  cd showcases
  latexmk -pdf example-luiss-bachelor.tex
  ```

- **Any editor** (Texifier/Texpad, TeXShop, TeXstudio, VS Code, Overleaf):
  every showcase starts with `\input{academicthesis-repo-paths}`, which
  adds the repository folders to LaTeX's search list. In Texifier, set the
  typesetter to *TeX Live (pdfLaTeX)*: its built-in engine is too old.
- **Plain pdflatex**, from `showcases/`:

  ```sh
  TEXINPUTS=../core//:../languages//:../universities//: pdflatex example-luiss-bachelor.tex
  ```

To use the class outside the repository, copy `core/`, `languages/` and
your university's folder next to your thesis, or into your personal TeX
tree (for example `~/Library/texmf/tex/latex/academicthesis/` on macOS).

**Requirements:** TeX Live or MacTeX 2023 or later (or an up-to-date
MiKTeX), pdfLaTeX, and biblatex with biber for the bibliography.

---

## Features shared by every university

- **One place for the data:** `\thesissetup{...}`, with the same key names
  at every university.
- **Clear errors** when a required field is missing.
- **Several languages in one thesis:** the abstract, statement of
  originality, acknowledgements and dedication each take `language=`, so
  an English thesis can carry an Italian abstract with the right heading
  and hyphenation.
- **Labels that adapt:** "Supervisor" or "Supervisors" by count, and in
  Italian "Candidato" or "Candidata".
- **A bibliography that always compiles:** biblatex and biber, with a
  natbib fallback behind the same commands.
- **Nothing imposed beyond the layout:** hyperref, TikZ and the
  bibliography style stay your choice.

---

## Adding a university

Create `universities/<uni>/` with `academicthesis-<uni>.cfg` and
`academicthesis-<uni>.sty`, add the folder to
`showcases/academicthesis-repo-paths.tex`, and add a showcase. Nothing in
the core or in the other universities changes. Part II of any user guide,
and [doc/ARCHITECTURE.md](doc/ARCHITECTURE.md), explain how.

---

## License

The repository uses **two licences**, both in this folder:

| What | Licence | File |
| --- | --- | --- |
| Everything except `universities/polimi/`: the core, the languages, the LUISS and Bocconi packages, the showcases and the user guides | LaTeX Project Public License 1.3c or later | [LICENSE](LICENSE) |
| `universities/polimi/`, the Politecnico di Milano package | Creative Commons Attribution-NonCommercial (CC BY-NC), the terms of the official PoliMi templates it adapts | [LICENSE-POLIMI.md](LICENSE-POLIMI.md) |

### LPPL part

Copyright 2025–2026 Luca Salvatore.

This work may be distributed and/or modified under the conditions of the
LaTeX Project Public License, either version 1.3c of this license or (at
your option) any later version. The license is in [LICENSE](LICENSE) and at
<https://www.latex-project.org/lppl.txt>.

This work has the LPPL maintenance status `maintained`. The Current
Maintainer of this work is Luca Salvatore. This work consists of all the
files of this repository except those in `universities/polimi/`.

### Politecnico di Milano part

The PoliMi package adapts the official LaTeX templates of Politecnico di
Milano (see [above](#politecnico-di-milano)) and is distributed under their
CC BY-NC terms: credit to Politecnico di Milano and the template authors,
and no commercial use. See [LICENSE-POLIMI.md](LICENSE-POLIMI.md).

### Names and logos

University names, logos and graphic elements belong to their respective
universities and are not licensed by this project. academicthesis is not
published by any of the universities it supports; always check your
university's current rules before submitting a thesis.
