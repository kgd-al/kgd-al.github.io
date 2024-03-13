#!/bin/bash

scripts=$(dirname $0)
source $scripts/common.sh

log=.build.log
date > $log

echo "Building navigation"
$scripts/auto_plan_and_navigation.sh >> $log

echo "Building cv"
$scripts/compile_cv.sh -c -a -e default \
    | tee -a $log | grep --color=never $'\e' | sed 's/^/> /'
