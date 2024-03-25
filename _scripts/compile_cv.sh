#!/bin/bash

source $(dirname $0)/common.sh

default_library="$HOME/texmf/bibtex/bib/library.bib"
show_help(){
  echo "Usage: $0 [-l english|french] [-c] [-a] [-b] [-e <default|library.bib>] [-f]"
  echo 
  echo "       -l choose the language in which to produce cv and publications list. Currently support english (and partially french)"
  echo "       -c, -a, -b Specify cleaning patterns. -c requests clean-up but specfiying after and/or before is still mandatory. -b/-a requests deletion before/after compilation"
  echo "       -e Extract publications by me (Godin-)Dubois, Kevin from the provided library file (defaults to $default_library)"
  echo "       -f Fast mode, don't generate cv/publications. Only process the bibliography"
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
cv="yes"
OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts "h?l:abce:f" opt; do
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

    f)  cv=""
        ;;
    esac
done


[ -n "$clean" -a -n "$cleanbefore" ] && clean

if [ -n "$library" ]
then
  bib2bib -q -r -s year -s '$key' -c 'author : "GodinDubois, Kevin*" or author : "Dubois, Kevin"' $library |
    grep -v -e "file =" -e "abstract =" |
    sed -e 's/type =/entrysubtype =/' \
        -e 's/\(url = {[^ ]*\) .*}\(,\?\)/\1}\2/' \
        -e 's/{{/{/' -e 's/}}/}/' \
        -e 's/{\\_}/_/g' \
        -e 's/{\\%}5C//g' \
        -e 's|\(https://vimeo.*\)},|},\n  addendum = {Presentation: \\url{\1}},|' \
        > cv.bib

  bib2bib -q \
    --remove abstract --remove file --remove keywords --remove mendeley-tags \
    --remove type \
    $library -ob library.bib

  cat cv.bib | while IFS= read line
  do
    [ "$line" == "" ] && continue
    [[ $line =~ "@comment" ]] && continue
    [[ $line =~ "url = {}" ]] && continue
    if [ "${line::1}" == @ ]
    then
      citekey=$(sed 's/.*{\(.*\),/\1/' <<< $line)
      key=$(sed 's/.*Dubois\(.*\),/\1/' <<< $line | tr '[:upper:]' '[:lower:]')
    fi
    if [ "${line: -1}" == "}" -a -n "$key" ]
    then
      echo "$line,"

      file=$(find ../download/papers -name "$key*.pdf" | sort | head -n 1 | sed 's/\.\.//')
      if [ -n "$file" ]
      then
        echo "  local = {$file}"
      else
        printf "\033[31mWarning: no pdf for ${citekey} ($key)\033[0m\n" >&2
      fi
      key=""
    else
      echo "$line"
    fi
  done > ~cv.bib
  mv ~cv.bib cv.bib

  cp -v $library .

  printf "\033[32mExtracted publications from $library\033[0m\n"
fi

if [ -n "$cv" ]
then
  for l in misc/academicons_rgate misc/academicons_gscholar
  do
    if [ ! -f $l.pdf ]
    then
      cd $(dirname $l)
      lualatex $(basename $l).tex
      cd $wd
      printf "\033[32mCompiled misc file $l\033[0m\n\n"
    fi
  done

  lg=${lang:0:2}
  echo "Compiling for '$lang' [$lg] language"
  echo

  for f in {cv,publications}
  do
    pdfcompile $f
    biber --quiet $f 2>&1
    pdfcompile $f
    pdfcompile $f

    echo
    o=${f}_${lg}.pdf
    mv -v $f.pdf $o

    if [ "$lg" == "en" ]
    then
      o_=$o
      o=../download/$f.pdf
      mv -v $o_ $o
    fi

    if [ -f $o ]
    then
      printf "\033[32mCompiled file $f\033[0m\n\n"
    else
      printf "\033[31mFailed to compile file $f\033[0m\n\n"
    fi
  done

  bibfilesize=$(grep "entrysubtype" cv.bib | wc -l)
  bibliosize=$(grep 'defaultrefcontext' cv.aux | wc -l)
  if [ $bibfilesize -ne $bibliosize ]
  then
    printf "\033[33mMismatched bibliography: found %d pieces of work but only %d were cited\033[0m\n" $bibfilesize $bibliosize
    (
      echo "cv.bib cv.aux"
      diff -y \
        <(sed -n "s/^@.*{\([A-Za-z]*Dubois.*\),/\1/p" cv.bib | sort) \
        <(sed -n 's/.*defaultrefcontext{0}{\([^}]*\)}.*/\1/p' cv.aux | sort)
    ) | column -t
  fi
else
  printf "\033[35mSkipping cv/publications compilation\033[0m\n"
fi

local="<i class='fa fa-download'></i>"
remote="<i class='fa fa-external-link'></i>"
target=$(find .. -type d -wholename "*/$sources/$autogen")
bibtex2html -q --nodoc -nf local "$local" -note entrysubtype -revkeys -o $target/publications cv.bib
sed -i -e "s|../$sources/$autogen/publications_bib.html|/publications/bib|" \
    -e "s|>.pdf</|>$remote</|" \
    $target/publications.html
sed -e 's/@comment.*//' \
    -e "s|../$sources/$autogen/publications.html|/publications/|" \
    -e 's|<h1>.*</h1>||' \
    $target/publications_bib.html \
  | awk 'NR==1{print "<div markdown=0>"};1;END{print "</div>"}' \
   > ~publications_bib.html
mv ~publications_bib.html $target/publications_bib.html
printf "\033[32mGenerated html bibliography\033[0m\n"

[ ! -z "$clean" -a ! -z "$cleanafter" ] && clean

exit 0
