#!/usr/bin/env bash
trap '[[ $pid ]] && kill $pid; exit' EXIT
echo "SOURCE_DATE_EPOCH: $SOURCE_DATE_EPOCH"
echo "SOURCE_DATE: $SOURCE_DATE"
for dev in RP64-rk3399:rockpro64-rk3399_defconfig PBP-rk3399:pinebook-pro-rk3399_defconfig PT2-rk3566:pinetab2-rk3566_defconfig R5B-rk3588:rock5b-rk3588_defconfig
  do
  for loc in $(echo $dev | cut -d':' -f1): $(echo $dev | cut -d':' -f1)-SB:sb- $(echo $dev | cut -d':' -f1)-MU-SB:mutable-sb-
    do
    unzip -q /v$UB_VER.zip -d /$(echo $loc | cut -d':' -f1)
    echo "Entering /$(echo $loc | cut -d':' -f1)/u-boot-$UB_VER"
    pushd /$(echo $loc | cut -d':' -f1)/u-boot-$UB_VER
      make clean
      ./../../common-config.sh
      if [ "$(echo $dev | cut -d':' -f2)" != "" ]; then
        ./../../efi-config.sh
        ./../../$(echo $loc | cut -d':' -f2)config.sh
      fi
      cp /efi.var efi.var && echo "Deployed efi.var"
      cp /logo.bmp tools/logos/denx.bmp && cp /logo.bmp drivers/video/u_boot_logo.bmp && echo "Deployed Logo"
      if [ "$(echo $dev | cut -d':' -f2)" = "pinebook-pro-rk3399_defconfig" ]; then
        cp /rk3399-pinebook-pro-u-boot.dtsi arch/arm/dts/rk3399-pinebook-pro-u-boot.dtsi && echo "Patched Device Tree Bug"
      fi
      if [ "$(echo $dev | cut -d':' -f2)" = "rock5b-rk3588_defconfig" ]; then
        ./../../tpl-config.sh
        sed -i '112,117d' arch/arm/mach-rockchip/sdram.c && echo "Deployed Rockchip TPL Bypass"
      fi
      if [ "$(echo $dev | cut -d':' -f2)" = "pinetab2-rk3566_defconfig" ]; then
        ./../../tpl-config.sh
        echo "CONFIG_TPL_TINY_MEMSET=y >> defconfig
        sed -i '112,117d' arch/arm/mach-rockchip/sdram.c && echo "Deployed Rockchip TPL Bypass"
      fi
      sed -i 's/CONFIG_BAUDRATE=1500000/CONFIG_BAUDRATE=115200/' configs/$(echo $dev | cut -d':' -f2)
      cat defconfig >> configs/$(echo $dev | cut -d':' -f2) && echo "Appended Defconfig"
      cat configs/$(echo $dev | cut -d':' -f2)
      make $(echo $dev | cut -d':' -f2)
      platt=$(echo $(echo $dev | cut -d':' -f1) | cut -d'-' -f2)
      BL31=/$platt-bl31.elf FORCE_SOURCE_DATE=1 SOURCE_DATE=$SOURCE_DATE SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH make -j $(nproc) all
      ls -la
    popd
  done
done
echo "\# Container Build System: $(uname -o) $(uname -r) $(uname -m) $(lsb_release -ds) $(uname -v)" > /sys.info
