#!/bin/bash -e

##
##	RockPro64 SPI U-Boot Assembler
##		Requirements: Debian based OS running on an ARM64 CPU & any size microSD in the MMCBLK1 slot
##		  By: Shant Tchatalbachian
##

OPT_VER=4.3.0;
ATF_VER=2.10.4;
UB_VER=2024.07;
padsize=$((0x60000 - 1));
FORCE_SOURCE_DATE=1;
SOURCE_DATE_EPOCH="$(date -d "$(date +%D)" +%s)";
SOURCE_DATE="@$SOURCE_DATE_EPOCH";
BUILD_MESSAGE_TIMESTAMP="$(date -u +'%b %d %Y - 00:00:00 +0000')";
export FORCE_SOURCE_DATE;
export SOURCE_DATE;
export SOURCE_DATE_EPOCH;
export BUILD_MESSAGE_TIMESTAMP;

pushd /tmp/
# echo "CONFIG_LOG=y" >> rk3399_defconfig
# echo "CONFIG_LOG_MAX_LEVEL=6" >> rk3399_defconfig
# echo "CONFIG_LOG_CONSOLE=y" >> rk3399_defconfig
# echo "CONFIG_LOGLEVEL=6" >> rk3399_defconfig
# echo "CONFIG_ARMV8_SEC_FIRMWARE_SUPPORT=y" >> rk3399_defconfig
# echo "CONFIG_ARM64=y" >> rk3399_defconfig
# echo "CONFIG_FIT=y" >> rk3399_defconfig
# echo "CONFIG_FIT_VERBOSE=y" >> rk3399_defconfig
# echo "CONFIG_SPL_FIT=y" >> rk3399_defconfig
# echo "CONFIG_SPL_LOAD_FIT=y" >> rk3399_defconfig
# echo "CONFIG_SPL_FIT_SIGNATURE=y" >> rk3399_defconfig
echo "CONFIG_FIT_SIGNATURE=y" >> rk3399_defconfig
echo "CONFIG_RSA=y" >> rk3399_defconfig
# echo "CONFIG_ECDSA=y" >> rk3399_defconfig
# echo "CONFIG_SPI_FLASH_UNLOCK_ALL=n" >> rk3399_defconfig
echo "CONFIG_SPI=y" >> rk3399_defconfig
echo "CONFIG_DM_SPI=y" >> rk3399_defconfig
## echo "CONFIG_DM_SPI_FLASH=y" >> rk3399_defconfig
# echo "CONFIG_TPM2_FTPM_TEE=y" >> rk3399_defconfig
# echo "CONFIG_DM_RNG=y" >> rk3399_defconfig
echo "CONFIG_TPM=y" >> rk3399_defconfig
echo "CONFIG_TPM_V1=n" >> rk3399_defconfig
echo "CONFIG_TPM_V2=y" >> rk3399_defconfig
# echo "CONFIG_TPM_RNG=y" >> rk3399_defconfig
## echo "CONFIG_TPM_TIS_INFINEON=y" >> rk3399_defconfig
echo "CONFIG_TPM2_TIS_SPI=y" >> rk3399_defconfig
# echo "CONFIG_TPL_TPM=y" >> rk3399_defconfig
# echo "CONFIG_SPL_TPM=y" >> rk3399_defconfig
echo "CONFIG_SOFT_SPI=y" >> rk3399_defconfig
## echo "CONFIG_MEASURED_BOOT=y" >> rk3399_defconfig
## echo "CONFIG_STACKPROTECTOR=y" >> rk3399_defconfig
## echo "CONFIG_TPL_STACKPROTECTOR=y" >> rk3399_defconfig
## echo "CONFIG_SPL_STACKPROTECTOR=y" >> rk3399_defconfig
# echo "CONFIG_SPL_OPTEE_IMAGE=y" >> rk3399_defconfig
echo "CONFIG_TEE=y" >> rk3399_defconfig
echo "CONFIG_OPTEE=y" >> rk3399_defconfig
# echo "CONFIG_OPTEE_TZDRAM_BASE=0x30000000" >> rk3399_defconfig
echo "CONFIG_OPTEE_TZDRAM_SIZE=0x02000000" >> rk3399_defconfig
echo "CONFIG_OPTEE_SERVICE_DISCOVERY=y" >> rk3399_defconfig
# echo "CONFIG_OPTEE_IMAGE=y" >> rk3399_defconfig
echo "CONFIG_BOOTM_EFI=y" >> rk3399_defconfig
echo "CONFIG_BOOTM_OPTEE=y" >> rk3399_defconfig
echo "CONFIG_OPTEE_TA_SCP03=n" >> rk3399_defconfig
echo "CONFIG_OPTEE_TA_AVB=n" >> rk3399_defconfig
echo "CONFIG_CHIMP_OPTEE=n" >> rk3399_defconfig
### echo "CONFIG_SCP03=Y" >> rk3399_defconfig
# echo "CONFIG_RNG_OPTEE=y" >> rk3399_defconfig
# echo "CONFIG_LIB_HW_RAND=y" >> rk3399_defconfig
# echo "CONFIG_ARM_FFA_TRANSPORT=y" >> rk3399_defconfig
# echo "CONFIG_FFA_SHARED_MM_BUF_SIZE=4000" >> rk3399_defconfig
# echo "CONFIG_FFA_SHARED_MM_BUF_OFFSET=0" >> rk3399_defconfig
# echo "CONFIG_FFA_SHARED_MM_BUF_ADDR=0x0" >> rk3399_defconfig
# echo "CONFIG_SUPPORT_EMMC_RPMB=y" >> rk3399_defconfig
## echo "CONFIG_SUPPORT_EMMC_BOOT=y" >> rk3399_defconfig
## echo "CONFIG_EFI_VARIABLE_FILE_STORE=n" >> rk3399_defconfig
echo "CONFIG_EFI_VARIABLE_NO_STORE=y" >> rk3399_defconfig
echo "CONFIG_EFI_VARIABLES_PRESEED=y" >> rk3399_defconfig
echo 'CONFIG_EFI_VAR_SEED_FILE="efi.var"' >> rk3399_defconfig
# echo "CONFIG_EFI_RNG_PROTOCOL=y" >> rk3399_defconfig
## echo "CONFIG_EFI_TCG2_PROTOCOL=y" >> rk3399_defconfig
## echo "CONFIG_EFI_TCG2_PROTOCOL_MEASURE_DTB=y" >> rk3399_defconfig
# echo "CONFIG_EFI_MM_COMM_TEE=y" >> rk3399_defconfig
#### echo "CONFIG_EFI_VAR_BUF_SIZE=7340032" >> rk3399_defconfig
echo "CONFIG_EFI_SECURE_BOOT=y" >> rk3399_defconfig
echo "CONFIG_EFI_LOADER=y" >> rk3399_defconfig
echo "CONFIG_CMD_BOOTEFI=y" >> rk3399_defconfig
# echo "CONFIG_HEXDUMP=y" >> rk3399_defconfig
# echo "CONFIG_CMD_NVEDIT_EFI=y" >> rk3399_defconfig
## echo "CONFIG_CMD_MMC_RPMB=y" >> rk3399_defconfig
# echo "CONFIG_CMD_OPTEE_RPMB=y" >> rk3399_defconfig
### echo "CONFIG_CMD_SCP03=y" >> rk3399_defconfig
echo "CONFIG_CMD_TPM=y" >> rk3399_defconfig
echo "CONFIG_CMD_SPI=y" >> rk3399_defconfig
echo "CONFIG_CMD_TPM_TEST=y" >> rk3399_defconfig
echo "CONFIG_CMD_HASH=y" >> rk3399_defconfig
## echo "CONFIG_CMD_BOOTMENU=y" >> rk3399_defconfig
## echo "CONFIG_CMD_BOOTEFI_BOOTMGR=y" >> rk3399_defconfig
## echo "CONFIG_CMD_EFIDEBUG=y" >> rk3399_defconfig
echo 'CONFIG_SYS_PROMPT="0MNITECK # "' >> rk3399_defconfig
echo 'CONFIG_LOCALVERSION="0MNITECK"' >> rk3399_defconfig
popd

