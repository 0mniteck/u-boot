# Flashing Recipe

[Asciinema Demo](https://asciinema.org/a/kSWswlC3jxwgrxGbu8Lc0redZ)

### Always do an Initial Flash From Bypassed & Erased SPI/eMMC; And Keep Ethernet Unplugged!

#### Bypass current SPI/eMMC, then boot into U-Boot Via SD with [sdcard.img](https://github.com/0mniteck/U-Boot/tree/UEFI%2BSb%2Bv2024.10%2Bv2.10.7%2Bv4.3.0/Builds)

`Insert SD Card`

`Bypass SPI & eMMC`

`Power-on`

#### Wait untill you see the environment fail to load from SPI

Ensure you see `Trying to boot from MMC2`

As well as `Loading Environment from SPIFlash... jedec_spi_nor flash@0: unrecognized JEDEC id bytes: ff, ff, ff`
`*** Warning - spi_flash_probe_bus_cs() failed, using default environment`

`Reconnect SPI`

`Stop Autoboot by hitting any key`

`sf probe`

`sf erase 0x0 0x1000000`

`reset`

`Stop Autoboot by hitting any key`

`ls mmc 1:1 /`

`load mmc 1:1 $kernel_addr_r u-boot-rockchip-spi.bin`

`sf probe`

`sf write $kernel_addr_r 0 $filesize`

`reset`

`Stop Autoboot by hitting any key`

`saveenv`

`reset`

Check for `Loading Environment from SPIFlash... SF: Detected gd25q128 with page size 256 Bytes, erase size 4 KiB, total 16 MiB`
`OK`

`Power-off`

#### Insert installation [ISO](https://cdimage.ubuntu.com/releases/oracular/release/ubuntu-24.10-desktop-arm64.iso) after adding OMNITECK's [bootaa64.efi](https://github.com/0mniteck/U-Boot/raw/refs/heads/Docker/Deploy/ubuntu/bootaa64.efi) to the ESP patition & Keep the eMMC bypassed and ethernet unplugged during boot

`Bypass eMMC`

`Power-on`

Wait until `Booting /\EFI\BOOT\BOOTAA64.EFI`

`Reconnect eMMC`

Continue installation as usual, connect ethernet, when subiquity has the option select `Automated Installation` and use the provided [https://omniteck.com/autoinstall.yaml](https://github.com/0mniteck/U-Boot/raw/refs/heads/Docker/Deploy/ubuntu/autoinstall.yaml)
