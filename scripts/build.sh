#!/bin/bash

scripts=$(dirname $0)
source $scripts/common.sh

log=.log
date > $log

echo "Building navigation"
$scripts/auto_navigation.sh >> $log

echo "Building cv"
$scripts/compile_cv.sh -c -a >> $log