## cp includes/0001-rockchip-rk3399-fix-SPI-NOR-flash-not-found-in-U-Boo.patch /tmp/0001-rockchip-rk3399.patch
## cp includes/0001-pkcs11-leak-the-engine-to-avoid-segfault-when-using-.patch /tmp/0001-pkcs11-leak.patch
# cp includes/rk3399-rockpro64-u-boot.dtsi /tmp/rk3399-rockpro64-u-boot.dtsi
## cp includes/rk3399-u-boot.dtsi /tmp/rk3399-u-boot.dtsi
# cp includes/platform_common.c /tmp/platform_common.c
# cp includes/platform_def.h /tmp/platform_def.h
# cp includes/plat_private.h /tmp/plat_private.h
# cp includes/platform.mk /tmp/platform.mk
# cp includes/rk3399_def.h /tmp/rk3399_def.h
# cp includes/bl31_param.h /tmp/bl31_param.h
## cp includes/logo.bmp /tmp/logo.bmp
## cp includes/efi.var /tmp/efi.var
## cp /tmp/rk3399_defconfig

if [ -f Builds/sbsign ]; then
  cp Builds/sbsign /tmp/sbsign
else
  snap install lxd && lxd init --auto && lxc launch ubuntu:24.04 sbtools && sleep 30 && ufw reload && sleep 10
  lxc exec sbtools apt update && lxc exec sbtools -- apt upgrade -y
  lxc exec sbtools -- apt install automake binutils-dev build-essential gnu-efi help2man libssl-dev make openssl pkg-config uuid uuid-dev -y
  lxc exec sbtools -- git clone https://git.kernel.org/pub/scm/linux/kernel/git/jejb/sbsigntools.git
  lxc file push 0001-pkcs11-leak-the-engine-to-avoid-segfault-when-using-.patch sbtools/root/sbsigntools/0001-pkcs11-leak.patch
  echo "Entering sbsign ------"
  lxc exec sbtools --cwd /root/sbsigntools -- git apply 0001-pkcs11-leak.patch && echo "Patched sbsign SEG_FAULT bug"
  lxc exec sbtools --cwd /root/sbsigntools -- ./autogen.sh
  lxc exec sbtools --cwd /root/sbsigntools -- ./configure
  lxc exec sbtools --cwd /root/sbsigntools -- make
  lxc exec sbtools --cwd /root/sbsigntools -- make install
  lxc file pull sbtools/root/sbsigntools/src/sbsign /tmp/
  snap remove lxd --purge
