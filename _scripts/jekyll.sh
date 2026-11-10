#!/bin/bash

if [ $# -eq 0 ]
then
    echo "Usage: $0 <cmds...>"
    echo
    echo "Encapsulates jekyll layer"
    echo "Typical usage:"
    echo "  $0 build"
    echo "  $0 serve --livereload"
    echo "    (to have the website on localhost, rebuilt on source changes)"
    exit 1
fi

export LC_ALL=en_US.UTF-8
# bundle exec jekyll $@ 2>&1 | awk \
#   '/ERROR: directory is already being watched/{glob_error=1}
#    !glob_error{print}
#    glob_error&&/MORE INFO/{glob_error=0}'
bundle exec jekyll $@ 2>&1
