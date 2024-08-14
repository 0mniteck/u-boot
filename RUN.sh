#!/bin/bash -e

##
##	RockPro64 SPI U-Boot Assembler
##		Requirements: Debian based OS running on an ARM64 CPU & any size microSD in the MMCBLK1 slot
##		  By: Shant Tchatalbachian
##

git remote remove origin && git remote add origin git@UBoot:0mniteck/U-Boot.git
rm -f spi_combined.zip
pushd /tmp/
apt update && apt install build-essential bc zip unzip bison flex libssl-dev gcc-arm-none-eabi gcc-arm-linux-gnueabihf device-tree-compiler swig python3-pyelftools python3-setuptools python3-dev parted dosfstools libncurses-dev -y
wget https://github.com/OP-TEE/optee_os/archive/refs/tags/4.3.0.zip
echo '04a2e85947283e49a79cb8d60fde383df28303a9be15080a7f5354268b01f16405178c0c570e253256c3be8e3084d812c8b46b6dc2cb5c8eb3bde8d2ba4c380e  4.3.0.zip' > 4.zip.sum
if [[ $(sha512sum -c 4.zip.sum) == '4.3.0.zip: OK' ]]; then echo 'OP-TEE Checksum Matched!'; else echo 'OP-TEE Checksum Mismatched!' & exit 1; fi;
wget wget https://git.trustedfirmware.org/plugins/gitiles/TF-A/trusted-firmware-a.git/+archive/refs/tags/lts-v2.10.5.tar.gz
echo '178f4793dff3a93a43b5e7faa607794bbf6ea20c23d1c13fa70e31c32081e33c77068644ac353de4988d4a1d98ab31a65d78a92926b70da930ff5ad0240fa5cf  lts-v2.10.5.tar.gz' > v2.zip.sum
if [[ $(sha512sum -c v2.zip.sum) == 'lts-v2.10.5.zip: OK' ]]; then echo 'ATF Checksum Matched!'; else echo 'ATF Checksum Mismatched!' & exit 1; fi;
wget https://github.com/u-boot/u-boot/archive/refs/tags/v2024.07.zip
echo '0a3e614ba0fd14224f52a8ad3e68e22df08f6e02c43e9183a459d80b4f37b4f384a4bfef7627a3863388fcffb1472c38d178810bed401f63eb8b5d0a21456603  v2024.07.zip' > v2024.zip.sum
if [[ $(sha512sum -c v2024.zip.sum) == 'v2024.07.zip: OK' ]]; then echo 'U-Boot Checksum Matched!'; else echo 'U-Boot Checksum Mismatched!' & exit 1; fi;
unzip 4.*.*.zip
unzip v202*.zip
gunzip lts*.gz
mkdir arm-trusted-firmware && cd arm-trusted-firmware
tar -x -f ../lts*.tar
cd ..
cd optee_os-*
echo "Entering OP-TEE ------"
make -j$(nproc) PLATFORM=rockchip-rk3399 CFG_ARM64_core=y
export TEE=/tmp/optee_os-4.3.0/out/arm-plat-rockchip/core/tee.bin
cd ..
cd arm-trusted-firmware*
echo "Entering TF-A ------"
make realclean
make PLAT=rk3399 BUILD_MESSAGE_TIMESTAMP=$(date -d $(date +%D) +%s) bl31
export BL31=/tmp/arm-trusted-firmware/build/rk3399/release/bl31/bl31.elf
cd ..
cd u-boot-202*
echo "Entering U-Boot ------"
sed -i 's/CONFIG_BAUDRATE=1500000/CONFIG_BAUDRATE=115200/' configs/rockpro64-rk3399_defconfig
make rockpro64-rk3399_defconfig
make SOURCE_DATE_EPOCH=$(date -d $(date +%D) +%s) -j$(nproc) all
image_name="spi_idbloader.img"
combined_name="spi_combined.img"
tools/mkimage -n rk3399 -T rkspi -d tpl/u-boot-tpl.bin:spl/u-boot-spl.bin "${image_name}"
padsize=$((0x60000 - 1))
image_size=$(wc -c < "${image_name}")
dd if=/dev/zero of="${image_name}" conv=notrunc bs=1 count=1 seek=${padsize}
cat ${image_name} u-boot.itb > "${combined_name}"
sha512sum spi_combined.img
sha512sum u-boot-rockchip.bin
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
cp u-boot-rockchip.bin /tmp/u-boot-rockchip.bin
sync
umount /mnt
dd if=u-boot-rockchip.bin of=/dev/mmcblk1 seek=64 conv=notrunc status=progress
cd ..
zip -0 spi_combined.zip spi_combined.img spi_combined.img.sum u-boot-rockchip.bin u-boot-rockchip.bin.sum
sync
popd
cp /tmp/spi_combined.zip spi_combined.zip
git status && git add -A && git status
read -p "Continue -->"
git commit -a -S -m "Successful Build of U-Boot $(date -d $(date +%D) +%s) W/ TF-A & OP-TEE For The RockPro64"
git push --set-upstream origin RP64-rk3399-A
cd ..
apt remove --purge build-essential bc zip unzip bison flex libssl-dev gcc-arm-none-eabi gcc-arm-linux-gnueabihf device-tree-compiler swig python3-pyelftools python3-setuptools python3-dev parted dosfstools libncurses-dev -y && apt autoremove -y
rm -f -r /tmp/u-boot* && rm -f /tmp/4.* && rm -f /tmp/lts* && rm -f /tmp/v2* && rm -f -r /tmp/arm-trusted-firmware-* && rm -f -r /tmp/optee_os-* && rm -f /tmp/spi_* && rm -f /tmp/rk* && rm -f -r ../U-Boot
