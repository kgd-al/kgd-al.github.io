#!/usr/bin/env bash
# Build transparent PNGs, SVGs and a multi-size favicon.ico from radial.tex.
# Needs: pdflatex (TikZ), pdftocairo (poppler-utils) and ImageMagick (convert, or magick for v7).
# Run it next to radial.tex:   ./export.sh [output-dir]
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)   # script's folder, safe with spaces
OUT=${1:-$HERE}
cd "$HERE"                            # pdflatex needs radial.tex in the cwd
IM=$(command -v magick || command -v convert)   # ImageMagick 7 / 6

# variant letter : pixel size : name   (A = 7 life forms, B = 7 abstract shapes, D = 7 dots;
#                                       C = the older 4-tip 16 px version, still in radial.tex)
for spec in "A:256:large" "B:64:medium" "D:16:small"; do
  IFS=: read -r v px name <<< "$spec"

  # 1. compile one variant (radial.tex draws only \VA / \VB / ... when \variant is defined)
  pdflatex -interaction=nonstopmode -jobname="var$v" "\\def\\variant{$v}\\input{radial.tex}" > /dev/null

  # 2. PNG with transparent background (-transp; PNG/TIFF only), exact pixel size
  pdftocairo -png -transp -scale-to-x "$px" -scale-to-y "$px" -singlefile "var$v.pdf" "$OUT/logo_${name}_${px}px"

  # 3. SVG (real vector paths, no background); default display size, the viewBox keeps it scalable
  pdftocairo -svg "var$v.pdf" "$OUT/logo_$name.svg"
  sed -i -E "0,/<svg /s/width=\"[0-9.]+\" height=\"[0-9.]+\"/width=\"$px\" height=\"$px\"/" "$OUT/logo_$name.svg"
done

# 4. favicon.ico: 16 px = small design, 32 and 48 px = medium design (one entry per size)
tmp=$(mktemp -d)
for px in 32 48; do
  pdftocairo -png -transp -scale-to-x "$px" -scale-to-y "$px" -singlefile varB.pdf "$tmp/medium_$px"
done
"$IM" "$OUT/logo_small_16px.png" "$tmp/medium_32.png" "$tmp/medium_48.png" "$OUT/favicon.ico"
rm -rf "$tmp"

# 5. clean up: only the intermediate files this script made (varA.aux/.log/.pdf, ...), so that
#    other .pdf/.log/.aux files next to it are left alone
rm *.aux *.log *.pdf

echo "wrote:"; ls -1 "$OUT"
