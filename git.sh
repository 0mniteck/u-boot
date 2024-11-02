#!/bin/bash

git status && git add -A && git status
git commit -a -S -m "$1" && git push --set-upstream origin rk3399-Docker
