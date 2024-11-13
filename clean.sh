#!/bin/bash

chmod +x Configs/*
pushd Builds/
  if [ "$1" = "yes" ]; then
    find . ! -type d -delete
    for dev in $LIST
    do
      for loc in $dev $dev-SB $dev-MU-SB
      do
        touch $loc/tmp
      done
    done
    for arch in $ARCHS
    do
      touch $arch/tmp
    done
  fi
  if [ "$1" = "cleanup" ]; then
    for dev in $LIST
    do
      for loc in $dev $dev-SB $dev-MU-SB
      do
        rm -f $loc/tmp
      done
    done
    for arch in $ARCHS
    do
      rm -f $arch/tmp
    done
  fi
popd
rm -f builder.log && rm -f status.build && rm -f sys.info
exit
