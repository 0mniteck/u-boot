#!/bin/bash

chmod +x Configs/dev-config.sh
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
    for arch in rk3399 rk3568
    do
      touch $arch/tmp
    done
  elseif [ "$1" = "cleanup" ];
    for dev in RP64-rk3399 PBP-rk3399 PT2-rk3566
    do
      for loc in $dev $dev-SB $dev-MU-SB
      do
        rm -f $loc/tmp
      done
    done
    for arch in rk3399 rk3568
    do
      rm -f $arch/tmp
    done
  fi
popd
rm -f /tmp/builder.log && rm -f /tmp/status.build
exit
