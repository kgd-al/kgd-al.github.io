#!/bin/bash

job=Building
scripts=$(dirname $0)
source $scripts/common.sh

step "Building cv" $scripts/compile_cv.sh -c -a -e default || exit $?
step "Building navigation" $scripts/auto_plan_and_navigation.sh
step "Building site locally" $scripts/jekyll.sh build
step "Generating gallery" $scripts/generate_gallery.sh
