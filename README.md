# U-Boot-rk3399
## U-Boot Prebuilt Release v2023.04 W/ ATF 2.8.6

Prebuilt spi_combined.img is included for convenience.

## RockPro64 SPI-Uboot Assembler

Requirements:

* [ ] Debian based OS already running on the RockPro64

* [ ] Any size Fat formatted microsd in the /dev/mmcblk1 slot w/ no MBR/GUID


## Post-Build

Reboot into U-Boot, Then:

`sf probe`

`sf erase 0x0 0x1000000`

`ls mmc 1:0 /`

`load mmc 1:0 0x02080000 spi_combined.img`

`sf write 0x02080000 0 163800`

`reset`

`saveenv`

`reset`
