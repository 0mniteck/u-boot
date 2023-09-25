# U-Boot Allwinner A64
## U-Boot Prebuilt Release v2023.07.02 W/ ATF v2.9 & SCP v0.6

Prebuilt spi_combined.zip is included for convenience.

## PinePhone SPI-Uboot Assembler

Requirements:

* [ ] Debian based OS already running on an ARM64 architecture CPU

* [ ] Any size Fat formatted microsd in the /dev/mmcblk1 slot w/ no MBR/GUID


## Post-Build

Reboot into U-Boot, Then:

`sf probe`

`sf erase 0x0 0x1000000`

`ls mmc 1:0 /`

`load mmc 1:0 $kernel_addr_r spi_combined.img`

`sf write $kernel_addr_r 0 $filesize`

`reset`

`saveenv`

`reset`