fi

cp /tmp/sbsign Builds/sbsign
git status && git add -A && git status
read -p "Successful Build of sbsign: Sign -->"
git commit -a -S -m "Successful Build of sbsign"
git push --set-upstream origin RP64-rk3399-Dev

if [ -f Builds/tee.bin ]; then
  cp Builds/tee.bin /tmp/tee.bin
else
  snap install lxd && lxd init --auto && lxc launch ubuntu:24.04 tee && sleep 30 && ufw reload && sleep 10
  lxc exec tee apt update && lxc exec tee -- apt upgrade -y
  lxc exec tee -- apt install -y adb acpica-tools autoconf automake bc bison build-essential ccache cpio cscope curl device-tree-compiler e2tools expect fastboot flex ftp-upload gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi \
  gdisk git libattr1-dev libcap-ng-dev libfdt-dev libftdi-dev libglib2.0-dev libgmp3-dev libhidapi-dev libmpc-dev libncurses5-dev libpixman-1-dev libslirp-dev libssl-dev libtool libusb-1.0-0-dev make mtools netcat-openbsd ninja-build python3-cryptography \
  python3-pip python3-pyelftools python3-serial python-is-python3 rsync swig unzip uuid-dev wget xalan xdg-utils xterm xz-utils zlib1g-dev
  lxc exec tee -- wget https://github.com/OP-TEE/optee_os/archive/refs/tags/$(echo $OPT_VER).zip
  lxc exec tee -- bash -c "echo '04a2e85947283e49a79cb8d60fde383df28303a9be15080a7f5354268b01f16405178c0c570e253256c3be8e3084d812c8b46b6dc2cb5c8eb3bde8d2ba4c380e  '$(echo $OPT_VER)'.zip' > $(echo $OPT_VER).zip.sum"
  if [[ $(lxc exec tee -- bash -c "sha512sum -c $(echo $OPT_VER).zip.sum") == $(echo $OPT_VER)'.zip: OK' ]]; then echo 'OP-TEE Checksum Matched!'; else echo 'OP-TEE Checksum Mismatched!' & exit 1; fi;
  lxc exec tee -- unzip $(echo $OPT_VER).zip
  echo "Entering OP-TEE ------"
  lxc exec tee --cwd /root/optee_os-$(echo $OPT_VER) -- bash -i -c "make -j\$(nproc) PLATFORM=rockchip-rk3399 CFG_ARM64_core=y CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE32=arm-linux-gnueabihf- CROSS_COMPILE_core=aarch64-linux-gnu- CROSS_COMPILE_ta_arm32=arm-linux-gnueabihf- CROSS_COMPILE_ta_arm64=aarch64-linux-gnu-"
  lxc file pull tee/root/optee_os-$(echo $OPT_VER)/out/arm-plat-rockchip/core/tee.bin /tmp/
  snap remove lxd --purge
