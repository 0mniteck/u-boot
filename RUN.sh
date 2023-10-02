#!/bin/bash -e

##
##	Pinephone U-Boot Assembler
##		Requirements: Debian based OS running on ARM64 CPU & any size Unformatted microSD in the MMCBLK1 slot w/ no MBR/GUID
##		  By: Shant Tchatalbachian
##

git remote remove origin && git remote add origin git@UBoot:0mniteck/U-Boot.git
rm -f build.zip
pushd /tmp/
apt update && apt install build-essential bc zip unzip bison flex libssl-dev device-tree-compiler swig python3-pyelftools python3-dev -y
wget https://github.com/crust-firmware/arm-trusted-firmware/archive/refs/tags/crust-20220611.zip
echo 'fe8e12a45b6077c94f36fdd22a84d7c28088ba5f689f8a0b79f4d7699a3634f332d455a59ea07375f774acb8d5e93c5532d76fbe0b890c7b5b885c29f3c6d5ad  crust-20220611.zip' > v2.zip.sum
if [[ $(sha512sum -c v2.zip.sum) == 'crust-20220611.zip: OK' ]]; then sleep 0; else exit 1; fi;
wget https://github.com/u-boot/u-boot/archive/refs/tags/v2023.10.zip
echo '256e83b931005b3d596ec10c0be74daa3ad433e0e0fc851dae2c209e70d910ad3767c9ce5ba95d1feee362bb4365f056b67ccca1a88fc324471681f99bc4f403  v2023.10.zip' > v2023.zip.sum
if [[ $(sha512sum -c v2023.zip.sum) == 'v2023.10.zip: OK' ]]; then sleep 0; else exit 1; fi;
unzip v202*.zip
unzip crust-*.zip
cd arm-trusted-firmware-crust-*
echo "Entering TF-A ------"
make realclean
make PLAT=sun50i_a64 bl31
export BL31=/tmp/arm-trusted-firmware-crust-20220611/build/sun50i_a64/release/bl31/bl31.elf
cd ..
echo "Bypassing Crust ------"
export SCP=/dev/null
cd u-boot-202*
echo "Entering U-Boot ------"
make pinephone_defconfig && make -j$(nproc) all
sha512sum u-boot-sunxi-with-spl.bin
dd if=u-boot-sunxi-with-spl.bin of=/dev/mmcblk1 bs=8k seek=1
sha512sum u-boot-sunxi-with-spl.bin > /tmp/u-boot-sunxi-with-spl.bin.sum
cp u-boot-sunxi-with-spl.bin /tmp/u-boot-sunxi-with-spl.bin
cd ..
zip -0 build.zip u-boot-sunxi-with-spl.bin u-boot-sunxi-with-spl.bin.sum
sync
popd
cp /tmp/build.zip build.zip
git status
git add -A && git status && git commit -a -S -m "Successful Build of U-Boot with TF-A"
git push
apt remove --purge build-essential bc zip unzip bison flex libssl-dev device-tree-compiler swig python3-pyelftools python3-dev -y && apt autoremove -y
rm -f -r /tmp/u-boot-202* && rm -f /tmp/crust-* && rm -f -r /tmp/arm-trusted-firmware* && rm -f -r /tmp/u-boot* && rm -f /tmp/build*
