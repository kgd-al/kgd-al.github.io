#!/bin/bash

set -euo pipefail
shopt -s inherit_errexit

$(dirname $0)/build.sh
echo "Building done"

echo "Checking repository"
if [ -n "$(git status --porcelain=2)" ]
then
    echo "Repository not clean. Refusing to commit"
    git status
    exit 1
fi

git push
