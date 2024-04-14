set -euo pipefail
shopt -s inherit_errexit

sources=src
download=download
autogen=__generated

_grep() { grep $@ || test $? = 1; }
_field() { _grep $@ | cut -d ' ' -f 2-; }

