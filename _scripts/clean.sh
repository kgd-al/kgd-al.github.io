#!/bin/bash

source $(dirname $0)/common.sh

(
  find . -name "*.aux" -o -name "[[:alpha:]]*.log";
  echo _site;
) | xargs rm -rvf

[ $# -ge 1 ] && tree . -I .git
