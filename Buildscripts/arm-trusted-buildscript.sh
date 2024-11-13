#!/usr/bin/env bash
trap '[[ $pid ]] && kill $pid; exit' EXIT
echo "SOURCE_DATE_EPOCH: $SOURCE_DATE_EPOCH" && echo "BUILD_MESSAGE_TIMESTAMP: $BUILD_MESSAGE_TIMESTAMP"
ARCHS=$(echo $ARCHS | tr ' ' '\n' | sort -u | tr '\n' ' ')
for plat in $ARCHS
do
  unzip -q $ATF_VER.zip -d /$plat
  echo "Entering /$plat/arm-trusted-firmware-$ATF_VER"
  pushd /$plat/arm-trusted-firmware-$ATF_VER
    make realclean && make BUILD_MESSAGE_TIMESTAMP="$(echo '"'$BUILD_MESSAGE_TIMESTAMP'"')" PLAT=$plat bl31
    ls -la build/$plat/release/bl31/
  popd
done
