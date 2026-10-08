# latexmkrc -- local development builds for the academicthesis bundle.
#
# The packages in this repository are loaded by NAME (\LoadClass,
# \RequirePackage, \input{academicthesis-<lang>.ldf}), never by folder
# path, exactly as they will be once installed in a TeX distribution.
# For local builds we therefore don't touch the code: we add the source
# folders to TeX's search path (TEXINPUTS), so kpathsea finds every file
# by name wherever it lives in the repo. A trailing `//' means "search
# this folder and all its subfolders", so new universities and languages
# are picked up automatically.
#
# Used automatically by `latexmk` run from the repository root
# (e.g. `latexmk -cd showcases/example-luiss-bachelor.tex`), and loaded by
# showcases/latexmkrc when you run `latexmk` inside showcases/.

use Cwd qw(abs_path);
use File::Basename qw(dirname);

my $repo_root = dirname(abs_path(__FILE__));
ensure_path('TEXINPUTS',
            "$repo_root/core//",
            "$repo_root/languages//",
            "$repo_root/universities//");

$pdf_mode = 1;
