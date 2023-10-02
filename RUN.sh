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
wget https://github.com/ARM-software/arm-trusted-firmware/archive/refs/tags/v2.7.zip
echo '8c421e33b0b248872eef74ac3026366c1d861ced4cebb09b1d16431e130924fb481c7186bb676a7d7818658976dd14bb5f02e80bbb39a0704ba539755a578071  v2.7.zip' > v2.zip.sum
if [[ $(sha512sum -c v2.zip.sum) == 'v2.7.zip: OK' ]]; then sleep 0; else exit 1; fi;
wget https://github.com/u-boot/u-boot/archive/refs/tags/v2021.10.zip
echo '3da78730da93592b4a7d9f7ba4c8d50adb1173411d7bb9aadfb30301902f1c2027775a1bfd39db828a1bd2a431c5a52e86fbb18381dac0059ce25456e532a960  v2021.10.zip' > v2021.zip.sum
if [[ $(sha512sum -c v2021.zip.sum) == 'v2021.10.zip: OK' ]]; then sleep 0; else exit 1; fi;
unzip v202*.zip
unzip v2.*.zip
cd arm-trusted-firmware-*
echo "Entering TF-A ------"
sed -i '/--fatal-warnings -O1/ s/$/ --no-warn-rwx-segments/' Makefile
make realclean
make PLAT=sun50i_a64 bl31
export BL31=/tmp/arm-trusted-firmware-2.7/build/sun50i_a64/release/bl31/bl31.elf
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
rm -f -r /tmp/u-boot-202* && rm -f /tmp/v2* && rm -f -r /tmp/arm-trusted-firmware* && rm -f -r /tmp/u-boot* && rm -f /tmp/build*
