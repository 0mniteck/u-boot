#!/bin/bash -e

##
##	RockPro64 SPI-Uboot Assembler
##		Requirements: debian based OS already running on the RockPro64, any size Fat formatted microsd in the MMCBLK1 slot w/ no MBR/GUID
##

cd /tmp/
apt update && apt install build-essential bc zip unzip bison flex libssl-dev gcc-arm-none-eabi device-tree-compiler swig python3-pyelftools python3-dev -y
wget https://github.com/ARM-software/arm-trusted-firmware/archive/refs/tags/lts-v2.8.6.zip
echo '843ddf990a8aae0233eded7558e2d4147d0e43be98432614d1223bb6ffa50d200532b6ec043e862ea80b61642ae064984478b52989d8dbb6806b3da2e63cb76d  lts-v2.8.6.zip' > v2.zip.sum
if [[ $(sha512sum -c v2.zip.sum) == 'lts-v2.8.6.zip: OK' ]]; then sleep 0; else exit 1; fi;
wget https://github.com/u-boot/u-boot/archive/refs/tags/v2023.04.zip
echo '81be2e176ece1301fd7c7eafa8b46cda17b9be55025f5ed6d7dad4ea9d5e4db8eb86e229103517b584be294917ff4f9c6c43cd7ddf8067f2e2350408816dea1b  v2023.04.zip' > v2023.zip.sum
if [[ $(sha512sum -c v2023.zip.sum) == 'v2023.04.zip: OK' ]]; then sleep 0; else exit 1; fi;
unzip v202*.zip
unzip lts*.zip
cd arm-trusted-firmware-*
sed -i '/--fatal-warnings -O1/ s/$/ --no-warn-rwx-segments/' Makefile
make realclean
make PLAT=rk3399
export BL31=/tmp/arm-trusted-firmware-lts-v2.8.6/build/rk3399/release/bl31/bl31.elf
cd ..
cd u-boot-202*
sed -i 's/CONFIG_BAUDRATE=1500000/CONFIG_BAUDRATE=115200/' configs/rockpro64-rk3399_defconfig
make rockpro64-rk3399_defconfig #rpi_3_b_plus_defconfig
make all
image_name="spi_idbloader.img"
combined_name="spi_combined.img"
tools/mkimage -n rk3399 -T rkspi -d tpl/u-boot-tpl.bin:spl/u-boot-spl.bin "${image_name}"
padsize=$((0x60000 - 1))
image_size=$(wc -c < "${image_name}")
[ $image_size -le $padsize ] || exit 1
dd if=/dev/zero of="${image_name}" conv=notrunc bs=1 count=1 seek=${padsize}
cat ${image_name} u-boot.itb > "${combined_name}"
mount /dev/mmcblk1 /mnt
sha512sum spi_combined.img > /mnt/spi_combined.img.sum
#dd if=u-boot-rockchip.bin of=/dev/mmcblk1
cp spi_combined.img /mnt/spi_combined.img
sync
umount /mnt
cd ..
apt remove --purge build-essential bc zip unzip bison flex libssl-dev gcc-arm-none-eabi device-tree-compiler swig python3-pyelftools  python3-dev -y && apt autoremove -y && rm -f -r /tmp/u-boot-202* && rm -f /tmp/lts-* && rm -f /tmp/v2* && rm -f -r /tmp/arm-trusted-firmware-*
