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
    -o -name '*.out' -o -name '*.run.xml' -o -name '*.synctex.gz' -o -name '*.tex.dat' \) $@
}

pdfcompile(){
  if ! pdflatex --interaction=batchmode "\\def\\kgdlang{$lang}\input{$1}"
  then
    error "Error compiling $1" >&2
    less +G $1.log
  fi
}

clean(){
  n=$(tmpfiles | wc -l)
  echo "Deleting temporary files"
  tmpfiles -print
  tmpfiles -delete
  printf "> %d temporary files deleted\n\n" $n
}

field(){
  cut -d '=' -f2 | tr -d '{}, '
}

lower(){
  tr '[:upper:]' '[:lower:]'
}

hasfile(){
  [ $1 != "software" ] && [ $1 != "dataset" ]
}

message(){
  printf "\033[%dm$2\033[0m\n" "$1"
}

error(){
  message 31 "$1"
}

log(){
  message 32 "$1"
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
  bib2bib -q -r -s year -s '$key' \
      -c 'author : "GodinDubois, Kevin*" or author : "Dubois, Kevin"' \
       $library 2> >(grep -v -e "Sorting...done" -e "No citation file output") |
    sed -e 's|presentation = \(.*\)|addendum = {Presentation: \\\\url{\1}}|' > cv.bib

  # Check that the mappings are correct
  zotero_mapping_location=$LINENO
  declare -Ar zotero_types_to_bibtex=(
    ["dataset"]="software"
  )
  ok=0
  for key in $(grep type cv.bib | field | sort | uniq | lower)
  do
    value=${zotero_types_to_bibtex[$key]-$key}
    macro=$(grep ".def.publi$value{" common.tex || true)
    if [ -z "$macro" ]
    then
      msg="No macro \\publi$value for entry type $value"
      [ $key != $value ] && msg="$msg (mapped from $key)"
      error "$msg" >&2
      ok=$((ok + 1))
    fi
  done
  [ $ok -eq 0 ] || exit 11

  (
  echo "\\def\\publiclasses{"
  grep "^.def.publi.*{$" common.tex | cut -c 11- | tr -d '{' | sed 's|.*| &/\\publi&,|'
  echo "}"
  ) > _bibliography_sections.tex

  bib2bib -q \
    --remove abstract --remove file --remove keywords --remove mendeley-tags \
    --remove type \
    $library -ob library.bib 2> >(grep -v "No citation file output")

  grep -v -e "^$" -e "@comment" cv.bib | while IFS= read line
  do
#    echo $line >&2
    print="yes"

    if [ "${line::1}" == @ ]
    then
      type=$(sed 's/^@\(.*\){.*/\1/' <<< $line)
      citekey=$(sed 's/.*{\(.*\),/\1/' <<< $line)
      key=$(sed 's/.*Dubois\(.*\),/\1/' <<< $line | lower)
    fi

    if [[ $line =~ "type" ]]
    then
      subtype=$(field <<< $line | lower)
      [ $type != "misc" ] && print=""
    fi

    # Last line of entry
    if [ "${line: -1}" == "}" ] && [ -n "$key" ]
    then
#      echo ">> Last field" >&2
      [ -n "$print" ] && echo "$line,"

      if [ -z "$subtype" ]
      then
        error "Missing type for $key. Please provide it manually
        (e.g. setting tex.type in zotero extras field)" >&2
        exit 10
      fi

      if hasfile $subtype
      then
        file=$(find ../download/papers -name "$key*.pdf" | sort | head -n 1 | sed 's/\.\.//')
        if [ -n "$file" ]
        then
          echo "  local = {$file},"
        else
          error "Warning: no pdf for ${citekey} ($key)" >&2
        fi
        file=
      fi

      echo "  entrysubtype = {${zotero_types_to_bibtex[$subtype]-$subtype}}"

      # Reset variables (just in case)
      citekey=
      key=
      type=
      subtype=

    else
      [ -n "$print" ] && echo "$line"
    fi

  done > ~cv.bib
  mv ~cv.bib cv.bib

  log "Extracted publications from $library"
fi

# ====================================

if [ -n "$cv" ]
then
  for l in misc/academicons_rgate misc/academicons_gscholar
  do
    if [ ! -f $l.pdf ]
    then
      cd $(dirname $l)
      lualatex $(basename $l).tex
      cd $wd
      log "Compiled misc file $l\n"
    fi
  done

  lg=${lang:0:2}
  echo "Compiling for '$lang' [$lg] language"
  echo

  for f in {cv,publications}
  do
    pdfcompile $f
    biber --quiet $f 2> >(grep -v "Use of uninitialized value")
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
      log "Compiled file $f\n"
    else
      error "Failed to compile file $f\n"
    fi
  done

  bibfilesize=$(grep "entrysubtype" cv.bib | wc -l)
  bibliosize=$(grep 'defaultrefcontext' cv.aux | wc -l)
  if [ $bibfilesize -ne $bibliosize ]
  then
    message 33 "Mismatched bibliography: found $bibfilesize pieces of work but only $bibliosize were cited"
    (
      echo "cv.bib cv.aux"
      diff -y \
        <(sed -n "s/^@.*{\([A-Za-z]*Dubois.*\),/\1/p" cv.bib | sort) \
        <(sed -n 's/.*defaultrefcontext{0}{\([^}]*\)}.*/\1/p' cv.aux | sort)
    ) | column -t
  fi
else
  message 35 "Skipping cv/publications compilation"
fi

local="<i class='fa fa-download'></i>"
remote="<i class='fa fa-external-link'></i>"
target=$(find .. -type d -wholename "*/$sources/$autogen")
bibtex2html -q --nodoc -nf local "$local" -r -d -revkeys \
  -o $target/publications cv.bib

sed -e "s|../$sources/$autogen/publications_bib.html|/publications/bib|" \
    -e "s|>.pdf</|>$remote</|" \
    -e "s|.</em></p>| on $(date -Iseconds)&|" \
    -e "s|Kevin[^,]*Dubois|<b>&</b>|" \
    $target/publications.html \
  | awk '
    /\[&nbsp/{hold=1;data=""}
    !hold{print}
    hold{data=data""$0"\n"}
    /&nbsp;]/{hold=0;print "<span class=\"biblio-widget\">"data"</span>"}' \
    > ~publications.html
  mv ~publications.html $target/publications.html

sed -e 's/@comment.*//' \
    -e "s|../$sources/$autogen/publications.html|/publications/|" \
    -e 's|<h1>.*</h1>||' \
    -e "s|.</em></p>| on $(date -Iseconds)&|" \
    $target/publications_bib.html \
  | awk 'NR==1{
      print "{% raw %}"
      print "<div markdown=\"0\">"
    };1;END{
      print "</div>"
      print "{% endraw %}"
    }' \
   > ~publications_bib.html
