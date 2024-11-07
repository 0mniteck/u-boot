#!/bin/bash
if [ "$1" = "yes" ]; then
  pushd Builds/
  find . ! -type d -delete
  for loc in RP64-rk3399 PBP-rk3399 RP64-rk3399-SB PBP-rk3399-SB
  do
    touch $loc/tmp
  done
  popd
elseif [ "$1" = "cleanup" ];
  for loc in RP64-rk3399 PBP-rk3399 RP64-rk3399-SB PBP-rk3399-SB
  do
    rm -f $loc/tmp
  done
fi
rm -f /tmp/builder.log
exit
