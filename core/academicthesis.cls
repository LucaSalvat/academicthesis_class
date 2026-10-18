%%
%% academicthesis.cls
%% --------------------------------------------------------------
%% Core, university-agnostic class for academic theses (bachelor /
%% master / PhD) built on the LaTeX3 (expl3) programming layer.
%%
%% This class provides ONLY what every thesis needs regardless of
%% institution: page geometry & styles, language handling, metadata
%% storage and validation, bibliography baseline, and a small set of
%% front-matter environments (dedication, abstract, acknowledgements).
%%
%% Anything institution-specific (logos, title-page layout, colour
%% scheme, extra metadata fields such as "major" or "chair", ...)
%% lives in a separate, independently-maintained plugin package named
%% `academicthesis-<university>` (see academicthesis-luiss.sty for a
%% full example, and doc/ARCHITECTURE.md for the plugin contract).
%%
%% Copyright 2025-2026 Luca Salvatore.
%% Released under the LPPL 1.3c (or later); see https://www.latex-project.org/lppl.txt
%%--------------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{academicthesis}[2026/10/10 v0.2.0 Modular academic thesis class]

\RequirePackage{expl3}
\RequirePackage{xparse}
\RequirePackage{l3keys2e}

% Pull in the shared registries / metadata engine described in
% academicthesis-kernel.sty BEFORE option processing: the option keys
% below write directly into kernel-owned global variables (university,
% degree, gender, ...), so those variables must already be declared.
\RequirePackage{academicthesis-kernel}

\ExplSyntaxOn

% =====================================================================
% 1. Class options  (resolved with l3keys, not \DeclareOption chains)
% =====================================================================
% Every option ultimately funnels through \keys_set:nn so that the
% SAME interface is reachable from \documentclass[...]{academicthesis}
% and, if ever desired, from \PassOptionsToClass / a wrapper package.

\clist_new:N \l__academicthesis_classoptions_clist
\tl_new:N \l__academicthesis_classoptions_tl

