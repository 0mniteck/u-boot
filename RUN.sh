#!/bin/bash -e

##
##	RockPro64 SPI U-Boot Assembler
##		Requirements: Debian based OS running on an ARM64 CPU & any size microSD in the MMCBLK1 slot
##		  By: Shant Tchatalbachian
##

OPT_VER=4.3.0;
ATF_VER=2.10.4;
UB_VER=2024.07;
BUILDTIME=$(date -d $(date +%D) +%s);
BUILDTIME_A=$(date -d $(date +%D));

git remote remove origin && git remote add origin git@UBoot:0mniteck/U-Boot.git
rm -f spi_combined.zip
pushd /tmp/
apt update && apt install acpica-tools adb autoconf automake bc binfmt-support bison build-essential ccache coccinelle cpio cscope curl device-tree-compiler dfu-util dosfstools e2tools efitools expect fakeroot fastboot fdisk flex gcc gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi gdisk git git-lfs libattr1-dev libcap-ng-dev libfdt-dev libftdi-dev libgmp3-dev libgnutls28-dev libhidapi-dev liblz4-tool libmbedtls-dev libmpc-dev libncurses-dev libpixman-1-dev libpython3-dev libslirp-dev libssl-dev libtool libusb-1.0-0-dev lz4 lzma lzma-alone make mtools netcat-openbsd ninja-build openssl parted pkg-config python3 python3-asteval python3-coverage python3-dev python3-filelock python3-pip python3-pkg-resources python3-pycryptodome python3-pytest python3-pyelftools python3-pytest-xdist python3-setuptools python3-subunit python3-testtools python3-virtualenv python-is-python3 rsync swig u-boot-tools udev unzip uuid-dev uuid-runtime wget xz-utils zip zlib1g-dev -y
wget https://github.com/OP-TEE/optee_os/archive/refs/tags/$OPT_VER.zip
echo '04a2e85947283e49a79cb8d60fde383df28303a9be15080a7f5354268b01f16405178c0c570e253256c3be8e3084d812c8b46b6dc2cb5c8eb3bde8d2ba4c380e  $OPT_VER.zip' > $OPT_VER.zip.sum
if [[ $(sha512sum -c $OPT_VER.zip.sum) == '$OPT_VER.zip: OK' ]]; then echo 'OP-TEE Checksum Matched!'; else echo 'OP-TEE Checksum Mismatched!' & exit 1; fi;
wget https://github.com/ARM-software/arm-trusted-firmware/archive/refs/tags/lts-v$ATF_VER.zip
echo '5252dc59f1133d9c3fae5560954d9810e97a7e3b018522fddea584343d742a110c65678115cb0f554c201b5f7326353eec9a54031485156b6ca0788f53d33882  lts-v$ATF_VER.zip' > v$ATF_VER.zip.sum
if [[ $(sha512sum -c v$ATF_VER.zip.sum) == 'lts-v$ATF_VER.zip: OK' ]]; then echo 'ATF Checksum Matched!'; else echo 'ATF Checksum Mismatched!' & exit 1; fi;
wget https://github.com/u-boot/u-boot/archive/refs/tags/v$UB_VER.zip
echo '0a3e614ba0fd14224f52a8ad3e68e22df08f6e02c43e9183a459d80b4f37b4f384a4bfef7627a3863388fcffb1472c38d178810bed401f63eb8b5d0a21456603  v$UB_VER.zip' > v$UB_VER.zip.sum
if [[ $(sha512sum -c v$UB_VER.zip.sum) == 'v$UB_VER.zip: OK' ]]; then echo 'U-Boot Checksum Matched!'; else echo 'U-Boot Checksum Mismatched!' & exit 1; fi;
unzip $OPT_VER.zip
unzip v$UB_VER.zip
unzip lts-v$ATF_VER.zip
cd optee_os-$OPT_VER
echo "Entering OP-TEE ------"
make -j$(nproc) PLATFORM=rockchip-rk3399 CFG_ARM64_core=y
export TEE=/tmp/optee_os-$OPT_VER/out/arm-plat-rockchip/core/tee.bin
cd ..
cd arm-trusted-firmware-lts-v$ATF_VER
echo "Entering TF-A ------"
make realclean
make PLAT=rk3399 BUILD_MESSAGE_TIMESTAMP='"'$BUILDTIME_A'"' bl31
export BL31=/tmp/arm-trusted-firmware-lts-v$ATF_VER/build/rk3399/release/bl31/bl31.elf
cd ..
cd u-boot-$UB_VER
echo "Entering U-Boot ------"
sed -i 's/CONFIG_BAUDRATE=1500000/CONFIG_BAUDRATE=115200/' configs/rockpro64-rk3399_defconfig
make rockpro64-rk3399_defconfig
make SOURCE_DATE_EPOCH=$BUILDTIME -j$(nproc) all
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
git commit -a -S -m "Successful Build of U-Boot v$UB_VER at $BUILDTIME W/ TF-A $ATF_VER & OP-TEE $OPT_VER For The RockPro64"
git push --set-upstream origin RP64-rk3399-A
cd ..
apt remove --purge acpica-tools adb autoconf automake bc binfmt-support bison build-essential ccache coccinelle cscope device-tree-compiler dfu-util dosfstools e2tools efitools expect fakeroot fastboot flex gcc gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi libattr1-dev libcap-ng-dev libfdt-dev libftdi-dev libgmp3-dev libgnutls28-dev libhidapi-dev liblz4-tool libmbedtls-dev libmpc-dev libncurses-dev libpixman-1-dev libpython3-dev libslirp-dev libssl-dev libtool libusb-1.0-0-dev lz4 lzma lzma-alone make mtools netcat-openbsd ninja-build parted pkg-config python3-asteval python3-coverage python3-dev python3-filelock python3-pip python3-pycryptodome python3-pytest python3-pyelftools python3-pytest-xdist python3-setuptools python3-subunit python3-testtools python3-virtualenv python-is-python3 rsync swig u-boot-tools uuid-dev uuid-runtime zlib1g-dev -y && apt autoremove -y
rm -f -r /tmp/u-boot* && rm -f /tmp/4.* && rm -f /tmp/lts* && rm -f /tmp/v2* && rm -f -r /tmp/arm-trusted-firmware-* && rm -f -r /tmp/optee_os-* && rm -f /tmp/spi_* && rm -f /tmp/rk* && rm -f -r U-Boot
