#!/bin/bash

source $(dirname $0)/common.sh

default_library="$HOME/texmf/bibtex/bib/library.bib"
show_help(){
  echo "Usage: $0 [-l english|french] [-c] [-a] [-b] [-e <default|library.bib>]"
  echo 
  echo "       -l choose the language in which to produce cv and publications list. Currently support english (and partially french)"
  echo "       -c, -a, -b Specify cleaning patterns. -c requests clean-up but specfiying after and/or before is still mandatory. -b/-a requests deletion before/after compilation"
  echo "       -e Extract publications by me (Godin-)Dubois, Kevin from the provided library file (defaults to $default_library)"
}

tmpfiles(){
  find . \( \
       -name '*.aux' -o -name '*.bbl' -o -name '*.bcf' -o -name '*.blg' -o -name '*.log' \
    -o -name '*.out' -o -name '*.run.xml' -o -name '*.synctex.gz' \) $@
}

pdfcompile(){
  pdflatex --interaction=batchmode "\\def\\kgdlang{$lang}\input{$1}"
}

clean(){
  n=$(tmpfiles | wc -l)
  echo "Deleting temporary files"
  tmpfiles -print
  tmpfiles -delete
  printf "> %d temporary files deleted\n\n" $n
}

cvfolder=$(find . -name "cv.tex" -printf '%h')
cd $cvfolder
wd=$(pwd)

lang="english"
clean=""
cleanbefore=""
cleanafter=""
library=""
OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts "h?l:abce:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    l)  lang=$OPTARG
        ;;
    c)  clean="yes"
        ;;
    b)  cleanbefore="yes"
        ;;
    a)  cleanafter="yes"
        ;;
    
    e)  library=$default_library
        [ "$OPTARG" != "default" ] && library="$OPTARG"
        ;;
    esac
done


[ -n "$clean" -a -n "$cleanbefore" ] && clean

if [ -n "$library" ]
then
  bib2bib -q -r -s year -s '$key' -c 'author : "GodinDubois, Kevin*" or author : "Dubois, Kevin"' $library |
    grep -v -e "file =" -e "abstract =" | sed 's/type =/entrysubtype =/' |
    sed 's|\(https://vimeo.*\)},|},\n  addendum = {{Presentation}: \\url{\1}},|' |
    sed 's/\(url = {.*\) .*}/\1}/' | 
    sed 's/{\\_}/_/g' > cv.bib
  r=$?
  if [ $r -eq 0 ]
  then
    awk '/^@/{
      if ($1 != "@comment") {
        match($0, /.*{(.*),/, arr)
        key = tolower(arr[1])
      }
    }
    /.*=.*}$/{
      if (key) {
        printf "%s,\n", $0
        printf "  local = {{{site.baseurl}}/download/%s.pdf}\n", key
        key = ""
        next;
      }
    }{
      print $0
    }' cv.bib > ~cv.bib
    r=$?
    mv -f ~cv.bib cv.bib
  fi
  if [ $r -eq 0 ]
  then
    echo "Extracted publications from $library"
    echo
  else
    echo "Failed to extract publications from $library"
    exit 2
  fi
fi
#
# for l in misc/academicons_rgate misc/academicons_gscholar
# do
#   if [ ! -f $l.pdf ]
#   then
#     cd $(dirname $l)
#     lualatex $(basename $l).tex
#     cd $wd
#     printf "\033[32mCompiled misc file $l\033[0m\n\n"
#   fi
# done
#
# lg=${lang:0:2}
# echo "Compiling for '$lang' [$lg] language"
# echo
#
# for f in {cv,publications}
# do
#   pdfcompile $f
#   biber --quiet $f 2>&1
#   pdfcompile $f
#   pdfcompile $f
#
#   echo
#   o=${f}_${lg}.pdf
#   mv -v $f.pdf $o
#
#   if [ "$lg" == "en" ]
#   then
#     o_=$o
#     o=../download/$f.pdf
#     mv -v $o_ $o
#   fi
#
#   if [ -f $o ]
#   then
#     printf "\033[32mCompiled file $f\033[0m\n\n"
#   else
#     printf "\033[31mFailed to compile file $f\033[0m\n\n"
#   fi
# done
#
# bibfilesize=$(grep "entrysubtype" cv.bib | wc -l)
# bibliosize=$(grep 'defaultrefcontext' cv.aux | wc -l)
# if [ $bibfilesize -ne $bibliosize ]
# then
#   printf "\033[33mMismatched bibliography: found %d pieces of work but only %d were cited\033[0m\n" $bibfilesize $bibliosize
#   (
#     echo "cv.bib cv.aux"
#     diff -y \
#       <(sed -n "s/^@.*{\([A-Za-z]*Dubois.*\),/\1/p" cv.bib | sort) \
#       <(sed -n 's/.*defaultrefcontext{0}{\([^}]*\)}.*/\1/p' cv.aux | sort)
#   ) | column -t
# fi


target=$(find .. -type d -wholename "*/src/$outdir")
bibtex2html -q --nodoc -nf local pdf -o $target/publications cv.bib
sed -i "s|../src/$outdir/publications_bib.html|/publications/bib|" $target/publications.html
sed -e 's/{Presentation}/Presentation/' \
    -e 's/@comment.*//' $target/publications_bib.html \
    -e "s|../src/$outdir/publications.html|/publications/|" \
  | tail -n +9 \
  | grep . \
  | awk 'NR==1{print "<div markdown=0>"};1;END{print "</div>"}' \
   > ~publications_bib.html
mv ~publications_bib.html $target/publications_bib.html
printf "\033[32mGenerated html bibliography\033[0m\n"

[ ! -z "$clean" -a ! -z "$cleanafter" ] && clean

exit 0
