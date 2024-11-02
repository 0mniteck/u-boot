#!/usr/bin/env bash
trap '[[ $pid ]] && kill $pid; exit' EXIT
echo "SOURCE_DATE_EPOCH: ${SOURCE_DATE_EPOCH}"
echo "Entering /TEMPLATE"
pushd /TEMPLATE
ls -la release/
popd
