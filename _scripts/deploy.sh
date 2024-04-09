#!/bin/bash

if [ $# -eq 0 ]
then
    echo "No commit message provided"
    exit 1
fi

scripts=$(dirname $0)
source $scripts/common.sh

$scripts/build.sh | sed 's/^/> /'
echo "Building done"

$scripts/proof.sh | sed 's/^/> /'
echo "Checking done"

$scripts/clean.sh | sed 's/^/> /'
echo "Cleaned"

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