mv ~publications_bib.html $target/publications_bib.html

# \
#| while read item
#do
#  key=$(grep -o 'name="[^"]*"' <<< $item | sed 's/.*"\(.*\)"/\1/')
#  echo $key "$item"
#done

items=bibliography_items.html
tr '\n' '\t' < $target/publications.html | sed -e 's|</tr>|&\n|g' -e 's|<tr|\n&|' > $items
(
  grep -A 1 ".def.publi" common.tex | tr -d '\n' | sed -e 's/--/\n/g' -e 's/\\En//g' \
  | tr -d '{}%' | tr -s ' ' | cut -c 11- | while read type label
  do
    printf "<h2>$label</h2>\n<table class=\"biblio-table\">\n"
    bib2bib -q -oc .tmp -c "entrysubtype: \"$type\"" cv.bib > /dev/null
    while read key
    do
      grep "<a name=\"$key\">" $items
    done < <(sort -r .tmp)
    printf "</table>\n"
    rm .tmp
  done
  awk '/<hr>/{end=1};end{print}' $target/publications.html | sed 's|</table>||'
) | tr "\t" "\n" > ~publications.html
rm $items
mv ~publications.html $target/publications.html

log "Generated html bibliography"

[ -n "$clean" ] && [ -n "$cleanafter" ] && clean

log "Done"
exit 0
