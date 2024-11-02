#!/bin/bash

git status && git add -A && git status
git commit -a -S -m "Successful Build of Reproducible Release x.xx.x" && git push --set-upstream origin master