% `secondpage' as typed by the user: empty = not given, so the
% university default (\DeclareThesisSecondPage) applies.
\tl_new:N \l__academicthesis_secondpage_tl
\bool_new:N \g__academicthesis_secondpage_bool

\clist_new:N \l__academicthesis_otherlanguages_clist

\tl_new:N \l__academicthesis_language_tl
\tl_set:Nn \l__academicthesis_language_tl { english }

\bool_new:N \l__academicthesis_discussion_bool

\keys_define:nn { academicthesis / class }
  {
    % --- which institution's plugin to load -----------------------
    university .tl_set:N = \g__academicthesis_university_tl ,
    uni        .tl_set:N = \g__academicthesis_university_tl ,

    % --- which of the university's formats (see \DeclareThesisFormats)
    format     .tl_gset:N = \g__academicthesis_format_tl ,

    % --- language (loads academicthesis-<lang>.ldf) ---------------
    language .tl_set:N = \l__academicthesis_language_tl ,
    lang     .tl_set:N = \l__academicthesis_language_tl ,
    lang / en .meta:n = { language = english } ,
    lang / it .meta:n = { language = italian } ,
    lang / fr .meta:n = { language = french } ,
    english  .meta:n = { language = english } ,
    italian  .meta:n = { language = italian } ,
    french   .meta:n = { language = french } ,
    % extra languages for babel/polyglossia, e.g. other-languages=italian
    other-languages .clist_set:N = \l__academicthesis_otherlanguages_clist ,

    % --- degree type ------------------------------------------------
    bachelor .code:n =
      {
        \bool_gset_true:N  \g__academicthesis_bachelor_bool
        \bool_gset_false:N \g__academicthesis_master_bool
        \bool_gset_false:N \g__academicthesis_phd_bool
        \tl_gset:Nn \g__academicthesis_degree_tl { bachelor }
      } ,
    master .code:n =
      {
        \bool_gset_false:N \g__academicthesis_bachelor_bool
        \bool_gset_true:N  \g__academicthesis_master_bool
        \bool_gset_false:N \g__academicthesis_phd_bool
        \tl_gset:Nn \g__academicthesis_degree_tl { master }
      } ,
    phd .meta:n = { PhD } ,
    PhD .code:n =
      {
        \bool_gset_false:N \g__academicthesis_bachelor_bool
        \bool_gset_false:N \g__academicthesis_master_bool
        \bool_gset_true:N  \g__academicthesis_phd_bool
        \tl_gset:Nn \g__academicthesis_degree_tl { phd }
      } ,

    % --- feature toggles --------------------------------------------
    discussion       .bool_set:N = \l__academicthesis_discussion_bool ,
    discussion       .default:n = { true } ,
    no-discussion    .code:n = { \bool_set_false:N \l__academicthesis_discussion_bool } ,

    % second page (examination commission + copyright) after \frontpage
    secondpage       .choices:nn = { true , false }
      { \tl_set_eq:NN \l__academicthesis_secondpage_tl \l_keys_choice_tl } ,
    secondpage       .default:n = { true } ,
    no-secondpage    .code:n = { \tl_set:Nn \l__academicthesis_secondpage_tl { false } } ,

    % --- bibliography backend ---------------------------------------
    % Forwarded verbatim to biblatex; e.g. biblatex-options={style=apa}
    biblatex-options .tl_set:N = \l__academicthesis_biblatex_options_tl ,

    % --- anything else: forward to the base class (book, article...) -
    unknown .code:n =
      {
        \clist_put_right:NV \l__academicthesis_classoptions_clist \l_keys_key_str
      } ,
  }

% Sensible defaults: a single-author, written-language thesis.
\tl_gset:Nn \g__academicthesis_university_tl { }
\tl_gset:Nn \g__academicthesis_degree_tl     { }
\bool_gset_true:N \g__academicthesis_bachelor_bool

\ProcessKeysOptions { academicthesis / class }

% ---------------------------------------------------------------------
% The base class is NOT fixed here: the university decides it, possibly
% per format (e.g. LUISS -> book; PoliMi classical -> book, article ->
% article). academicthesis-<uni>.cfg is read now, before \LoadClass,
% and declares the base class, its default options, the formats, the
% second-page default and extra languages (see the kernel, \S5-6).
\tl_if_empty:NF \g__academicthesis_university_tl
  {
    \exp_args:NV \academicthesis_load_university_config:n
      \g__academicthesis_university_tl
  }
\tl_if_empty:NT \g__academicthesis_baseclass_tl
  { \tl_gset:Nn \g__academicthesis_baseclass_tl { book } }
\academicthesis_resolve_format:

\str_case:VnF \l__academicthesis_secondpage_tl
  {
    { true }  { \bool_gset_true:N  \g__academicthesis_secondpage_bool }
    { false } { \bool_gset_false:N \g__academicthesis_secondpage_bool }
  }
  {
    \bool_gset_eq:NN \g__academicthesis_secondpage_bool
      \g__academicthesis_secondpage_default_bool
  }

% Base-class options = university defaults + what the user typed. A
% default is dropped when the user chose another option of its group,
% because the standard classes process options in DECLARATION order
% (a default `12pt' would otherwise beat a user `11pt').
\seq_const_from_clist:Nn \c__academicthesis_option_groups_seq
  {
    { 10pt , 11pt , 12pt } ,
    { oneside , twoside } ,
    { onecolumn , twocolumn } ,
    { openright , openany } ,
    { a4paper , a5paper , b5paper , letterpaper , legalpaper , executivepaper } ,
    { portrait , landscape } ,
    { draft , final } ,
    { titlepage , notitlepage } ,
  }
