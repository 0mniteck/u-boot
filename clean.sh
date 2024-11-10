#!/bin/bash

pushd Builds/
  if [ "$1" = "yes" ]; then
    find . ! -type d -delete
    for dev in RP64-rk3399 PBP-rk3399 PT2-rk3566
    do
      for loc in $dev $dev-SB $dev-MU-SB
      do
        touch $loc/tmp
      done
    done
  elseif [ "$1" = "cleanup" ];
    for dev in RP64-rk3399 PBP-rk3399 PT2-rk3566
    do
      for loc in $dev $dev-SB $dev-MU-SB
      do
        rm -f $loc/tmp
      done
    done
  fi
popd
rm -f /tmp/builder.log
exit
