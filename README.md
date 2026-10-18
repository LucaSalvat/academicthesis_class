# academicthesis_class
Modular LaTeX class for academic theses: one university-agnostic core
class plus independent plugin packages per university and per language.

```latex
\documentclass[university=luiss, bachelor, language=english]{academicthesis}
\documentclass[university=polimi, master, format=classical]{academicthesis}
```

| University | Degrees | Formats | Showcase |
| --- | --- | --- | --- |
| LUISS | bachelor, master, phd | (one) | `showcases/example-luiss-bachelor.tex` |
| [Politecnico di Milano](universities/polimi/README.md) | bachelor, master | `classical` (book), `article` (article), `summary` (executive summary, two-column article) | `showcases/example-polimi-classical.tex`, `-article.tex`, `-summary.tex` |

Each university picks its base class (LUISS and PoliMi classical: `book`; PoliMi article: `article`)
and whether the second page (commission + copyright) is printed: on for
LUISS, off for PoliMi; override with `secondpage` / `no-secondpage`.

Abstract, statement of originality (`originality`), acknowledgements and dedication take `language=`, so a thesis
can have, say, an English and an Italian abstract (list the extra
languages in `other-languages={italian,french}` for correct hyphenation).

## Repository layout

| Folder | Contents |
| --- | --- |
| `core/` | `academicthesis.cls` and `academicthesis-kernel.sty` |
| `universities/<uni>/` | `academicthesis-<uni>.sty` plus that university's logos |
| `languages/` | `academicthesis-<lang>.ldf` string files |
| `showcases/` | Example documents that compile straight from the repo |
| `doc/` | [Architecture and developer guide](doc/ARCHITECTURE.md) |

Packages load each other **by name**, never by folder, so they can be
installed separately. To build from the repo, the root `latexmkrc` adds
the folders to TeX's search path:

```sh
cd showcases
latexmk example-luiss-bachelor.tex
```

Any editor works too (Texifier/Texpad, TeXShop, TeXstudio): every showcase
starts with `\input{academicthesis-repo-paths}`, which adds the repo
folders to LaTeX's search list. In Texifier, set the typesetter to TeX Live
(pdfLaTeX), because its built-in engine is too old for this class.

Without latexmk, from a terminal:
`TEXINPUTS=../core//:../languages//:../universities//: pdflatex example-luiss-bachelor.tex`.
See [doc/ARCHITECTURE.md](doc/ARCHITECTURE.md#folders-are-for-humans-names-are-for-tex).
