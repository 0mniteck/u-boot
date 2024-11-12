#!/usr/bin/env bash
trap '[[ $pid ]] && kill $pid; exit' EXIT
echo "SOURCE_DATE_EPOCH: $SOURCE_DATE_EPOCH"
RUN unzip -q $OPT_VER.zip
echo "Entering /optee_os-$OPT_VER"
pushd /optee_os-$OPT_VER
make -j $(nproc) PLATFORM=rockchip-rk3399 CFG_ARM64_core=y CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE32=arm-linux-gnueabihf- CROSS_COMPILE_core=aarch64-linux-gnu- CROSS_COMPILE_ta_arm32=arm-linux-gnueabihf- CROSS_COMPILE_ta_arm64=aarch64-linux-gnu-
ls -la /optee_os-$OPT_VER/out/arm-plat-rockchip/core/
popd
