#!/bin/bash

echo "# Starting Build: $(date -u '+on %D at %R UTC')" >> Builds/release.sha512sum && echo "" >> Builds/release.sha512sum && echo "Starting Build: $(date -u '+on %D at %R UTC')"
rm -f -r /var/snap/docker/* && rm -f -r /var/snap/docker
snap remove docker --purge
mkdir /var/snap/docker
chown root:root /var/snap/docker
snap install docker --revision=2936 && ufw disable
sleep 5

source_date_epoch=1;
if [ "$1" != 0 ]; then
  echo 'Using override timestamp for SOURCE_DATE_EPOCH: $(date -d @$(($1)) = $1';
  source_date_epoch=$(($1));
else
  timestamp=$(date -d $(date +%D) +%s);
  if [ "${timestamp}" != "" ]; then
    echo "Setting SOURCE_DATE_EPOCH from today's date: $(date +%D) = @$timestamp";
    source_date_epoch=$((timestamp));
  else
    echo "Can't get timestamp. Defaulting to 1.";
    source_date_epoch=1;
  fi
fi

source_date="@$source_date_epoch"
build_message_timestamp="$(date +'%b %d %Y - 00:00:00 +0000' -d $source_date)";
echo "SOURCE_DATE: $source_date"
echo "SOURCE_DATE_EPOCH: $source_date_epoch"
echo "BUILD_MESSAGE_TIMESTAMP: $build_message_timestamp"
if [ "$2" = "yes" ]; then
  echo "DEV_BUILD: $DEV_BUILD"
fi
ARCHS=$(echo $ARCHS | tr ' ' '\n' | sort -u | tr '\n' ' ')
docker buildx create --name U-Boot-Builder --bootstrap --use

if [ "$2" = "" ]; then
  docker buildx build --load --target optee --tag optee \
    --build-arg SOURCE_DATE_EPOCH=$source_date_epoch \
    --build-arg OPT_VER=$OPT_VER \
    --build-arg OPT_SUM=$OPT_SUM \
    --build-arg HUB=$HUB \
    --build-arg BASE=$BASE \
    --build-arg BASE_EXTRA=$BASE_EXTRA \
    --build-arg ENTRYPOINT=optee \
    -f Dockerfile .
  mkdir -p "$HOME/syft" && TMPDIR="$HOME/syft" syft scan docker:optee -o spdx-json=Builds/optee-os.manifest.spdx.json && rm -f -r "$HOME/syft" 
  docker run -it --cpus=$(nproc) \
    --name optee \
    --user "$(id -u):$(id -g)" \
    --entrypoint /optee-buildscript.sh \
    -e SOURCE_DATE_EPOCH=$source_date_epoch \
    -e OPT_VER=$OPT_VER \
    optee
  
  docker cp optee:/optee_os-$OPT_VER/out/arm-plat-rockchip/core/tee.bin Builds/rk3399/
  sha512sum Builds/rk3399/tee.bin && sha512sum Builds/rk3399/tee.bin > Builds/release.sha512sum
  docker stop optee > /dev/null && echo "optee stopped" && docker rm --volumes optee > /dev/null && echo "optee removed"

  docker buildx build --load --target arm-trusted --tag arm-trusted \
    --build-arg SOURCE_DATE_EPOCH=$source_date_epoch \
    --build-arg BUILD_MESSAGE_TIMESTAMP="$build_message_timestamp" \
    --build-arg ATF_VER=$ATF_VER \
    --build-arg ATF_SUM=$ATF_SUM \
    --build-arg HUB=$HUB \
    --build-arg BASE=$BASE \
    --build-arg BASE_EXTRA=$BASE_EXTRA \
    --build-arg ENTRYPOINT=arm-trusted \
    -f Dockerfile .
  mkdir -p "$HOME/syft" && TMPDIR="$HOME/syft" syft scan docker:arm-trusted -o spdx-json=Builds/arm-trusted-firmware.manifest.spdx.json && rm -f -r "$HOME/syft" 
  docker run -it --cpus=$(nproc) \
    --name arm-trusted \
    --user "$(id -u):$(id -g)" \
    --entrypoint /arm-trusted-buildscript.sh \
    -e SOURCE_DATE_EPOCH=$source_date_epoch \
    -e BUILD_MESSAGE_TIMESTAMP="$build_message_timestamp" \
    -e ATF_VER=$ATF_VER \
    -e ARCHS="$ARCHS" \
    arm-trusted
  
  for arch in $ARCHS
  do
    docker cp arm-trusted:/$arch/arm-trusted-firmware-$ATF_VER/build/$arch/release/bl31/bl31.elf Builds/$arch/
    sha512sum Builds/$arch/bl31.elf && sha512sum Builds/$arch/bl31.elf >> Builds/release.sha512sum
  done
  docker stop arm-trusted > /dev/null && echo "arm-trusted stopped" && docker rm --volumes arm-trusted > /dev/null && echo "arm-trusted removed"
fi

docker buildx build --load --target u-boot --tag u-boot \
  --build-arg SOURCE_DATE_EPOCH=$source_date_epoch \
  --build-arg UB_VER=$UB_VER \
  --build-arg UB_SUM=$UB_SUM \
  --build-arg HUB=$HUB \
  --build-arg BASE=$BASE \
  --build-arg BASE_EXTRA=$BASE_EXTRA \
  --build-arg ENTRYPOINT=u-boot \
  -f Dockerfile .
mkdir -p "$HOME/syft" && TMPDIR="$HOME/syft" syft scan docker:u-boot -o spdx-json=Builds/u-boot.manifest.spdx.json && rm -f -r "$HOME/syft" 
docker run -it --cpus=$(nproc) \
  --name u-boot \
  --user "$(id -u):$(id -g)" \
  --entrypoint /u-boot-buildscript.sh \
  -e SOURCE_DATE_EPOCH=$source_date_epoch \
  -e SOURCE_DATE=$source_date \
  -e UB_VER=$UB_VER \
  -e BUILD_LIST="$BUILD_LIST" \
  -e DEV_BUILD=$2 \
  u-boot

for dev in $LIST
do
  for loc in $dev $dev-SB $dev-MU-SB
  do
    docker cp u-boot:/$loc/u-boot-$UB_VER/u-boot-rockchip.bin Builds/$loc/u-boot-rockchip.bin && sha512sum Builds/$loc/u-boot-rockchip.bin >> Builds/release.sha512sum
    docker cp u-boot:/$loc/u-boot-$UB_VER/u-boot-rockchip-spi.bin Builds/$loc/u-boot-rockchip-spi.bin && sha512sum Builds/$loc/u-boot-rockchip-spi.bin >> Builds/release.sha512sum
  done
done
docker cp u-boot:/sys.info sys.info

docker stop u-boot > /dev/null && echo "u-boot stopped"
docker rm --volumes u-boot > /dev/null && echo "u-boot removed"
snap disable docker
rm -f -r /var/snap/docker/* && rm -f -r /var/snap/docker
sleep 5
snap remove docker --purge
snap remove docker --purge
ufw -f enable

if [ "$2" = "" ]; then
  for dev in $LIST
  do
    for loc in $dev $dev-SB $dev-MU-SB
    do
      pushd Builds/$loc/
      dd if=/dev/zero of=/dev/mmcblk1 bs=1M count=100 status=progress
      parted /dev/mmcblk1 mktable gpt mkpart P1 fat32 15MB 34MB -s && sleep 3
      mkfs.fat /dev/mmcblk1p1 && mount /dev/mmcblk1p1 /mnt
      cp u-boot-rockchip.bin /mnt/u-boot-rockchip.bin
      cp u-boot-rockchip-spi.bin /mnt/u-boot-rockchip-spi.bin
      touch -c -d "$(date -R -d $source_date)" /mnt/*
      touch -c -d "$(date -R -d $source_date)" /mnt/
      dd if=/mnt/u-boot-rockchip.bin of=/dev/mmcblk1 seek=64 conv=notrunc status=progress
      sync && umount /mnt && dd if=/dev/mmcblk1 of=sdcard.img bs=1M count=35 status=progress
      touch -c -d "$(date -R -d $source_date)" sdcard.img
      popd
      sha512sum Builds/$loc/sdcard.img >> Builds/release.sha512sum
    done
  done
fi

dd if=/dev/zero of=/dev/mmcblk1 bs=1M count=100 status=progress
dd if=Builds/RP64-rk3399-SB/u-boot-rockchip.bin of=/dev/mmcblk1 seek=64 conv=notrunc status=progress

cat builder.log | grep -n Checksum && echo "" && echo "" >> Builds/release.sha512sum
echo "# 0mniteck's Current GPG Key ID: 287EE837E6ED2DD3" >> Builds/release.sha512sum && echo "" >> Builds/release.sha512sum
echo "# Source Date Epoch: $source_date_epoch" >> Builds/release.sha512sum
echo "# Build Complete: $(date -u '+on %D at %R UTC')" >> Builds/release.sha512sum && echo "Build Complete: $(date -u '+on %D at %R UTC')"
echo "# Base Build System: $(uname -o) $(uname -r) $(uname -p) $(lsb_release -ds) $(lsb_release -cs) $(uname -v)"  >> Builds/release.sha512sum
echo $(cat sys.info) >> Builds/release.sha512sum

echo "Successful Build of U-Boot v$UB_VER at $BUILD_MESSAGE_TIMESTAMP W/ TF-A commit $ATF_VER & OP-TEE v$OPT_VER" > status.build