fi

export TEE=/tmp/tee.bin
cp /tmp/tee.bin Builds/tee.bin
git status && git add -A && git status
read -p "Successful Build of OP-TEE: Sign -->"
git commit -a -S -m "Successful Build of OP-TEE"
git push --set-upstream origin RP64-rk3399-Dev

if [ -f Builds/bl31.elf ]; then
  cp Builds/bl31.elf /tmp/bl31.elf
else
  snap install lxd && lxd init --auto && lxc launch ubuntu:24.04 tf-a
  sleep 30 && ufw reload && sleep 10
  # cp /tmp/platform_common.c plat/rockchip/common/aarch64/platform_common.c
  # cp /tmp/platform_def.h plat/rockchip/rk3399/include/platform_def.h
  # cp /tmp/plat_private.h plat/rockchip/common/include/plat_private.h
  # cp /tmp/platform.mk plat/rockchip/rk3399/platform.mk
  # cp /tmp/rk3399_def.h plat/rockchip/rk3399/rk3399_def.h
  # cp /tmp/bl31_param.h plat/rockchip/rk3399/include/shared/bl31_param.h
  lxc exec tf-a apt update && lxc exec tf-a -- apt upgrade -y
  lxc exec tf-a -- apt install -y bc bison build-essential device-tree-compiler dosfstools flex gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi libengine-pkcs11-openssl libncurses-dev libssl-dev parted python3-dev python3-pyelftools python3-setuptools swig unzip wget zip
  lxc exec tf-a -- wget https://github.com/ARM-software/arm-trusted-firmware/archive/refs/tags/lts-v$(echo $ATF_VER).zip
  lxc exec tf-a -- bash -c "echo '5252dc59f1133d9c3fae5560954d9810e97a7e3b018522fddea584343d742a110c65678115cb0f554c201b5f7326353eec9a54031485156b6ca0788f53d33882  lts-v'$(echo $ATF_VER)'.zip' > $(echo $ATF_VER).zip.sum"
  if [[ $(lxc exec tf-a -- bash -c "sha512sum -c $(echo $ATF_VER).zip.sum") == $(echo $ATF_VER)'.zip: OK' ]]; then echo 'TF-A Checksum Matched! Checksum Matched!'; else echo 'TF-A Checksum Mismatched!' & exit 1; fi;
  lxc exec tf-a -- unzip lts-v$(echo $ATF_VER).zip
  echo "Entering TF-A ------"
  lxc exec tf-a --cwd /root/arm-trusted-firmware-lts-v$(echo $ATF_VER) -- make realclean
  lxc exec tf-a --cwd /root/arm-trusted-firmware-lts-v$(echo $ATF_VER) -- make -j\$(nproc) BUILD_MESSAGE_TIMESTAMP="$(echo '"'$BUILD_MESSAGE_TIMESTAMP'"')" PLAT=rk3399 bl31
  lxc file pull tf-a/root/arm-trusted-firmware-lts-v$(echo $ATF_VER)/build/rk3399/release/bl31/bl31.bin /tmp/
  snap remove lxd --purge
fi

export BL31=/tmp/bl31.elf
cp /tmp/bl31.elf Builds/bl31.elf
git status && git add -A && git status
read -p "Successful Build of TF-A: Sign -->"
git commit -a -S -m "Successful Build of TF-A"
git push --set-upstream origin RP64-rk3399-Dev

