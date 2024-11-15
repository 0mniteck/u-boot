#!/usr/bin/env bash
trap '[[ $pid ]] && kill $pid; exit' EXIT
for dev in $BUILD_LIST
  do
  for loc in $(echo $dev | cut -d':' -f1): $(echo $dev | cut -d':' -f1)-SB:sb- $(echo $dev | cut -d':' -f1)-MU-SB:mutable-sb-
    do
    echo "Unzipping U-Boot for $(echo $dev | cut -d':' -f1)..."
    unzip -q /v$UB_VER.zip -d /$(echo $loc | cut -d':' -f1) > /dev/null
    echo "Entering /$(echo $loc | cut -d':' -f1)/u-boot-$UB_VER"
    pushd /$(echo $loc | cut -d':' -f1)/u-boot-$UB_VER
      make clean
      if [ "$DEV_BUILD" = "yes" ]; then
        ../.././Configs/dev-config.sh
      else
        ../.././Configs/common-config.sh
        if [ "$(echo $loc | cut -d':' -f2)" != "" ]; then
          ../.././Configs/efi-config.sh
          ../.././Configs/$(echo $loc | cut -d':' -f2)config.sh
        fi
      fi
      cp /Includes/efi.var efi.var
      sha512sum --status -c /Includes/efi.var.sum && echo "Deployed efi.var" || exit 1
      cp /Includes/logo.bmp tools/logos/denx.bmp && cp /Includes/logo.bmp drivers/video/u_boot_logo.bmp && echo "Deployed Logo"
      if [ "$(echo $dev | cut -d':' -f2)" = "pinebook-pro-rk3399_defconfig" ]; then
        cp /Includes/rk3399-pinebook-pro-u-boot.dtsi arch/arm/dts/rk3399-pinebook-pro-u-boot.dtsi && echo "Patched Device Tree Bug"
      fi
      if [ "$(echo $dev | cut -d':' -f2)" = "rock5b-rk3588_defconfig" ]; then
        ../.././Configs/tpl-config.sh
        sed -i '112,117d' arch/arm/mach-rockchip/sdram.c && echo "Deployed Rockchip TPL Bypass"
      fi
      if [ "$(echo $dev | cut -d':' -f2)" = "pinetab2-rk3566_defconfig" ]; then
        ../.././Configs/tpl-config.sh
        echo "CONFIG_TPL_TINY_MEMSET=y" >> defconfig
        sed -i '112,117d' arch/arm/mach-rockchip/sdram.c && echo "Deployed Rockchip TPL Bypass"
      fi
      sed -i 's/CONFIG_BAUDRATE=1500000/CONFIG_BAUDRATE=115200/' configs/$(echo $dev | cut -d':' -f2)
      cat defconfig >> configs/$(echo $dev | cut -d':' -f2) && echo "Appended Defconfig"
      cat configs/$(echo $dev | cut -d':' -f2)
      make $(echo $dev | cut -d':' -f2)
      platt=$(echo $(echo $dev | cut -d':' -f1) | cut -d'-' -f2)
      if [ "$platt" = "rk3566" ]; then
        platt=rk3568
      fi
      BL31=/Builds/$platt/bl31.elf FORCE_SOURCE_DATE=1 SOURCE_DATE=$SOURCE_DATE SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH make -j $(nproc) all
      ls -la
    popd
  done
done
echo "# Container Build System: $(uname -o) $(uname -r) $(uname -m) $(lsb_release -ds) $(uname -v)" > /sys.info
