#!/usr/bin/env bash

trap '[[ $pid ]] && kill $pid; exit' EXIT

echo "SOURCE_DATE_EPOCH: ${SOURCE_DATE_EPOCH}"

echo "Entering /TEMPLATE"
pushd /TEMPLATE

echo "# Container Build System: $(uname -o) $(uname -r) $(uname -m) $(lsb_release -ds) $(uname -v)" > /sys.info
ls -la release/
popd
