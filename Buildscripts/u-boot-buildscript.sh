#!/usr/bin/env bash
trap '[[ $pid ]] && kill $pid; exit' EXIT
echo "SOURCE_DATE_EPOCH: $SOURCE_DATE_EPOCH"
echo "SOURCE_DATE: $SOURCE_DATE"
./$CONFIG.sh
echo "Entering /RP64/u-boot-$UB_VER"
pushd /RP64/u-boot-$UB_VER
make clean
cp /efi.var efi.var && echo "Deployed efi.var"
cp /logo.bmp tools/logos/denx.bmp && cp /logo.bmp drivers/video/u_boot_logo.bmp
sed -i 's/CONFIG_BAUDRATE=1500000/CONFIG_BAUDRATE=115200/' configs/rockpro64-rk3399_defconfig
cat /rk3399_defconfig >> configs/rockpro64-rk3399_defconfig
cat configs/rockpro64-rk3399_defconfig
make rockpro64-rk3399_defconfig
FORCE_SOURCE_DATE=1 SOURCE_DATE=$SOURCE_DATE SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH make -j $(nproc) all
ls -la
popd
echo "Entering /PBP/u-boot-$UB_VER"
pushd /PBP/u-boot-$UB_VER
make clean
cp /rk3399-pinebook-pro-u-boot.dtsi arch/arm/dts/rk3399-pinebook-pro-u-boot.dtsi && echo "Patched Device Tree bug"
cp /efi.var efi.var && echo "Deployed efi.var"
cp /logo.bmp tools/logos/denx.bmp && cp /logo.bmp drivers/video/u_boot_logo.bmp
sed -i 's/CONFIG_BAUDRATE=1500000/CONFIG_BAUDRATE=115200/' configs/pinebook-pro-rk3399_defconfig
cat /rk3399_defconfig >> configs/pinebook-pro-rk3399_defconfig
cat configs/pinebook-pro-rk3399_defconfig
make pinebook-pro-rk3399_defconfig
FORCE_SOURCE_DATE=1 SOURCE_DATE=$SOURCE_DATE SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH make -j $(nproc) all
ls -la
popd
echo "# Container Build System: $(uname -o) $(uname -r) $(uname -m) $(lsb_release -ds) $(uname -v)" > /sys.info
