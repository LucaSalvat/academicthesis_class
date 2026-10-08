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
\ProvidesClass{academicthesis}[2026/01/01 v0.1.0 Modular academic thesis class]

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

\tl_new:N \l__academicthesis_classoptions_tl
\tl_set:Nn \l__academicthesis_classoptions_tl { }

\tl_new:N \l__academicthesis_language_tl
\tl_set:Nn \l__academicthesis_language_tl { english }

\bool_new:N \l__academicthesis_discussion_bool

\keys_define:nn { academicthesis / class }
  {
    % --- which institution's plugin to load -----------------------
    university .tl_set:N = \g__academicthesis_university_tl ,
    uni        .tl_set:N = \g__academicthesis_university_tl ,

    % --- language (loads academicthesis-<lang>.ldf) ---------------
    language .tl_set:N = \l__academicthesis_language_tl ,
    lang     .tl_set:N = \l__academicthesis_language_tl ,
    lang / en .meta:n = { language = english } ,
    lang / it .meta:n = { language = italian } ,
    lang / fr .meta:n = { language = french } ,
    english  .meta:n = { language = english } ,
    italian  .meta:n = { language = italian } ,
    french   .meta:n = { language = french } ,

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

    % --- bibliography backend ---------------------------------------
    % Forwarded verbatim to biblatex; e.g. biblatex-options={style=apa}
    biblatex-options .tl_set:N = \l__academicthesis_biblatex_options_tl ,

    % --- anything else: forward to the underlying `book` class ------
    unknown .code:n =
      {
        \tl_put_right:Nx \l__academicthesis_classoptions_tl { \exp_not:n {,\l_keys_key_tl} }
      } ,
  }

% Sensible defaults: a single-author, written-language thesis.
\tl_gset:Nn \g__academicthesis_university_tl { }
\tl_gset:Nn \g__academicthesis_degree_tl     { }
\bool_gset_true:N \g__academicthesis_bachelor_bool

\ProcessKeysOptions { academicthesis / class }

% Anything we did not recognise above is forwarded to `book`
% (twoside, openright, draft, a4paper, 11pt, ... all keep working).
\exp_args:Nx \PassOptionsToClass { \tl_use:N \l__academicthesis_classoptions_tl } { book }
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
\LoadClass{book}

\academicthesis_meta_set:nn { uni-option-string } { \l__academicthesis_classoptions_tl }


% =====================================================================
% 2. Engine-aware font & language setup
% =====================================================================
\RequirePackage{iftex}

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
  \cs_set:Npx \BabelLangNow { \l__academicthesis_language_tl }
  \catcode 95 =12 \catcode 58 =12
  \RequirePackage[\BabelLangNow]{babel}
  \catcode 95 =11 \catcode 58 =11
\else
  \RequirePackage{fontspec}
  \RequirePackage{polyglossia}
  \cs_set:Npx \__academicthesis_set_mainlanguage:w { }
    { \setmainlanguage { \l__academicthesis_language_tl } }
  \__academicthesis_set_mainlanguage:w
  \setmainfont{Latin Modern Roman}
  \setsansfont{Latin Modern Sans}
  \setmonofont{Latin Modern Mono}
\fi

\academicthesis_load_language:n { \l__academicthesis_language_tl }


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

\AtEndOfClass
  {
    \bool_if:NTF \g__academicthesis_biblatex_bool
      {
        \tl_if_empty:NTF \l__academicthesis_biblatex_options_tl
          {
            \__academicthesis_if_bibdefaults:TF
              {
                \exp_args:Nno \RequirePackage [ \__academicthesis_bibdefaults_get: ] { biblatex }
              }
              {
                \RequirePackage[style=numeric,backend=biber]{biblatex}
              }
          }
          {
            \exp_args:Nno \RequirePackage [ \l__academicthesis_biblatex_options_tl ] { biblatex }
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
    \__academicthesis_secondpage:
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
    \vfill
    \noindent\rule{\textwidth}{0.4pt}\vspace{0.03\textheight}
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
\NewDocumentCommand \thesisfrontchapter { m }
  {
    \cleardoublepage
    \thispagestyle{plain}
    \chapter*{#1}
    \addcontentsline{toc}{chapter}{#1}
    \markboth{#1}{#1}
  }

\NewDocumentCommand \dedication { m }
  {
    \cleardoublepage
    \thispagestyle{empty}
    \null\vspace{\stretch{0.26}}
    \begin{flushright}\textit{#1}\end{flushright}
    \vspace{\stretch{0.74}}\null
  }

\NewDocumentEnvironment { abstractthesis } { }
  { \thesisfrontchapter{\thesisstring{AbstractLabel}} \noindent\ignorespaces }
  { \par\null\ignorespacesafterend }

\NewDocumentEnvironment { acknowledgements } { }
  {
    \chapter*{\thesisstring{AcknowledgmentsLabel}}
    \begingroup
    \pagestyle{acknowledgments}
    \thispagestyle{plain}
    \itshape\noindent\ignorespaces
  }
  {
    \par\null
    \endgroup
    \pagestyle{Thesis}
    \thispagestyle{acknowledgments}
  }


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
    \fancyhead[CE,CO]{\small\nouppercase{\thesisstring{AcknowledgmentsLabel}}}%
    \fancyhead[LE,RO]{\thepage}%
  \else
    \fancyhead[C]{\small\nouppercase{\thesisstring{AcknowledgmentsLabel}}}%
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