snap install ub && lxd init --auto && lxc launch ubuntu:24.04 ub && sleep 30 && ufw reload && sleep 10
# cp /tmp/rk3399-rockpro64-u-boot.dtsi arch/arm/dts/rk3399-rockpro64-u-boot.dtsi && echo "Patched Device Tree for TPM"
lxc exec ub apt update && lxc exec ub -- apt upgrade -y
lxc exec ub -- apt install -y bc bison build-essential device-tree-compiler dosfstools flex gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi libengine-pkcs11-openssl libncurses-dev libssl-dev parted python3-dev python3-pyelftools python3-setuptools swig unzip wget zip
lxc exec ub -- wget https://github.com/u-boot/u-boot/archive/refs/tags/v$(echo $UB_VER).zip
lxc exec ub -- bash -c "echo '0a3e614ba0fd14224f52a8ad3e68e22df08f6e02c43e9183a459d80b4f37b4f384a4bfef7627a3863388fcffb1472c38d178810bed401f63eb8b5d0a21456603  v'$(echo $UB_VER)'.zip' > $(echo $UB_VER).zip.sum"
if [[ $(lxc exec ub -- bash -c "sha512sum -c $(echo $UB_VER).zip.sum") == $(echo $UB_VER)'.zip: OK' ]]; then echo 'U-Boot Checksum Matched! Checksum Matched!'; else echo 'U-Boot Checksum Mismatched!' & exit 1; fi;
lxc exec ub -- unzip v$(echo $UB_VER).zip
echo "Entering U-Boot ------"
lxc exec ub --cwd /root/u-boot-$(echo $UB_VER) -- make clean
lxc file push includes/0001-rockchip-rk3399-fix-SPI-NOR-flash-not-found-in-U-Boo.patch ub/root/u-boot-$(echo $UB_VER)/0001-rockchip-rk3399.patch
lxc exec ub --cwd /root/u-boot-$(echo $UB_VER) -- git apply 0001-rockchip-rk3399.patch && echo "Patched SPI bug"
lxc file push includes/rk3399-u-boot.dtsi ub/root/u-boot-$(echo $UB_VER)/arch/arm/dts/rk3399-u-boot.dtsi && echo "Patched Device Tree for TPM"
lxc file push includes/efi.var ub/root/u-boot-$(echo $UB_VER)/efi.var && echo "Deployed efi.var"
lxc exec ub --cwd /root/u-boot-$(echo $UB_VER) -- rm tools/logos/denx.bmp && rm drivers/video/u_boot_logo.bmp
lxc file push includes/logo.bmp ub/root/u-boot-$(echo $UB_VER)/tools/logos/denx.bmp
lxc file push includes/logo.bmp ub/root/u-boot-$(echo $UB_VER)/drivers/video/u_boot_logo.bmp
lxc exec ub --cwd /root/u-boot-$(echo $UB_VER) -- sed -i 's/CONFIG_BAUDRATE=1500000/CONFIG_BAUDRATE=115200/' configs/rockpro64-rk3399_defconfig
lxc file push /tmp/rk3399_defconfig ub/root/u-boot-$(echo $UB_VER)/rk3399_defconfig
lxc exec ub --cwd /root/u-boot-$(echo $UB_VER) -- cat rk3399_defconfig >> configs/rockpro64-rk3399_defconfig
lxc exec ub --cwd /root/u-boot-$(echo $UB_VER) -- make rockpro64-rk3399_defconfig
lxc exec ub --cwd /root/u-boot-$(echo $UB_VER) -- cat configs/rockpro64-rk3399_defconfig
read -p "menuconfig -->"
lxc exec ub --cwd /root/u-boot-$(echo $UB_VER) -- make menuconfig
read -p "Build U-Boot -->"
lxc exec ub --cwd /root/u-boot-$(echo $UB_VER) -- FORCE_SOURCE_DATE=1 SOURCE_DATE=$SOURCE_DATE SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH make -j$(nproc) all
lxc exec ub --cwd /root/u-boot-$(echo $UB_VER) -- make -j\$(nproc) BUILD_MESSAGE_TIMESTAMP="$(echo '"'$BUILD_MESSAGE_TIMESTAMP'"')" PLAT=rk3399 bl31
lxc file pull ub/root/u-boot-$(echo $UB_VER) /tmp/u-boot
pushd /tmp/u-boot/

