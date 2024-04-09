#!/bin/bash

source $(dirname $0)/common.sh

export LC_ALL=en_US.UTF-8
bundle exec jekyll build
bundle exec htmlproofer _site \
    --allow-missing-href=true --enforce-https=false \
    --ignore-urls "/.*10.13140/RG\..*/" \
    --ignore-status-codes 0
export LC_ALL=C
