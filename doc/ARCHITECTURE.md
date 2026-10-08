# academicthesis — Architecture & Developer Guide

## Overview

`academicthesis` is a modular LaTeX3 (expl3) thesis class. A single core
class (`academicthesis.cls`) provides all university-agnostic infrastructure;
per-university formatting lives in independent plugin packages
(`academicthesis-<uni>.sty`) that extend the core without modifying it.

```
\documentclass[university=luiss, bachelor, language=english]{academicthesis}
```

This single line loads the core class, which then automatically loads
`academicthesis-luiss.sty` and the appropriate language file.

---

## Project layout

```
academicthesis_class/
├── core/
│   ├── academicthesis.cls          Core class (university-agnostic)
│   └── academicthesis-kernel.sty   Shared API (metadata, messages, registries)
├── languages/
│   ├── academicthesis-english.ldf  English strings
│   └── academicthesis-italian.ldf  Italian strings
├── universities/
│   └── luiss/                      One folder per university plugin
│       ├── academicthesis-luiss.sty
│       ├── logoluissblue.pdf
│       └── luiss.pdf
├── showcases/                      Example documents / proofs
│   ├── example-luiss-bachelor.tex
│   ├── example.bib
│   ├── academicthesis-repo-paths.tex  Search path for any editor
│   └── latexmkrc                   Loads ../latexmkrc
├── latexmkrc                       Adds the source folders to TEXINPUTS
└── doc/
    └── ARCHITECTURE.md             (this file)
```

### Folders are for humans, names are for TeX

Every file is an independent package and is loaded **by name only**
(`\LoadClass`, `\RequirePackage{academicthesis-<uni>}`,
`\input{academicthesis-<lang>.ldf}`, `\includegraphics{logoluissblue}`).
No code ever mentions `core/`, `universities/` or `languages/`. That is
what lets a user install only the core plus the one university they need:
once installed in a texmf tree, kpathsea finds each file by name no matter
which package shipped it.

The repository folders are therefore purely organisational. For local
builds we make TeX see them the same way an installation would, by adding
them to the search path instead of changing the code:

- **latexmk** (recommended): the root `latexmkrc` adds
  `core//`, `languages//` and `universities//` to `TEXINPUTS` (the trailing
  `//` searches subfolders, so new universities and languages need no
  config change). `showcases/latexmkrc` reuses it, so
  `cd showcases && latexmk example-luiss-bachelor.tex` or, from the root,
  `latexmk -cd showcases/example-luiss-bachelor.tex` both work.
  Overleaf and VS Code LaTeX Workshop run latexmk, so they pick this up too.
- **Any editor, including Texifier/Texpad, TeXShop and TeXstudio**: each
  showcase starts with `\input{academicthesis-repo-paths}` before
  `\documentclass`. That file (in `showcases/`) only extends LaTeX's own
  search list `\input@path` with `../core/`, `../languages/` and each
  `../universities/<uni>/`, so it works whatever runs the build, with no
  environment variables. It lives in the showcase, never in a package.
  Two limits: `\input@path` does not search subfolders, so add a line there
  for each new university; and TeX's normal search comes first, so if you
  also *install* academicthesis in a texmf tree, the installed copy wins.
- **Plain pdflatex/lualatex** (no latexmk): set the variable yourself, e.g.
  from `showcases/`:
  `TEXINPUTS=../core//:../languages//:../universities//: pdflatex example-luiss-bachelor.tex`
  (the final `:` keeps the system search path; on Windows use `;`).

Adding a university = new folder `universities/<uni>/` with
`academicthesis-<uni>.sty` and its logos. Adding a language = new
`languages/academicthesis-<lang>.ldf`. Nothing else changes.

---

## Core class: `academicthesis.cls`

Processed top-to-bottom in numbered sections. All code lives inside a single
`\ExplSyntaxOn … \ExplSyntaxOff` block, so expl3 naming conventions
(`\module_function:Nn`, `\l__module_var_tl`) apply throughout.

