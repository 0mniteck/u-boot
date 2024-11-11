#!/usr/bin/env bash
trap '[[ $pid ]] && kill $pid; exit' EXIT
echo "SOURCE_DATE_EPOCH: $SOURCE_DATE_EPOCH"
echo "Entering /rk3399/arm-trusted-firmware-lts-v$ATF_VER"
pushd /rk3399/arm-trusted-firmware-lts-v$ATF_VER
make realclean && make BUILD_MESSAGE_TIMESTAMP="$(echo '"'$BUILD_MESSAGE_TIMESTAMP'"')" PLAT=rk3399 bl31
ls -la build/rk3399/release/bl31/
popd
echo "Entering /rk3568/arm-trusted-firmware-lts-v$ATF_VER"
pushd /rk3568/arm-trusted-firmware-lts-v$ATF_VER
make realclean && make BUILD_MESSAGE_TIMESTAMP="$(echo '"'$BUILD_MESSAGE_TIMESTAMP'"')" PLAT=rk3568 bl31
ls -la build/rk3568/release/bl31/
popd
