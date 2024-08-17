#!/bin/bash -e

##
##	RockPro64 SPI U-Boot Assembler
##		Requirements: Debian based OS running on an ARM64 CPU & any size microSD in the MMCBLK1 slot
##		  By: Shant Tchatalbachian
##

OPT_VER=4.3.0;
ATF_VER=2.10.4;
UB_VER=2024.07;
SOURCE_DATE_EPOCH=$(date -d $(date +%D) +%s);
BUILD_MESSAGE_TIMESTAMP='"'$(date -d $(date +%D))'"';

git remote remove origin && git remote add origin git@UBoot:0mniteck/U-Boot.git
rm -f spi_combined.zip
cp 0001-rockchip-rk3399-fix-SPI-NOR-flash-not-found-in-U-Boo.patch /tmp/0001-rockchip-rk3399.patch
cp logo.bmp /tmp/logo.bmp
pushd /tmp/
apt update && apt install bc bison build-essential device-tree-compiler dosfstools flex gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi libncurses-dev libssl-dev parted python3-dev python3-pyelftools python3-setuptools swig unzip zip -y
wget https://github.com/OP-TEE/optee_os/archive/refs/tags/$(echo $OPT_VER).zip
echo '04a2e85947283e49a79cb8d60fde383df28303a9be15080a7f5354268b01f16405178c0c570e253256c3be8e3084d812c8b46b6dc2cb5c8eb3bde8d2ba4c380e  '$(echo $OPT_VER)'.zip' > $(echo $OPT_VER).zip.sum
if [[ $(sha512sum -c $(echo $OPT_VER).zip.sum) == $(echo $OPT_VER)'.zip: OK' ]]; then echo 'OP-TEE Checksum Matched!'; else echo 'OP-TEE Checksum Mismatched!' & exit 1; fi;
wget https://github.com/ARM-software/arm-trusted-firmware/archive/refs/tags/lts-v$(echo $ATF_VER).zip
echo '5252dc59f1133d9c3fae5560954d9810e97a7e3b018522fddea584343d742a110c65678115cb0f554c201b5f7326353eec9a54031485156b6ca0788f53d33882  lts-v'$(echo $ATF_VER)'.zip' > v$(echo $ATF_VER).zip.sum
if [[ $(sha512sum -c v$(echo $ATF_VER).zip.sum) == 'lts-v'$(echo $ATF_VER)'.zip: OK' ]]; then echo 'ATF Checksum Matched!'; else echo 'ATF Checksum Mismatched!' & exit 1; fi;
git clone https://github.com/u-boot/u-boot.git -b v$(echo $UB_VER)
unzip $(echo $OPT_VER).zip
unzip lts-v$(echo $ATF_VER).zip
cd optee_os-$(echo $OPT_VER)
echo "Entering OP-TEE ------"
make -j$(nproc) PLATFORM=rockchip-rk3399 CFG_ARM64_core=y
export TEE=/tmp/optee_os-$(echo $OPT_VER)/out/arm-plat-rockchip/core/tee.bin
cd ..
cd arm-trusted-firmware-lts-v$(echo $ATF_VER)
echo "Entering TF-A ------"
make realclean
make PLAT=rk3399 bl31
export BL31=/tmp/arm-trusted-firmware-lts-v$(echo $ATF_VER)/build/rk3399/release/bl31/bl31.elf
cd ..
cd u-boot
echo "Entering U-Boot ------"
git am < ../0001-rockchip-rk3399.patch
rm tools/logos/denx.bmp && rm drivers/video/u_boot_logo.bmp
cp /tmp/logo.bmp tools/logos/denx.bmp && cp /tmp/logo.bmp drivers/video/u_boot_logo.bmp
sed -i 's/CONFIG_BAUDRATE=1500000/CONFIG_BAUDRATE=115200/' configs/rockpro64-rk3399_defconfig
make rockpro64-rk3399_defconfig
make SOURCE_DATE_EPOCH=$(echo $SOURCE_DATE_EPOCH) -j$(nproc) all
image_name="spi_idbloader.img"
combined_name="spi_combined.img"
tools/mkimage -n rk3399 -T rkspi -d tpl/u-boot-tpl.bin:spl/u-boot-spl.bin "${image_name}"
padsize=$((0x60000 - 1))
image_size=$(wc -c < "${image_name}")
dd if=/dev/zero of="${image_name}" conv=notrunc bs=1 count=1 seek=${padsize}
cat ${image_name} u-boot.itb > "${combined_name}"
sha512sum spi_combined.img
sha512sum u-boot-rockchip.bin
sha512sum u-boot-rockchip-spi.bin
read -p "Insert any SD Card, Then Press Enter to Continue"
dd if=/dev/zero of=/dev/mmcblk1 bs=1M count=2000 status=progress
parted /dev/mmcblk1 mktable gpt mkpart P1 fat32 16MB 1G -s && sleep 3
mkfs.fat /dev/mmcblk1p1
mount /dev/mmcblk1p1 /mnt
sha512sum spi_combined.img
sha512sum spi_combined.img > /mnt/spi_combined.img.sum
sha512sum spi_combined.img > /tmp/spi_combined.img.sum
cp spi_combined.img /mnt/spi_combined.img
cp spi_combined.img /tmp/spi_combined.img
sha512sum u-boot-rockchip.bin
sha512sum u-boot-rockchip.bin > /mnt/u-boot-rockchip.bin.sum
sha512sum u-boot-rockchip.bin > /tmp/u-boot-rockchip.bin.sum
cp u-boot-rockchip.bin /mnt/u-boot-rockchip.bin
cp u-boot-rockchip.bin /tmp/u-boot-rockchip.bin
sha512sum u-boot-rockchip-spi.bin
sha512sum u-boot-rockchip-spi.bin > /mnt/u-boot-rockchip-spi.bin.sum
sha512sum u-boot-rockchip-spi.bin > /tmp/u-boot-rockchip-spi.bin.sum
cp u-boot-rockchip-spi.bin /mnt/u-boot-rockchip-spi.bin
cp u-boot-rockchip-spi.bin /tmp/u-boot-rockchip-spi.bin
sync
umount /mnt
dd if=u-boot-rockchip.bin of=/dev/mmcblk1 seek=64 conv=notrunc status=progress
cd ..
zip -0 spi_combined.zip spi_combined.img spi_combined.img.sum u-boot-rockchip.bin u-boot-rockchip.bin.sum u-boot-rockchip-spi.bin u-boot-rockchip-spi.bin.sum
sha512sum spi_combined.zip
sync
popd
sha512sum /tmp/spi_combined.zip > /tmp/spi_combined.zip.sum
cp /tmp/spi_combined.zip.sum spi_combined.zip.sum
cp /tmp/spi_combined.zip spi_combined.zip
sha512sum spi_combined.zip
git status && git add -A && git status
read -p "Successful Build of U-Boot v$(echo $UB_VER) at $(echo $BUILD_MESSAGE_TIMESTAMP) W/ TF-A $(echo $ATF_VER) & OP-TEE $(echo $OPT_VER) For The RockPro64: Sign -->"
git commit -a -S -m "Successful Build of U-Boot v$(echo $UB_VER) at $(echo $BUILD_MESSAGE_TIMESTAMP) W/ TF-A $(echo $ATF_VER) & OP-TEE $(echo $OPT_VER) For The RockPro64"
git push --set-upstream origin RP64-rk3399-A
cd ..
apt remove --purge bc bison build-essential device-tree-compiler dosfstools flex gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi libncurses-dev libssl-dev parted python3-dev python3-pyelftools python3-setuptools swig unzip zip -y && apt autoremove -y
rm -f -r /tmp/u-boot* && rm -f /tmp/4.* && rm -f /tmp/lts* && rm -f /tmp/v2* && rm -f -r /tmp/arm-trusted-firmware-* && rm -f -r /tmp/optee_os-* && rm -f /tmp/spi_* && rm -f /tmp/rk* && rm -f /tmp/000* && rm -f /tmp/logo.bmp && rm -f -r U-Boot