| Section | What it does |
|---------|-------------|
| 1 — Class options | `\keys_define:nn {academicthesis/class}` declares `university`, `bachelor`/`master`/`phd`, `language`, `twoside`, `discussion`, `biblatex-options`. `\ProcessKeysOptions` populates the global state variables. |
| 2 — Font & language | Loads `fontenc`/`inputenc`/`lmodern` (pdfLaTeX) or `fontspec` (XeLaTeX/LuaLaTeX). Loads `babel` with the chosen language. **Note:** babel must be loaded with `_`/`:` catcodes temporarily restored to "other" (see comment in source). |
| 3 — Layout packages | `geometry`, `fancyhdr`, `titlesec`, `microtype`, `setspace`, `lettrine`, `xcolor`, `graphicx`, `amsmath`. |
| 4 — Bibliography | Prefers `biblatex`+`biber`; falls back to `natbib`+BibTeX if biblatex is unavailable, with a package warning. |
| 5 — University plugin | `\exp_args:NV \academicthesis_load_university:n \g__academicthesis_university_tl` — expands the stored university ID to a string and calls the loader defined in the kernel. |
| 6 — Page geometry | Two-sided vs one-sided layout, chapter/section heading styles via `titlesec`. |
| 7 — Hyperref | Loaded last (standard LaTeX practice). |
| 8 — Metadata API | `\thesissetup{key=value, …}` — user-facing command that dispatches to the kernel's metadata prop. |
| 9 — Front-matter helpers | `\frontmatter`, `\mainmatter`, `\backmatter`, abstract/dedication/acknowledgements environments. |

---

## Kernel: `academicthesis-kernel.sty`

Loaded by the class at the very beginning (before the `book` base class).
Provides the shared vocabulary that both the class and all plugins use.

### Metadata store

```latex
\academicthesis_meta_set:nn { key } { value }
\academicthesis_meta_get:n  { key }            % expands to value
\academicthesis_meta_if_empty:nTF { key } { true } { false }
```

A single `\prop` (`\g__academicthesis_meta_prop`) holds all metadata.
Standard keys: `title`, `subtitle`, `candidate`, `idnumber`, `degree`,
`chair`, `academicyear`, `supervisors`, `cosupervisor`, `copyyear`,
`authoremail`, `examdate`, `examiner`.

Plugins add their own keys using the same API — the core never reads
plugin-owned keys, so there is no coupling.

### University loader

```latex
\academicthesis_load_university:n { luiss }
```

Calls `\RequirePackage{academicthesis-luiss}`. The argument is the
literal university ID — not a tl-variable name. The class calls this via
`\exp_args:NV` to expand `\g__academicthesis_university_tl` to its
stored value before passing it. (Passing the variable name directly would
cause infinite expansion inside `\IfFileExists`.)

### Front-page registry

```latex
\DeclareThesisFrontPage { luiss } { bachelor } { \__luiss_frontpage_bachelor: }
```

Plugins call this to register their front-page commands. The core's
`\frontpage` command looks up `university.degree` in the registry and
calls whatever is registered there. If nothing is found, a clear error
is raised naming the missing combination.

### Requirement declarations

```latex
\DeclareThesisRequirement { luiss } { \c_true_bool } { supervisors } { Prof. X }
```

Plugins declare which metadata keys are mandatory for a given
university/degree. The core checks these at `\begin{document}` and
raises errors for missing required fields.

### Message system

All user-facing messages go through expl3's `\msg_*` layer:

```latex
\msg_new:nnnn  { academicthesis } { msg-name } { short text } { extended help }
\msg_error:nnn { academicthesis } { msg-name } { arg }
\msg_warning:nnn ...
```

---

## Writing a university plugin

Create `academicthesis-<uni>.sty`. The plugin is a standard LaTeX package
and may use `\ExplSyntaxOn` freely. It has access to the full kernel API
from the moment it is loaded (the kernel is always loaded before any
plugin).

### Minimal plugin skeleton

```latex
\NeedsTeXFormat{LaTeX2e}
\ProvidesPackage{academicthesis-myuni}[2026/01/01 v0.1 My University plugin]
\RequirePackage{academicthesis-kernel}

\ExplSyntaxOn

% 1. Declare any extra metadata keys
\keys_define:nn { academicthesis-myuni / meta }
  {
    department .code:n = { \academicthesis_meta_set:nn { myuni-department } {#1} } ,
  }

% 2. Layout variables and \myunithesissetup (optional but recommended)
\tl_new:N \l__myuni_logo_align_tl  \tl_set:Nn \l__myuni_logo_align_tl { c }
\keys_define:nn { academicthesis-myuni / layout }
  {
    department .code:n = { \academicthesis_meta_set:nn { myuni-department } {#1} } ,
    logo-align .tl_set:N = \l__myuni_logo_align_tl ,
  }
\NewDocumentCommand \myunithesissetup { m }
  { \keys_set:nn { academicthesis-myuni / layout } { #1 } }

% 3. Front-page implementation
\NewDocumentCommand \__myuni_frontpage_bachelor: { }
  {
    \thispagestyle{empty}
    % ... typeset the front page using \academicthesis_meta_get:n{title} etc.
    \clearpage
  }

% 4. Register front pages
\DeclareThesisFrontPage { myuni } { bachelor } { \__myuni_frontpage_bachelor: }

% 5. Declare required metadata
\DeclareThesisRequirement { myuni } { \c_true_bool } { supervisors } { Prof. X }

\ExplSyntaxOff
```

