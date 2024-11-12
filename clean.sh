#!/bin/bash

pushd Builds/
  if [ "$1" = "yes" ]; then
    find . ! -type d -delete
    for dev in RP64-rk3399 PBP-rk3399 PT2-rk3566 R5B-rk3588
    do
      for loc in $dev $dev-SB $dev-MU-SB
      do
        touch $loc/tmp
      done
    done
    for arch in rk3399 rk3568 rk3588
    do
      touch $arch/tmp
    done
  fi
  if [ "$1" = "cleanup" ]; then
    for dev in RP64-rk3399 PBP-rk3399 PT2-rk3566 R5B-rk3588
    do
      for loc in $dev $dev-SB $dev-MU-SB
      do
        rm -f $loc/tmp
      done
    done
    for arch in rk3399 rk3568 rk3588
    do
      rm -f $arch/tmp
    done
  fi
popd
rm -f builder.log && rm -f status.build
exit
