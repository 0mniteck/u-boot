#!/usr/bin/env bash
trap '[[ $pid ]] && kill $pid; exit' EXIT
echo "SOURCE_DATE_EPOCH: ${SOURCE_DATE_EPOCH}"
echo "Entering /arm-trusted-firmware-lts-v${ATF_VER}"
pushd /arm-trusted-firmware-lts-v${ATF_VER}
make -j$(nproc) BUILD_MESSAGE_TIMESTAMP="$(echo '"'$BUILD_MESSAGE_TIMESTAMP'"')" PLAT=rk3399 bl31
ls -la /arm-trusted-firmware-lts-v$(echo $ATF_VER)/build/rk3399/release/bl31/
popd
