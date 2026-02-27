#!/bin/bash

job=Building
scripts=$(dirname $0)
source $scripts/common.sh

if [ -z "$(which bundle)" ]
then
    echo "Could not find requirement 'bundle'. Please double check following instructions"
    $scripts/install_requirements.sh
    exit 1
fi

step "Building cv" $scripts/compile_cv.sh -c -a -e default || exit $?
step "Building navigation" $scripts/auto_plan_and_navigation.sh
step "Building site locally" $scripts/jekyll.sh build
echo $?
step "Generating gallery" $scripts/generate_gallery.sh
