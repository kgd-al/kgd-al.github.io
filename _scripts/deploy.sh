#!/bin/bash

if [ $# -eq 0 ]
then
    echo "No commit message provided"
    exit 1
fi

#set -x
scripts=$(dirname $0)
source $scripts/common.sh
date > $log

$scripts/build.sh | sed 's/^/> /' || exit 1
$scripts/proof.sh | sed 's/^/> /' || exit 2
$scripts/clean.sh | sed 's/^/> /' || exit 3

if [ "$1" != "test" ]
then
    git commit -a -m "$@"

    echo "Checking repository"
    if [ -n "$(git status --porcelain=2)" ]
    then
        echo "Repository not clean. Refusing to push"
        git status
        exit 1
    fi

    git push
fi