Users then write:

```latex
\documentclass[university=myuni, bachelor]{academicthesis}
\myunithesissetup{ logo-align = center, department = Economics }
\thesissetup{ title = {My Thesis}, candidate = {Jane Doe}, … }
```

### Accessing metadata in front pages

```latex
\academicthesis_meta_get:n { title }        % expands to the title string
\academicthesis_meta_if_empty:nF { cosupervisor }
  { Co-supervisor: \academicthesis_meta_get:n { cosupervisor} \\ }
```

### Logo files

Place logo PDFs in the plugin's own folder (`universities/<uni>/`) and
refer to them by bare file name. The `latexmkrc` search path makes them
visible for local builds; when installed in a texmf tree, kpathsea finds
them the same way.

---

## Language files

`academicthesis-<lang>.ldf` files are plain `\input`-loaded (not
`\RequirePackage`'d). They define localised string macros:

```latex
\providecommand\acadth@str@supervisors{Supervisor}
\providecommand\acadth@str@candidate{Candidate}
% … etc.
```

The front-matter environments and front-page builders use these macros
rather than hard-coded strings. To add a new language, create
`academicthesis-<lang>.ldf` mirroring the English file and add a
`lang/<xx>` shorthand alias in the class options block.

---

## Key design decisions

**LaTeX3 (expl3) throughout.** The entire class and all plugins live inside
`\ExplSyntaxOn`. This gives precise argument-type specifications, safe
variable scoping (`\l__` local, `\g__` global), and structured message
handling — at the cost of requiring a reasonably modern TeX distribution
(TeX Live 2023+ recommended).

**Babel loaded with catcode guard.** `\ExplSyntaxOn` makes `_` and `:`
catcode-11 (letter) globally. Babel tokenises its `begindocument` hook
code at load time; those tokens mismatch the catcodes at execution time,
producing cascades of "Undefined control sequence" errors. The fix: bake
the language string into a plain-named macro via `\cs_set:Npx` (while
expl3 catcodes are active), then temporarily restore `_`/`:` to
catcode-12 with plain `\catcode` assignments around the
`\RequirePackage{babel}` call, then restore them. A full
`\ExplSyntaxOff`/`\ExplSyntaxOn` toggle cannot be used here because it
would re-tokenise the rest of the class file with wrong catcodes.

**Single metadata prop, open extension.** The core metadata store is a
plain prop (`\g__academicthesis_meta_prop`). Plugins add keys freely; the
core never inspects plugin-owned keys. There is no registration step — a
plugin just calls `\academicthesis_meta_set:nn` with whatever key name it
likes and reads it back the same way.

**University loader via `\exp_args:NV`.** The class stores the chosen
university as a string in `\g__academicthesis_university_tl` and loads
the plugin with
`\exp_args:NV \academicthesis_load_university:n \g__academicthesis_university_tl`.
The `NV` expansion converts the tl-variable to its string value before
calling the function, so the function receives `"luiss"` not
`\g__academicthesis_university_tl`. Passing the variable name directly
would make `\IfFileExists{academicthesis-\g__academicthesis_university_tl.sty}`
try to expand the variable inside a filename string, looping infinitely.

---

## Migration from the original monolithic class

The original `Initial/` code was a single `academicthesis.cls` that
contained all university formats (LUISS, LUMSA, …) in one file, selected
via `\DeclareOption`/`\ProcessOptions`. Problems:

- Adding a new university required editing the core class.
- Options for different universities polluted a shared namespace.
- No separation between core infrastructure and formatting.

The new structure moves each university into its own package. Adding
Bocconi means creating `academicthesis-bocconi.sty` and never touching
the core. The core class remains stable; plugins can be versioned and
distributed independently.

**Mapping from old keys to new:**

| Old option / command | New equivalent |
|----------------------|---------------|
| `\documentclass[luiss,bachelor]{academicthesis}` | `\documentclass[university=luiss,bachelor]{academicthesis}` |
| `\major{Finance}` | `\luissthesissetup{major=Finance}` or `\major{Finance}` |
| Hard-coded logo path in class | `\luissthesissetup{logo-file=path/to/logo}` |
| Language via `\DeclareOption{italian}` | `\documentclass[language=italian]{academicthesis}` |