dd if=/dev/zero of=/dev/mmcblk1 bs=1M count=100 status=progress
dd if=u-boot-rockchip.bin of=/dev/mmcblk1 seek=64 conv=notrunc status=progress

# WIP
read -p "Insert another SD Card + yubikey, Then Press Enter to Continue"
# openssl req -new -x509 -engine pkcs11 -keyform ENGINE -key 1 -out dev.crt
tools/mkimage -n rk3399 -T rksd -d tpl/u-boot-tpl.bin:spl/u-boot-spl.bin sd_idbloader.img
tools/mkimage -n rk3399 -T rkspi -d tpl/u-boot-tpl.bin:spl/u-boot-spl.bin spi_idbloader.img
export PKCS11_MODULE_PATH=/usr/lib/aarch64-linux-gnu/libykcs11.so.2.2.0
tools/mkimage -F -N pkcs11 -k 1 -K simple-bin.fit.fit -r rk3399.fit
tools/mkimage -n rk3399 -T rksd -f auto -d rk3399.fit -A arm64 -O u-boot rk3399.sd.itb
tools/mkimage -n rk3399 -T rkspi -f auto -d rk3399.fit -A arm64 -O u-boot rk3399.spi.itb
dd if=/dev/zero of=sd_idbloader.img conv=notrunc bs=1 count=1 seek=${padsize}
dd if=/dev/zero of=spi_idbloader.img conv=notrunc bs=1 count=1 seek=${padsize}
cat spi_idbloader.img rk3399.sd.itb > rk3399-sd.bin
cat sd_idbloader.img rk3399.spi.itb > rk3399-spi.bin
sha512sum rk3399-sd.bin
sha512sum rk3399-spi.bin
dd if=/dev/zero of=/dev/mmcblk1 bs=1M count=100 status=progress
parted /dev/mmcblk1 mktable gpt mkpart P1 fat32 10MB 25MB -s && sleep 3
mkfs.fat /dev/mmcblk1p1
mount /dev/mmcblk1p1 /mnt
sha512sum rk3399-sd.bin
sha512sum rk3399-sd.bin > /mnt/rk3399-sd.bin.sum
sha512sum rk3399-sd.bin > /tmp/rk3399-sd.bin.sum
cp rk3399-sd.bin /mnt/rk3399-sd.bin
cp rk3399-sd.bin /tmp/rk3399-sd.bin
sha512sum rk3399-spi.bin
sha512sum rk3399-spi.bin > /mnt/rk3399-spi.bin.sum
sha512sum rk3399-spi.bin > /tmp/rk3399-spi.bin.sum
cp rk3399-spi.bin /mnt/rk3399-spi.bin.bin
cp rk3399-spi.bin /tmp/rk3399-spi.bin.bin
sync
umount /mnt
dd if=u-boot-rockchip.bin of=/dev/mmcblk1 seek=64 conv=notrunc status=progress
sync
popd

cp /tmp/u-boot/rk3399-sd.bin Builds/rk3399-sd.bin
cp /tmp/u-boot/rk3399-sd.bin.sum Builds/rk3399-sd.bin.sum
cp /tmp/u-boot/rk3399-spi.bin Builds/rk3399-spi.bin
cp /tmp/u-boot/rk3399-spi.bin.sum Builds/rk3399-spi.bin.sum

git status && git add -A && git status
read -p "Successful Build of U-Boot v$(echo $UB_VER) at $(echo $BUILD_MESSAGE_TIMESTAMP) W/ TF-A $(echo $ATF_VER) & OP-TEE $(echo $OPT_VER) For The RockPro64: Sign -->"
git commit -a -S -m "Successful Build of U-Boot v$(echo $UB_VER) at $(echo $BUILD_MESSAGE_TIMESTAMP) W/ TF-A $(echo $ATF_VER) & OP-TEE $(echo $OPT_VER) For The RockPro64"
git push --set-upstream origin RP64-rk3399-Dev

rm -f -r /tmp/u-boot* && rm -f /tmp/rk3399* && rm -f /tmp/bl31.elf && rm -f /tmp/tee.bin && rm -f /tmp/sbsign && rm -f -r ../U-Boot &
snap remove lxd --purge
exit
