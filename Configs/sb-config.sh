#!/usr/bin/env bash

echo 'CONFIG_SYS_PROMPT="0MNITECK:~$ "' >> defconfig
echo 'CONFIG_LOCALVERSION=" 0MNITECK"' >> defconfig
echo "CONFIG_FIT_SIGNATURE=y" >> defconfig
echo "CONFIG_RSA=y" >> defconfig
echo "CONFIG_ECDSA=y" >> defconfig
echo "CONFIG_TEE=y" >> defconfig
echo "CONFIG_OPTEE=y" >> defconfig
echo "CONFIG_OPTEE_TZDRAM_SIZE=0x02000000" >> defconfig
echo "CONFIG_OPTEE_SERVICE_DISCOVERY=y" >> defconfig
echo "CONFIG_BOOTM_EFI=y" >> defconfig
echo "CONFIG_BOOTM_OPTEE=y" >> defconfig
echo "CONFIG_OPTEE_TA_SCP03=n" >> defconfig
echo "CONFIG_OPTEE_TA_AVB=n" >> defconfig
echo "CONFIG_CHIMP_OPTEE=n" >> defconfig
echo "CONFIG_EFI_SECURE_BOOT=y" >> defconfig
echo "CONFIG_EFI_LOADER=y" >> defconfig
echo "CONFIG_CMD_BOOTEFI=y" >> defconfig
echo "CONFIG_EFI_VARIABLE_NO_STORE=y" >> defconfig
echo "CONFIG_EFI_VARIABLES_PRESEED=y" >> defconfig
echo 'CONFIG_EFI_VAR_SEED_FILE="efi.var"' >> defconfig
