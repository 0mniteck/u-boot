#!/usr/bin/env bash

echo "CONFIG_TPL=y" >> defconfig
echo "CONFIG_SUPPORT_TPL=y" >> defconfig
echo "TPL_MAX_SIZE=0x2800=y" >> defconfig
echo "TPL_TINY_FRAMEWORK=y" >> defconfig
echo "CONFIG_TPL_TINY_MEMSET=y" >> defconfig
echo "CONFIG_SPL_TINY_MEMSET=y" >> defconfig
echo "TPL_NEEDS_SEPARATE_STACK=y" >> defconfig
echo "CONFIG_ROCKCHIP_EXTERNAL_TPL=n" >> defconfig
##echo "CONFIG_XPL_BUILD=y" >> defconfig
##echo "CONFIG_SPL_STACK=y" >> defconfig
#echo "CONFIG_TPL_DM=y" >> defconfig
#echo "CONFIG_TPL_SERIAL=y" >> defconfig
#echo "CONFIG_NR_DRAM_BANKS=1" >> defconfig
#echo "CONFIG_RAM_ROCKCHIP_LPDDR4=y" >> defconfig
#echo "CONFIG_TPL_LIBCOMMON_SUPPORT=y" >> defconfig
#echo "CONFIG_TPL_LIBGENERIC_SUPPORT=y" >> defconfig
#echo "CONFIG_TPL_ROCKCHIP_COMMON_BOARD=y" >> defconfig
