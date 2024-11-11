#!/usr/bin/env bash
trap '[[ $pid ]] && kill $pid; exit' EXIT
echo "SOURCE_DATE_EPOCH: $SOURCE_DATE_EPOCH"
echo "SOURCE_DATE: $SOURCE_DATE"
for dev in RP64-rk3399:rockpro64-rk3399_defconfig PBP-rk3399:pinebook-pro-rk3399_defconfig PT2-rk3566:pinetab2-rk3566_defconfig
  do
  for loc in $(echo $dev | cut -d':' -f1): $(echo $dev | cut -d':' -f1)-SB:sb- $(echo $dev | cut -d':' -f1)-MU-SB:mutable-sb-
    do
    echo "Entering /$(echo $loc | cut -d':' -f1)/u-boot-$UB_VER"
    pushd /$(echo $loc | cut -d':' -f1)/u-boot-$UB_VER
      make clean
      ./$(echo $loc | cut -d':' -f2)config.sh
      cp /efi.var efi.var && echo "Deployed efi.var"
      cp /logo.bmp tools/logos/denx.bmp && cp /logo.bmp drivers/video/u_boot_logo.bmp
      cp /rk3399-pinebook-pro-u-boot.dtsi arch/arm/dts/rk3399-pinebook-pro-u-boot.dtsi && echo "Patched Device Tree bug"
      sed -i 's/CONFIG_BAUDRATE=1500000/CONFIG_BAUDRATE=115200/' configs/$(echo $dev | cut -d':' -f2)
      cat defconfig >> configs/$(echo $dev | cut -d':' -f2)
      cat configs/$(echo $dev | cut -d':' -f2)
      make $(echo $dev | cut -d':' -f2)
      FORCE_SOURCE_DATE=1 SOURCE_DATE=$SOURCE_DATE SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH make -j $(nproc) all
      ls -la
    popd
  done
done
pinetab2-rk3566_defconfig
echo "# Container Build System: $(uname -o) $(uname -r) $(uname -m) $(lsb_release -ds) $(uname -v)" > /sys.info
