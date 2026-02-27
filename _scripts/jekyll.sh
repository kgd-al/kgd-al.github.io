#!/bin/bash

export LC_ALL=en_US.UTF-8
# bundle exec jekyll $@ 2>&1 | awk \
#   '/ERROR: directory is already being watched/{glob_error=1}
#    !glob_error{print}
#    glob_error&&/MORE INFO/{glob_error=0}'
bundle exec jekyll $@ 2>&1
