#!/bin/bash

source $(dirname $0)/common.sh

log=.proof.log
date > $log
job="Proofing"

export LC_ALL=en_US.UTF-8
step "htmlproofer" bundle exec htmlproofer _site \
    --allow-missing-href=true --enforce-https=false \
    --ignore-urls "/.*10.13140/RG\..*/,/doi.org/,/dl.acm.org/" \
    --ignore-status-codes 0
export LC_ALL=C
