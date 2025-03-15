sources=src
download=download
autogen=__generated

log=.log

_grep() { grep $@ || test $? = 1; }
_field() { _grep $@ | cut -d ' ' -f 2-; }

to_log() {
  tee -a $log | _grep --color=never $'\e' | sed 's/^/> /';
}

print_colored() {
  printf "\033[%dm%s\033[0m\n" $1 "$2"
}
COLOR_RED=31
COLOR_GREEN=32
COLOR_VIOLET=35
COLOR_OK=$COLOR_GREEN
COLOR_NOK=$COLOR_RED
COLOR_NEUTRAL=$COLOR_VIOLET

_step=""
on_exit(){
  code=$?
  [ -z "$_step" ] && exit $code
  if [ $code -eq 0 ]
  then
    print_colored $COLOR_OK "$job successful!"
  else
    print_colored $COLOR_NOK "Error at step '$_step' for job $job"
    tail $log
  fi
  exit $code
}

trap on_exit EXIT

step() {
  _step="$1"
  print_colored $COLOR_NEUTRAL "$_step"
  shift
  $@ | to_log
  print_colored $COLOR_NEUTRAL "... done"
}

_job=""
job(){
  _job=$1
  export _job
}

if [ -n "$_job" ]
then
  echo "$(date) $_job start" >> $log
fi
