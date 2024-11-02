#!/usr/bin/env bash

trap '[[ $pid ]] && kill $pid; exit' EXIT

echo "SOURCE_DATE_EPOCH: ${SOURCE_DATE_EPOCH}"

echo "Entering /TEMPLATE"
pushd /TEMPLATE
sha512sum release/*.file && sha512sum release/*.file > release/release.sha512sum
echo "# 0mniteck's Current GPG Key ID: 287EE837E6ED2DD3" >> release/release.sha512sum
echo "Source Date Epoch: ${SOURCE_DATE_EPOCH}" >> release/release.sha512sum
echo "Build Complete: "$(date -u '+on %D at %R UTC') && echo "# Build Complete: "$(date -u '+on %D at %R UTC') >> release/release.sha512sum
echo "# Container Build System: $(uname -o) $(uname -r) $(uname -m) $(lsb_release -ds) $(uname -v)"  >> release/release.sha512sum
ls -la release/
popd
