#!/bin/bash -e

##
##	RockPro64 SPI U-Boot Assembler
##		Requirements: Debian based OS running on an ARM64 CPU & any size microSD in the MMCBLK1 slot
##		  By: Shant Tchatalbachian
##

EDK_VER=edk2-stable202408;
EDKP_VER=2acddc92a4951ee885351c035ac19794644a1fd8;
OPT_VER=4.3.0;
ATF_VER=2.10.4;
UB_VER=2024.07;
FORCE_SOURCE_DATE=1;
SOURCE_DATE_EPOCH="$(date -d "$(date +%D)" +%s)";
SOURCE_DATE="@$SOURCE_DATE_EPOCH";
BUILD_MESSAGE_TIMESTAMP="$(date -u +'%b %d %Y - 00:00:00 +0000')";
export FORCE_SOURCE_DATE;
export SOURCE_DATE;
export SOURCE_DATE_EPOCH;
export BUILD_MESSAGE_TIMESTAMP;

git remote remove origin && git remote add origin git@UBoot:0mniteck/U-Boot.git
cp includes/0001-rockchip-rk3399-fix-SPI-NOR-flash-not-found-in-U-Boo.patch /tmp/0001-rockchip-rk3399.patch
# cp includes/platform_common.c /tmp/platform_common.c
cp includes/logo.bmp /tmp/logo.bmp
if [ -f Builds/BL32_AP_MM.fd ]; then
  cp Builds/BL32_AP_MM.fd /tmp/BL32_AP_MM.fd
  pushd /tmp/
else
  pushd /tmp/
  apt remove --purge bc bison build-essential device-tree-compiler dosfstools flex gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi libncurses-dev libssl-dev parted python3-dev python3-pyelftools python3-setuptools swig unzip wget zip -y && apt autoremove -y
  snap install lxd && lxd init --auto && lxc launch ubuntu:18.04 edk2
  sleep 30
  ufw reload
  sleep 10
  lxc exec edk2 apt update && lxc exec edk2 -- apt upgrade -y
  lxc exec edk2 -- apt install build-essential gcc-5 acpica-tools nasm unzip uuid-dev wget python3-distutils -y
  lxc exec edk2 -- git clone https://github.com/tianocore/edk2.git -b $(echo $EDK_VER) edk2-$(echo $EDK_VER)
  lxc exec edk2 -- wget https://github.com/tianocore/edk2-platforms/archive/$(echo $EDKP_VER).zip
  lxc exec edk2 -- bash -c "echo '00f69c101927bac3fe98efd0714f2418dd9be52ae6b9e30e7395b56f4f34f8691bc4da140a2b17bbfac0cb8ef772e15db64db76033b03b2c036992f5a95b8809  '$(echo $EDKP_VER)'.zip' > $(echo $EDKP_VER).zip.sum"
  if [[ $(lxc exec edk2 -- bash -c "sha512sum -c $(echo $EDKP_VER).zip.sum") == $(echo $EDKP_VER)'.zip: OK' ]]; then echo 'EDK2 Platform Checksum Matched!'; else echo 'EDK2 Platform Checksum Mismatched!' & exit 1; fi;
  lxc exec edk2 -- unzip $(echo $EDKP_VER).zip
  echo "Entering EDK2 ------"
  lxc exec edk2 --cwd /root/edk2-$(echo $EDK_VER) -- git submodule init
  lxc exec edk2 --cwd /root/edk2-$(echo $EDK_VER) -- git submodule update --init --recursive
  lxc exec edk2 --cwd /root/edk2-$(echo $EDK_VER) -- bash -i -c "export WORKSPACE=/root && \
  export PACKAGES_PATH=/root/edk2-$(echo $EDK_VER):/root/edk2-platforms-$(echo $EDKP_VER) && \
  export ACTIVE_PLATFORM='Platform/StandaloneMm/PlatformStandaloneMmPkg/PlatformStandaloneMmRpmb.dsc' && \
  export GCC5_AARCH64_PREFIX=aarch64-linux-gnu- && \
  source edksetup.sh && \
  make -C BaseTools && \
  build -p \$ACTIVE_PLATFORM -b RELEASE -a AARCH64 -t GCC5 -n `nproc`"
  lxc file pull edk2/root/Build/MmStandaloneRpmb/RELEASE_GCC5/FV/BL32_AP_MM.fd /tmp/
  snap remove lxd --purge
