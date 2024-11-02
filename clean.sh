#!/bin/bash
if [ "$1" = "yes" ]; then
pushd Builds/
find . ! -type d -delete
popd
fi
exit