\clist_new:N \l__academicthesis_defaultoptions_clist
\bool_new:N  \l__academicthesis_option_taken_bool
\clist_map_inline:Nn \g__academicthesis_baseclass_options_clist
  {
    \bool_set_false:N \l__academicthesis_option_taken_bool
    \seq_map_inline:Nn \c__academicthesis_option_groups_seq
      {
        \clist_if_in:nnT { ##1 } { #1 }
          {
            \clist_map_inline:nn { ##1 }
              {
                \clist_if_in:NnT \l__academicthesis_classoptions_clist { ####1 }
                  { \bool_set_true:N \l__academicthesis_option_taken_bool }
              }
          }
      }
    \bool_if:NF \l__academicthesis_option_taken_bool
      { \clist_put_right:Nn \l__academicthesis_defaultoptions_clist { #1 } }
  }
\clist_concat:NNN \l__academicthesis_classoptions_clist
  \l__academicthesis_defaultoptions_clist \l__academicthesis_classoptions_clist
\tl_set:Nx \l__academicthesis_classoptions_tl
  { \clist_use:Nn \l__academicthesis_classoptions_clist { , } }

% NOTE: \ExplSyntaxOn remaps the catcodes of `_', `:' and SPACE for the
% remainder of this file. Foreign LaTeX2e package/class sources are
% loaded directly below -- this mirrors the standard, well-tested
% pattern used by other expl3-based packages (e.g. acro.sty loads
% \RequirePackage{translations} while \ExplSyntaxOn is in effect, and
% never calls \ExplSyntaxOff again). Toggling the regime off and back on
% repeatedly around each \RequirePackage is unnecessary and was found,
% empirically, to corrupt expl3's internal catcode-tracking state and
% hang \ExplSyntaxOn on a later call -- so we deliberately do NOT do
% that here.
% (A helper, because \LoadClass must see a literal `[' -- see the
% biblatex loader in \S4 for the same issue.)
\cs_new_protected:Npn \__academicthesis_load_class:nn #1 #2
  { \LoadClass [ #1 ] { #2 } }
\cs_generate_variant:Nn \__academicthesis_load_class:nn { VV }
\__academicthesis_load_class:VV
  \l__academicthesis_classoptions_tl \g__academicthesis_baseclass_tl

\academicthesis_meta_set:nn { uni-option-string } { \l__academicthesis_classoptions_tl }


% =====================================================================
% 2. Engine-aware font & language setup
% =====================================================================
\RequirePackage{iftex}

% Extra languages: from the user (other-languages=...) and from the
% university (\DeclareThesisOtherLanguages), minus the main language.
\clist_gconcat:NNN \g__academicthesis_otherlanguages_clist
  \g__academicthesis_otherlanguages_clist \l__academicthesis_otherlanguages_clist
\clist_gremove_duplicates:N \g__academicthesis_otherlanguages_clist
\cs_generate_variant:Nn \clist_gremove_all:Nn { NV }
\clist_gremove_all:NV \g__academicthesis_otherlanguages_clist \l__academicthesis_language_tl

\ifPDFTeX
  \RequirePackage[T1]{fontenc}
  \RequirePackage[utf8]{inputenc}
  \RequirePackage{lmodern}
  % BABEL CATCODE WORKAROUND
  % \RequirePackage[<lang>]{babel} must NOT be called while `_' and `:'
  % have catcode "letter" (as \ExplSyntaxOn sets them for this whole file).
  % Babel tokenises its begindocument-hook code at load time; if `_'/`:'
  % are letters when that happens, the stored control-sequence tokens
  % mismatch the ones looked up at \begin{document} (catcode "other"
  % inside babel's own groups) -- producing cascades of "Undefined control
  % sequence / Extra \fi" errors.  A full \ExplSyntaxOff/\ExplSyntaxOn
  % toggle would fix catcodes but break tokenisation of the rest of *this*
  % file (every subsequent \academicthesis_..:N-style name gets mis-split).
  %
  % Proven solution (babelmin7.tex test):
  %   1. \cs_set:Npx bakes the language string into a plain-named macro
  %      (\BabelLangNow has no `_'/`:' so it tokenises identically at any
  %      catcode regime) while ExplSyntaxOn's catcodes are still active.
  %   2. Flip only the two problem catcodes (numeric codes: 95=`_', 58=`:')
  %      using plain \catcode -- no catcode-sensitive names required.
  %   3. Write \RequirePackage[\BabelLangNow]{babel} INLINE here (not via
  %      a second wrapper macro -- a wrapper's invocation token would be
  %      mis-tokenised if its name contains `_'/`:' and appears after the
  %      toggle; \BabelLangNow contains neither, so it's safe).
  %   4. Restore the two catcodes immediately after.
  % (the main language goes LAST: babel makes the last option the main one)
  \cs_set:Npx \BabelLangNow
    {
      \clist_use:Nn \g__academicthesis_otherlanguages_clist { , }
      \clist_if_empty:NF \g__academicthesis_otherlanguages_clist { , }
      \l__academicthesis_language_tl
    }
  \catcode 95 =12 \catcode 58 =12
  \RequirePackage[\BabelLangNow]{babel}
  \catcode 95 =11 \catcode 58 =11
\else
  \RequirePackage{fontspec}
  \RequirePackage{polyglossia}
  \cs_set:Npx \__academicthesis_set_mainlanguage:w { }
    { \setmainlanguage { \l__academicthesis_language_tl } }
  \__academicthesis_set_mainlanguage:w
  \clist_if_empty:NF \g__academicthesis_otherlanguages_clist
    {
      \exp_args:Nx \setotherlanguages
        { \clist_use:Nn \g__academicthesis_otherlanguages_clist { , } }
    }
  \setmainfont{Latin Modern Roman}
  \setsansfont{Latin Modern Sans}
  \setmonofont{Latin Modern Mono}
\fi

\exp_args:NV \academicthesis_set_main_language:n \l__academicthesis_language_tl


% =====================================================================
% 3. Core layout packages
% =====================================================================
\RequirePackage{graphicx}
\RequirePackage{geometry}
\RequirePackage{etoolbox}
\RequirePackage{fancyhdr}
\RequirePackage{xcolor}
\RequirePackage{amsmath}

% Drop-cap configuration (kept from the original class; universities
% may override \LettrineFontHook for their own colour scheme).
\RequirePackage{type1cm}
\RequirePackage{lettrine}
\setcounter{DefaultLines}{2}
\renewcommand{\LettrineTextFont}{\normalfont}
\renewcommand{\DefaultLoversize}{0.25}
\renewcommand{\DefaultLhang}{0.25}

\newcommand{\TitleFont}{\fontsize{16}{20}\selectfont}
\newcommand{\SubtitleFont}{\fontsize{14}{18}\selectfont}
\newcommand{\LowerFont}{\fontsize{12}{14.5}\selectfont}


% =====================================================================
% 4. Bibliography baseline
% =====================================================================
% Preferred backend is biblatex, configured (in priority order) from
%   1. an explicit `biblatex-options` class option,
%   2. the active university plugin's \DeclareThesisBibDefaults,
%   3. a generic numeric fallback.
%
% Not every TeX installation ships biblatex+biber (e.g. minimal CI
% images), so the class degrades gracefully to natbib/BibTeX and
% exposes the SAME two user-facing commands either way:
%   \addbibresource{<file>}   \printbibliography
% This keeps thesis source files portable across machines without the
% author needing to know which backend ended up being used.

\msg_new:nnn { academicthesis } { bibliography-fallback }
  {
    biblatex~is~not~available~on~this~system;~falling~back~to~
    natbib~+~BibTeX~for~the~bibliography.
  }

\bool_new:N \g__academicthesis_biblatex_bool
\IfFileExists{biblatex.sty}
  { \bool_gset_true:N  \g__academicthesis_biblatex_bool }
  { \bool_gset_false:N \g__academicthesis_biblatex_bool }

% Load biblatex with an option list that is only known as a variable.
% (\exp_args:Nno \RequirePackage [ ... ] would treat `[' as the first
% argument and typeset the options as text before \begin{document}.)
\cs_new_protected:Npn \__academicthesis_load_biblatex:n #1
  { \RequirePackage [ #1 ] { biblatex } }
\cs_generate_variant:Nn \__academicthesis_load_biblatex:n { e , V }

\AtEndOfClass
  {
    \bool_if:NTF \g__academicthesis_biblatex_bool
      {
        \tl_if_empty:NTF \l__academicthesis_biblatex_options_tl
          {
            \__academicthesis_if_bibdefaults:TF
              {
                \__academicthesis_load_biblatex:e { \__academicthesis_bibdefaults_get: }
              }
              {
                \RequirePackage[style=numeric,backend=biber]{biblatex}
              }
          }
          {
            \__academicthesis_load_biblatex:V \l__academicthesis_biblatex_options_tl
          }
      }
      {
        \msg_warning:nn { academicthesis } { bibliography-fallback }
        \RequirePackage{natbib}
        \tl_new:N \g__academicthesis_bibresource_tl
        \tl_new:N \l__academicthesis_bibfile_tl
        % Minimal compatibility shims so thesis sources stay portable:
        \NewDocumentCommand \addbibresource { m }
          { \tl_gset:Nn \g__academicthesis_bibresource_tl { #1 } }
        \NewDocumentCommand \printbibliography { }
          {
            \bibliographystyle{plainnat}
            \tl_set:Nx \l__academicthesis_bibfile_tl { \g__academicthesis_bibresource_tl }
            \regex_replace_once:nnN { \.bib \z } { } \l__academicthesis_bibfile_tl
            \exp_args:NV \bibliography \l__academicthesis_bibfile_tl
          }
      }
  }


% =====================================================================
% 5. Load the university plugin  (the actual "modularity" seam)
% =====================================================================
\tl_if_empty:NTF \g__academicthesis_university_tl
  {
    \msg_error:nnnn { academicthesis } { invalid-key-value }
      { university } { (none) }
      {
        Pass~university=<id>~as~a~class~option,~e.g.~\MessageBreak
        \exp_not:n{ \documentclass[university=luiss,bachelor]{academicthesis} }
      }
  }
  {
    % \academicthesis_load_university:n takes its argument as a literal
    % university id (e.g. "luiss"), not as a token-list-variable name --
    % \exp_args:NV expands \g__academicthesis_university_tl to its stored
    % string first, so the function receives "luiss", not the csname
    % \g__academicthesis_university_tl itself (passing the csname verbatim
    % previously caused infinite expansion -- see the note at
    % \academicthesis_load_university:n's definition in the kernel).
    \exp_args:NV \academicthesis_load_university:n \g__academicthesis_university_tl
  }


% =====================================================================
% 6. Author / supervisor / examiner labels  (gender- & count-aware)
% =====================================================================
\NewDocumentCommand \authorlabel { }
  {
    \bool_if:NTF \g__academicthesis_female_bool
      { \thesisstring{CandidateLabelFemale} }
      { \thesisstring{CandidateLabel} }
  }

\NewDocumentCommand \supervisorlabel { }
  {
    \int_compare:nNnTF { \academicthesis_list_count:n {supervisors} } > {1}
      { \thesisstring{SupervisorsLabel} }
      { \thesisstring{SupervisorLabel} }
  }

\NewDocumentCommand \cosupervisorlabel { }
  {
    \int_compare:nNnTF { \academicthesis_list_count:n {cosupervisors} } > {1}
      { \thesisstring{CoSupervisorsLabel} }
      { \thesisstring{CoSupervisorLabel} }
  }


% =====================================================================
% 7. Front page entry point  (dispatches to the active plugin)
% =====================================================================
\NewDocumentCommand \frontpage { }
  {
    \__academicthesis_frontpage_dispatch:
    \bool_if:NT \g__academicthesis_secondpage_bool
      { \__academicthesis_secondpage: }
  }


% =====================================================================
% 8. Second page: examination commission + copyright block
% =====================================================================
\NewDocumentCommand \__academicthesis_examination_commission: { }
  {
    \bool_if:NTF \l__academicthesis_discussion_bool
      {
        \thesisstring{ThesisDiscussionBegin}\ \academicthesis_meta_get:n{examdate}\
        \thesisstring{ThesisDiscussionFollowing}
        \linebreak
        \academicthesislist{examiners}
      }
      { \thesisstring{NoDiscussion} }
  }

\NewDocumentCommand \__academicthesis_copyright_section: { }
  {
    \footnotesize
    \textbf{\academicthesis_meta_get:n{title}} \linebreak
    \textcopyright~\academicthesis_meta_get:n{copyyear}~\academicthesis_meta_get:n{candidate}
    \linebreak\linebreak
    \thesisstring{Copyrights}\linebreak\linebreak
    \academicthesis_meta_if_empty:nF {candidate}
      { \thesisstring{AuthorCopyright}~\academicthesis_meta_get:n{candidate} }
    \academicthesis_meta_if_empty:nF {authoremail}
      { \linebreak\thesisstring{ContactCopyright}~\academicthesis_meta_get:n{authoremail} }
    \academicthesis_meta_if_empty:nF {website}
      { \linebreak\thesisstring{Website}~\academicthesis_meta_get:n{website} }
    \linebreak\linebreak
    \thesisstring{AcknowledgmentsCopyright}
    \ignorespacesafterend
  }

\NewDocumentCommand \__academicthesis_secondpage: { }
  {
    \thispagestyle{empty}
    \makebox[0.8\textwidth][l]{%
      \parbox{0.8\textwidth}{\raggedright \__academicthesis_examination_commission: }%
    }
    \par
    \vfill
    \noindent\rule{\textwidth}{0.4pt}\par
    \vspace{0.03\textheight}
    \noindent
    \makebox[0.8\textwidth][l]{%
      \parbox{0.8\textwidth}{%
        \setlength{\parindent}{0pt}
        \begin{flushleft} \__academicthesis_copyright_section: \end{flushleft}
      }%
    }
    \vspace{3.65cm}
  }


% =====================================================================
% 9. Front-matter helpers (university-agnostic)
% =====================================================================
% The base class is the university's choice (book, report, article...),
% so front-matter headings follow what it offers: a starred chapter when
% \chapter exists, otherwise a starred section in the running text.
\bool_new:N \g__academicthesis_chapters_bool
\cs_if_exist:NTF \chapter
  { \bool_gset_true:N  \g__academicthesis_chapters_bool }
  { \bool_gset_false:N \g__academicthesis_chapters_bool }

% Unnumbered top-level heading: \chapter* or \section*
\NewDocumentCommand \thesisfrontheading { m }
  {
    \bool_if:NTF \g__academicthesis_chapters_bool
      { \chapter*{#1} }
      { \section*{#1} }
  }

\NewDocumentCommand \thesisfrontchapter { m }
  {
    \bool_if:NTF \g__academicthesis_chapters_bool
      {
        \cleardoublepage
        \thispagestyle{plain}
        \chapter*{#1}
        \addcontentsline{toc}{chapter}{#1}
      }
      {
        \section*{#1}
        \addcontentsline{toc}{section}{#1}
      }
    \markboth{#1}{#1}
  }

% ---------------------------------------------------------------------
% Front-matter blocks: dedication, abstract, originality, acknowledgements
% ---------------------------------------------------------------------
% All of them (and originality, below) take the same optional keys:
%   language  e.g. language=italian: the block's strings (heading,
%             "Keywords") come from that language, and so does
%             hyphenation when babel/polyglossia loaded it (class option
%             other-languages=italian,french). Default: the main
%             language (the `language' class option).
%   title     replaces the default heading
%   keywords  (abstract) printed after the text as "<Keywords>: a, b"
% So a thesis can have, e.g., an English and an Italian abstract:
%   \begin{abstractthesis}[keywords={...}] ... \end{abstractthesis}
%   \begin{abstractthesis}[language=italian, keywords={...}] ... \end{abstractthesis}
\tl_new:N \l__academicthesis_block_keywords_tl
\tl_new:N \l__academicthesis_block_language_tl
\tl_new:N \l__academicthesis_block_title_tl
\keys_define:nn { academicthesis / block }
  {
    keywords .tl_set:N = \l__academicthesis_block_keywords_tl ,
    language .tl_set:N = \l__academicthesis_block_language_tl ,
    title    .tl_set:N = \l__academicthesis_block_title_tl ,
  }

% #1 = user options, #2 = string key of the default heading.
% Must run inside a group (every caller is an environment or a group).
% The heading is kept as the string's raw text, not \thesisstring{..}:
% it is also written to the ToC, which is read back in the main language.
\cs_new_protected:Npn \__academicthesis_block_setup:nn #1 #2
  {
    \tl_clear:N \l__academicthesis_block_keywords_tl
    \tl_clear:N \l__academicthesis_block_language_tl
    \tl_clear:N \l__academicthesis_block_title_tl
    \keys_set:nn { academicthesis / block } { #1 }
    \tl_if_empty:NF \l__academicthesis_block_language_tl
      {
        \exp_args:NV \academicthesis_select_language:n
          \l__academicthesis_block_language_tl
      }
    \tl_if_empty:NT \l__academicthesis_block_title_tl
      { \academicthesis_string_get:nN { #2 } \l__academicthesis_block_title_tl }
  }

% \dedication[language=...]{text}
\NewDocumentCommand \dedication { O{} +m }
  {
    \cleardoublepage
    \thispagestyle{empty}
    \group_begin:
      \__academicthesis_block_setup:nn { #1 } { }
      \null\vspace{\stretch{0.26}}
      \begin{flushright}\textit{#2}\end{flushright}
      \vspace{\stretch{0.74}}\null
    \group_end:
  }

% \thesiskeywords{<label>}{<keywords>}: how keywords are printed after an
% abstract; a university package may redefine it (e.g. a coloured box).
\NewDocumentCommand \thesiskeywords { m m }
  {
    \vspace{\baselineskip}
    \noindent\textbf{#1:}~#2\par
  }

% \begin{abstractthesis}[language=..., keywords=..., title=...]
\NewDocumentEnvironment { abstractthesis } { O{} }
  {
    \__academicthesis_block_setup:nn { #1 } { AbstractLabel }
    \exp_args:NV \thesisfrontchapter \l__academicthesis_block_title_tl
    \noindent\ignorespaces
  }
  {
    \par
    \tl_if_empty:NF \l__academicthesis_block_keywords_tl
      {
        \exp_args:NnV \thesiskeywords { \thesisstring{KeywordsLabel} }
          \l__academicthesis_block_keywords_tl
      }
    \null\ignorespacesafterend
  }

% \begin{originality}[language=..., title=...]
% Statement of originality (e.g. Oxford): a front-matter chapter with
% the same options as the abstract, listed in the table of contents.
\NewDocumentEnvironment { originality } { O{} }
  {
    \__academicthesis_block_setup:nn { #1 } { OriginalityLabel }
    \exp_args:NV \thesisfrontchapter \l__academicthesis_block_title_tl
    \noindent\ignorespaces
  }
  { \par\null\ignorespacesafterend }

% \begin{acknowledgements}[language=..., title=...]
% The look lives in \thesisacknowledgementsbegin{<heading>} and
% \thesisacknowledgementsend, which a university package may redefine
% (the language/title handling above stays in the core).
\tl_new:N \g__academicthesis_ack_title_tl   % for the running header
\int_new:N \g__academicthesis_ack_firstpage_int
\NewDocumentCommand \thesisacknowledgementsbegin { m }
  {
    \thesisfrontheading{#1}
    \tl_gset:Nn \g__academicthesis_ack_title_tl { #1 }
    \int_gset:Nn \g__academicthesis_ack_firstpage_int { \value{page} }
    \begingroup
    \pagestyle{acknowledgments}
    \thispagestyle{plain}
    \itshape\noindent\ignorespaces
  }
\NewDocumentCommand \thesisacknowledgementsend { }
  {
    \par\null
    \endgroup
    \pagestyle{Thesis}
    % Keep the acknowledgments header on their last page, but not when
    % they fit on the chapter's opening page (that one stays `plain').
    \int_compare:nNnF { \value{page} } = { \g__academicthesis_ack_firstpage_int }
      { \thispagestyle{acknowledgments} }
  }
\NewDocumentEnvironment { acknowledgements } { O{} }
  {
    \__academicthesis_block_setup:nn { #1 } { AcknowledgmentsLabel }
    \exp_args:NV \thesisacknowledgementsbegin \l__academicthesis_block_title_tl
  }
  { \thesisacknowledgementsend }


% =====================================================================
% 10. Page styles
% =====================================================================
\fancypagestyle{Thesis}{%
  \fancyhf{}%
  \if@twoside
    \fancyhead[LE,RO]{\thepage}%
    \fancyhead[RE]{\small\nouppercase{\leftmark}}%
    \fancyhead[OL]{\small\nouppercase{\rightmark}}%
  \else
    \fancyhead[R]{\thepage}%
    \fancyhead[L]{\small\nouppercase{\rightmark}}%
  \fi
  \renewcommand{\headrulewidth}{0.4pt}%
  \renewcommand{\footrulewidth}{0pt}%
}

\fancypagestyle{acknowledgments}{%
  \fancyhf{}%
  \if@twoside
    \fancyhead[CE,CO]{\small\nouppercase{\g__academicthesis_ack_title_tl}}%
    \fancyhead[LE,RO]{\thepage}%
  \else
    \fancyhead[C]{\small\nouppercase{\g__academicthesis_ack_title_tl}}%
    \fancyhead[R]{\thepage}%
  \fi
  \renewcommand{\headrulewidth}{0.4pt}%
  \renewcommand{\footrulewidth}{0pt}%
}

\fancypagestyle{plain}{%
  \fancyhf{}%
  \renewcommand{\headrulewidth}{0pt}%
  \renewcommand{\footrulewidth}{0pt}%
  \fancyhead[LE,RO]{\thepage}%
}

% Classes without \frontmatter/\mainmatter/\backmatter (article): light
% versions, so the same document source compiles on any base class.
\cs_if_exist:NF \frontmatter
  {
    \NewDocumentCommand \frontmatter { } { \pagenumbering{roman} }
    \NewDocumentCommand \mainmatter { } { \clearpage \pagenumbering{arabic} }
    \NewDocumentCommand \backmatter { } { }
  }
\g@addto@macro\frontmatter{\pagestyle{plain}}
\g@addto@macro\mainmatter{\pagestyle{Thesis}}
\apptocmd{\tableofcontents}{\cleardoublepage\markboth{}{}\markright{}}{}{}


% =====================================================================
% 11. Metadata validation  (common fields + plugin-registered ones)
% =====================================================================
\NewDocumentCommand \__academicthesis_check_metadata: { }
  {
    \academicthesis_require:nn {title}        { \thesissetup{title=My~Thesis~Title} }
    \academicthesis_require:nn {candidate}    { \thesissetup{candidate=Your~Name} }
    \academicthesis_require:nn {academicyear} { \thesissetup{academicyear=20XX/20XX} }

    \academicthesis_require_if:Nnn \g__academicthesis_bachelor_bool {degree}
      { \thesissetup{degree=Degree~name} }
    \academicthesis_require_if:Nnn \g__academicthesis_master_bool {degree}
      { \thesissetup{degree=Degree~name} }

    \academicthesis_list_if_empty:nTF {supervisors}
      { \msg_error:nnnn { academicthesis } { missing-metadata }
          { supervisors } { \thesissetup{supervisors={Prof.~Name}} } }
      { }

    \academicthesis_require_if:Nnn \l__academicthesis_discussion_bool {examdate}
      { \thesissetup{examdate=29~October~2026} }

    % Plugin-specific requirements (e.g. LUISS PhD wants cycle/department)
    \__academicthesis_run_requirements:
  }

\AtBeginDocument{ \__academicthesis_check_metadata: }

\ExplSyntaxOff
\endinput
