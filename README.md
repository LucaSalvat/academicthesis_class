# academicthesis_class
Modular LaTeX class for academic theses: one university-agnostic core
class plus independent plugin packages per university and per language.

```latex
\documentclass[university=luiss, bachelor, language=english]{academicthesis}
```

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

Without latexmk:
`TEXINPUTS=../core//:../languages//:../universities//: pdflatex example-luiss-bachelor.tex`.
See [doc/ARCHITECTURE.md](doc/ARCHITECTURE.md#folders-are-for-humans-names-are-for-tex).