fi
apt update && apt install bc bison build-essential device-tree-compiler dosfstools flex gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi libncurses-dev libssl-dev parted python3-dev python3-pyelftools python3-setuptools swig unzip wget zip -y
wget https://github.com/OP-TEE/optee_os/archive/refs/tags/$(echo $OPT_VER).zip
echo '04a2e85947283e49a79cb8d60fde383df28303a9be15080a7f5354268b01f16405178c0c570e253256c3be8e3084d812c8b46b6dc2cb5c8eb3bde8d2ba4c380e  '$(echo $OPT_VER)'.zip' > $(echo $OPT_VER).zip.sum
if [[ $(sha512sum -c $(echo $OPT_VER).zip.sum) == $(echo $OPT_VER)'.zip: OK' ]]; then echo 'OP-TEE Checksum Matched!'; else echo 'OP-TEE Checksum Mismatched!' & exit 1; fi;
wget https://github.com/ARM-software/arm-trusted-firmware/archive/refs/tags/lts-v$(echo $ATF_VER).zip
echo '5252dc59f1133d9c3fae5560954d9810e97a7e3b018522fddea584343d742a110c65678115cb0f554c201b5f7326353eec9a54031485156b6ca0788f53d33882  lts-v'$(echo $ATF_VER)'.zip' > v$(echo $ATF_VER).zip.sum
if [[ $(sha512sum -c v$(echo $ATF_VER).zip.sum) == 'lts-v'$(echo $ATF_VER)'.zip: OK' ]]; then echo 'ATF Checksum Matched!'; else echo 'ATF Checksum Mismatched!' & exit 1; fi;
wget https://github.com/u-boot/u-boot/archive/refs/tags/v$(echo $UB_VER).zip
echo '0a3e614ba0fd14224f52a8ad3e68e22df08f6e02c43e9183a459d80b4f37b4f384a4bfef7627a3863388fcffb1472c38d178810bed401f63eb8b5d0a21456603  v'$(echo $UB_VER)'.zip' > v$(echo $UB_VER).zip.sum
if [[ $(sha512sum -c v$(echo $UB_VER).zip.sum) == 'v'$(echo $UB_VER)'.zip: OK' ]]; then echo 'U-Boot Checksum Matched!'; else echo 'U-Boot Checksum Mismatched!' & exit 1; fi;
unzip $(echo $OPT_VER).zip
unzip v$(echo $UB_VER).zip
unzip lts-v$(echo $ATF_VER).zip
cd optee_os-$(echo $OPT_VER)
echo "Entering OP-TEE ------"
ln -s /tmp/BL32_AP_MM.fd
make -j$(nproc) PLATFORM=rockchip-rk3399 CFG_ARM64_core=y CFG_STMM_PATH=BL32_AP_MM.fd CFG_RPMB_FS=y CFG_RPMB_FS_DEV_ID=0 CFG_CORE_HEAP_SIZE=524288 CFG_RPMB_WRITE_KEY=y CFG_CORE_DYN_SHM=y CFG_RPMB_TESTKEY=y CFG_REE_FS=n CFG_CORE_ARM64_PA_BITS=48 CFG_TEE_CORE_LOG_LEVEL=4 CFG_TEE_TA_LOG_LEVEL=4 CFG_SCTLR_ALIGNMENT_CHECK=n CFG_EARLY_CONSOLE=y CFG_EARLY_CONSOLE_BASE=UART2_BASE CFG_EARLY_CONSOLE_SIZE=UART2_SIZE CFG_EARLY_CONSOLE_BAUDRATE=115200 CFG_EARLY_CONSOLE_CLK_IN_HZ=24000000
export TEE=/tmp/optee_os-$(echo $OPT_VER)/out/arm-plat-rockchip/core/tee.bin
cd ..
cd arm-trusted-firmware-lts-v$(echo $ATF_VER)
echo "Entering TF-A ------"
make realclean
ln -s /tmp/BL32_AP_MM.fd
ln -s /tmp/optee_os-$(echo $OPT_VER)/out/arm-plat-rockchip/core/tee.bin
# cp /tmp/platform_common.c plat/rockchip/common/aarch64/platform_common.c
BL33=tee.bin BL32=BL32_AP_MM.fd make BUILD_MESSAGE_TIMESTAMP="$(echo '"'$BUILD_MESSAGE_TIMESTAMP'"')" SPM_MM=1 EL3_EXCEPTION_HANDLING=1 ENABLE_SVE_FOR_NS=0 ARM_BL31_IN_DRAM=1 PLAT=rk3399 bl31
# make BUILD_MESSAGE_TIMESTAMP="$(echo '"'$BUILD_MESSAGE_TIMESTAMP'"')" PLAT=rk3399 bl31
export BL31=/tmp/arm-trusted-firmware-lts-v$(echo $ATF_VER)/build/rk3399/release/bl31/bl31.elf
cd ..
cd u-boot-$(echo $UB_VER)
echo "Entering U-Boot ------"
make clean
git apply ../0001-rockchip-rk3399.patch && echo "Patched SPI bug"
rm tools/logos/denx.bmp && rm drivers/video/u_boot_logo.bmp
cp /tmp/logo.bmp tools/logos/denx.bmp && cp /tmp/logo.bmp drivers/video/u_boot_logo.bmp
sed -i 's/CONFIG_BAUDRATE=1500000/CONFIG_BAUDRATE=115200/' configs/rockpro64-rk3399_defconfig
# echo "CONFIG_LOG=y" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_LOG_MAX_LEVEL=7" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_LOG_CONSOLE=y" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_LOGLEVEL=7" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_ARMV8_SEC_FIRMWARE_SUPPORT=y" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_FIT_SIGNATURE=y" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_RSA=y" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_ECDSA=y" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_BOOTM_EFI=y" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_SPI_FLASH_UNLOCK_ALL=n" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_TPM2_FTPM_TEE=y" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_DM_RNG=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_TPM=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_TPM_V1=n" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_TPM_V2=y" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_TPM_RNG=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_TPM2_TIS_SPI=y" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_TPL_TPM=y" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_SPL_TPM=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_MEASURED_BOOT=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_STACKPROTECTOR=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_TPL_STACKPROTECTOR=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_SPL_STACKPROTECTOR=y" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_SPL_OPTEE_IMAGE=y" >> configs/rockpro64-rk3399_defconfig
echo "CONFIG_TEE=y" >> configs/rockpro64-rk3399_defconfig
echo "CONFIG_OPTEE=y" >> configs/rockpro64-rk3399_defconfig
echo "CONFIG_OPTEE_TZDRAM_SIZE=0x700000" >> configs/rockpro64-rk3399_defconfig
echo "CONFIG_OPTEE_SERVICE_DISCOVERY=y" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_OPTEE_IMAGE=y" >> configs/rockpro64-rk3399_defconfig
### echo "CONFIG_SCP03=Y" >> configs/rockpro64-rk3399_defconfig
echo "CONFIG_OPTEE_TA_SCP03=n" >> configs/rockpro64-rk3399_defconfig
echo "CONFIG_OPTEE_TA_AVB=n" >> configs/rockpro64-rk3399_defconfig
echo "CONFIG_CHIMP_OPTEE=n" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_BOOTM_OPTEE=y" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_RNG_OPTEE=y" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_LIB_HW_RAND=y" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_ARM_FFA_TRANSPORT=y" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_FFA_SHARED_MM_BUF_SIZE=4000" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_FFA_SHARED_MM_BUF_OFFSET=0" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_FFA_SHARED_MM_BUF_ADDR=0x0" >> configs/rockpro64-rk3399_defconfig
#### echo "CONFIG_SUPPORT_EMMC_RPMB=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_SUPPORT_EMMC_BOOT=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_EFI_VARIABLE_FILE_STORE=n" >> configs/rockpro64-rk3399_defconfig
# echo "CONFIG_EFI_RNG_PROTOCOL=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_EFI_TCG2_PROTOCOL=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_EFI_TCG2_PROTOCOL_MEASURE_DTB=y" >> configs/rockpro64-rk3399_defconfig
echo "CONFIG_EFI_MM_COMM_TEE=y" >> configs/rockpro64-rk3399_defconfig
#### echo "CONFIG_EFI_VAR_BUF_SIZE=7340032" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_EFI_SECURE_BOOT=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_SOFT_SPI=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_CMD_MMC_RPMB=y" >> configs/rockpro64-rk3399_defconfig
echo "CONFIG_CMD_OPTEE_RPMB=y" >> configs/rockpro64-rk3399_defconfig
### echo "CONFIG_CMD_SCP03=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_CMD_TPM=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_CMD_TPM_TEST=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_CMD_BOOTMENU=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_CMD_BOOTEFI_BOOTMGR=y" >> configs/rockpro64-rk3399_defconfig
## echo "CONFIG_CMD_EFIDEBUG=y" >> configs/rockpro64-rk3399_defconfig
make rockpro64-rk3399_defconfig
cat configs/rockpro64-rk3399_defconfig
read -p "menuconfig -->"
make menuconfig
read -p "Build U-Boot -->"
FORCE_SOURCE_DATE=1 SOURCE_DATE=$SOURCE_DATE SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH make -j$(nproc) all
sha512sum u-boot-rockchip.bin
sha512sum u-boot-rockchip-spi.bin
read -p "Insert any SD Card, Then Press Enter to Continue"
dd if=/dev/zero of=/dev/mmcblk1 bs=1M count=2000 status=progress
parted /dev/mmcblk1 mktable gpt mkpart P1 fat32 16MB 1G -s && sleep 3
mkfs.fat /dev/mmcblk1p1
mount /dev/mmcblk1p1 /mnt
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
sync
popd
cp /tmp/u-boot-rockchip.bin Builds/u-boot-rockchip.bin
cp /tmp/u-boot-rockchip.bin.sum Builds/u-boot-rockchip.bin.sum
cp /tmp/u-boot-rockchip-spi.bin Builds/u-boot-rockchip-spi.bin
cp /tmp/u-boot-rockchip-spi.bin.sum Builds/u-boot-rockchip-spi.bin.sum
cp /tmp/BL32_AP_MM.fd Builds/BL32_AP_MM.fd
cp /tmp/optee_os-$(echo $OPT_VER)/out/arm-plat-rockchip/core/tee.bin Builds/tee.bin
git status && git add -A && git status
read -p "Successful Build of U-Boot v$(echo $UB_VER) at $(echo $BUILD_MESSAGE_TIMESTAMP) W/ TF-A $(echo $ATF_VER) & OP-TEE $(echo $OPT_VER) For The RockPro64: Sign -->"
git commit -a -S -m "Successful Build of U-Boot v$(echo $UB_VER) at $(echo $BUILD_MESSAGE_TIMESTAMP) W/ TF-A $(echo $ATF_VER) & OP-TEE $(echo $OPT_VER) For The RockPro64"
git push --set-upstream origin RP64-rk3399-A
cd ..
apt remove --purge bc bison build-essential device-tree-compiler dosfstools flex gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi libncurses-dev libssl-dev parted python3-dev python3-pyelftools python3-setuptools swig unzip wget zip -y && apt autoremove -y
rm -f -r /tmp/u-boot* && rm -f /tmp/4.* && rm -f /tmp/lts* && rm -f /tmp/v2* && rm -f -r /tmp/arm-trusted-firmware-* && rm -f -r /tmp/optee_os-* && rm -f /tmp/000* && rm -f /tmp/logo.bmp && rm -f /tmp/BL32_AP_MM.fd && rm -f -r U-Boot && cd ..
exit
