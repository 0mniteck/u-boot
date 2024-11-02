#!/bin/bash

rm -f -r /var/snap/docker/*
rm -f -r /var/snap/docker
snap remove docker --purge
mkdir /var/snap/docker
chown root:root /var/snap/docker
snap install docker --revision=2936
ufw disable
sleep 10

OPT_VER=4.4.0;
ATF_VER=2.10.9;
UB_VER=2024.10;

source_date_epoch=1
if [ "$1" != 0 ]; then
  echo "Using override timestamp for SOURCE_DATE_EPOCH: "$(date -d @$(($1))" = "$1
  source_date_epoch=$(($1))
else
  timestamp=$(date -d $(date +%D) +%s)
  if [ "${timestamp}" != "" ]; then
    echo "Setting SOURCE_DATE_EPOCH from today's date: "$(date +%D)" = @"$timestamp
    source_date_epoch=$((timestamp))
  else
    echo "Can't get timestamp. Defaulting to 1."
    source_date_epoch=1
  fi
fi

if [ -f Builds/tee.bin ]; then
  cp Builds/tee.bin /tmp/tee.bin
else
docker build --target optee -t optee \
  --build-arg SOURCE_DATE_EPOCH=$source_date_epoch \
  --build-arg OPT_VER=$OPT_VER \
  --build-arg ENTRYPOINT=optee .
docker run -it --cpus=$(nproc) \
  --name optee \
  --user "$(id -u):$(id -g)" \
  -e SOURCE_DATE_EPOCH=$source_date_epoch \
  -e OPT_VER=$OPT_VER \
  optee
docker cp optee:/optee_os-$OPT_VER/out/arm-plat-rockchip/core/tee.bin builds/
sha512sum builds/tee.bin && sha512sum builds/tee.bin > Builds/release.sha512sum
read -p "Continue to Git Signing-->"
./git.sh "Successful Build of OP-TEE v"$OPT_VER
fi

if [ -f Builds/bl31.elf ]; then
  cp Builds/bl31.elf /tmp/bl31.elf
else
docker build --target arm-trusted -t arm-trusted \
  --build-arg SOURCE_DATE_EPOCH=$source_date_epoch \
  --build-arg ATF_VER=$ATF_VER \
  --build-arg ENTRYPOINT=arm-trusted .
docker run -it --cpus=$(nproc) \
  --name arm-trusted \
  --user "$(id -u):$(id -g)" \
  -e SOURCE_DATE_EPOCH=$source_date_epoch \
  -e ATF_VER=$ATF_VER \
  arm-trusted
docker cp arm-trusted:/arm-trusted-firmware-lts-v$(echo $ATF_VER)/build/rk3399/release/bl31/bl31.elf builds/
sha512sum builds/bl31.elf && sha512sum builds/bl31.elf >> Builds/release.sha512sum
read -p "Continue to Git Signing-->"
./git.sh "Successful Build of TF-A v"$ATF_VER
fi

docker build --target u-boot -t u-boot \
  --build-arg SOURCE_DATE_EPOCH=$source_date_epoch \
  --build-arg UB_VER=$UB_VER \
  --build-arg ENTRYPOINT=u-boot .
docker run -it --cpus=$(nproc) \
  --name u-boot \
  --user "$(id -u):$(id -g)" \
  -e SOURCE_DATE_EPOCH=$source_date_epoch \
  -e UB_VER=$UB_VER \
  u-boot
docker cp u-boot:/u-boot-$UB_VER/u-boot-rockchip.bin builds/u-boot-rockchip.bin && sha512sum builds/u-boot-rockchip.bin >> Builds/release.sha512sum
docker cp u-boot:/u-boot-$UB_VER/u-boot-rockchip-spi.bin builds/u-boot-rockchip-spi.bin && sha512sum builds/u-boot-rockchip-spi.bin >> Builds/release.sha512sum
docker cp u-boot:/u-boot-$UB_VER/u-boot-rockchip.bin builds/u-boot-rockchip.bin && sha512sum builds/u-boot-rockchip.bin >> Builds/release.sha512sum
docker cp u-boot:/u-boot-$UB_VER/u-boot-rockchip-spi.bin builds/u-boot-rockchip-spi.bin && sha512sum builds/u-boot-rockchip-spi.bin >> Builds/release.sha512sum

docker build --target u-boot -t u-boot-sb \
  --build-arg SOURCE_DATE_EPOCH=$source_date_epoch \
  --build-arg UB_VER=$UB_VER \
  --build-arg ENTRYPOINT=u-boot-sb .
docker run -it --cpus=$(nproc) \
  --name u-boot-sb \
  --user "$(id -u):$(id -g)" \
  -e SOURCE_DATE_EPOCH=$source_date_epoch \
  -e UB_VER=$UB_VER \
  u-boot-sb
docker cp u-boot-sb:/u-boot-$UB_VER/u-boot-rockchip.bin builds/u-boot-rockchip.bin && sha512sum builds/u-boot-rockchip.bin >> Builds/release.sha512sum
docker cp u-boot-sb:/u-boot-$UB_VER/u-boot-rockchip-spi.bin builds/u-boot-rockchip-spi.bin && sha512sum builds/u-boot-rockchip-spi.bin >> Builds/release.sha512sum
docker cp u-boot-sb:/u-boot-$UB_VER/u-boot-rockchip.bin builds/u-boot-rockchip.bin && sha512sum builds/u-boot-rockchip.bin >> Builds/release.sha512sum
docker cp u-boot-sb:/u-boot-$UB_VER/u-boot-rockchip-spi.bin builds/u-boot-rockchip-spi.bin && sha512sum builds/u-boot-rockchip-spi.bin >> Builds/release.sha512sum
docker cp u-boot-sb:/sys.info /tmp/sys.info

echo "# 0mniteck's Current GPG Key ID: 287EE837E6ED2DD3" >> Builds/release.sha512sum
echo "Source Date Epoch: ${SOURCE_DATE_EPOCH}" >> Builds/release.sha512sum
echo "Build Complete: "$(date -u '+on %D at %R UTC') && echo "# Build Complete: "$(date -u '+on %D at %R UTC') >> Builds/release.sha512sum
echo "# Base Build System: $(uname -o) $(uname -r) $(uname -p) $(lsb_release -ds) $(lsb_release -cs) $(uname -v)"  >> Builds/release.sha512sum
echo $(cat /tmp/sys.info) >> Builds/release.sha512sum

read -p "Continue to Git Signing-->"
./git.sh "Successful Build of U-Boot v$UB_VER at $BUILD_MESSAGE_TIMESTAMP W/ TF-A v$ATF_VER & OP-TEE v$OPT_VER For The RockPro64"

snap disable docker
rm -f -r /var/snap/docker/*
rm -f -r /var/snap/docker
sleep 10
snap remove docker --purge
snap remove docker --purge
ufw -f enable
read -p "Continue: -->"
