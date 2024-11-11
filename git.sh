#!/bin/bash

git status && git add -A && git status
git commit -a -S -m "$1" && sleep 5 && git push --set-upstream origin Docker
if [ "$2" != "" ]; then
  git tag -a "$2" -s -m "Tagged Release $2" && sleep 5 && git push origin "$2"
fi
