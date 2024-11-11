#!/usr/bin/env bash
trap '[[ $pid ]] && kill $pid; exit' EXIT
echo "SOURCE_DATE_EPOCH: $SOURCE_DATE_EPOCH"
echo "BUILD_MESSAGE_TIMESTAMP: $BUILD_MESSAGE_TIMESTAMP"
for plat in rk3399 rk3568
do
echo "Entering /$plat/arm-trusted-firmware-lts-v$ATF_VER"
pushd /$plat/arm-trusted-firmware-lts-v$ATF_VER
make realclean && make BUILD_MESSAGE_TIMESTAMP="$(echo '"'$BUILD_MESSAGE_TIMESTAMP'"')" PLAT=$plat bl31
ls -la build/$plat/release/bl31/
popd
done
