#!/bin/bash

source $(dirname $0)/common.sh

out=_data/$autogen/images.yml

#set -x
grep -rnoz "<img [^>]*/>" _site/ | tr '\n' ' ' | tr -s ' ' | tr '\0' '\n' \
 | grep -v "gallery.html" \
 | grep -v "gallery.js" \
 | grep -v "index.html" \
 | grep -v "subfolder-image" \
 | while read tag
do
#  echo $tag >&2
  file=$(cut -d: -f 1 <<< "$tag" | sed 's|_site||')
  img=$(sed 's/.*src="\([^"]*\)".*/\1/' <<< $tag)
  echo "- src: $img"
  echo "  file: $file"
  echo
done > $out

cat $out

