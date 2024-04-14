#!/bin/bash

job="Cleaning"
source $(dirname $0)/common.sh

(
  find . -name "*.aux" -o -name "[[:alpha:]]*.log";
  echo _site;
) | xargs rm -rvf | to_log

if [ $# -ge 1 ]
then
  tree . -I .git
fi
