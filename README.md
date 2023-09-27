# U-Boot Allwinner A64
## U-Boot Prebuilt Release v2023.07.02 W/ ATF v2.9 & SCP v0.6

Prebuilt build.zip is included for convenience.

## PinePhone Uboot Assembler

Requirements:

* [ ] Debian based OS already running on an ARM64 CPU

* [ ] Any size Fat formatted microsd in the /dev/mmcblk1 slot w/ no MBR/GUID


`sf write $kernel_addr_r 0 $filesize`

`reset`

`saveenv`

`reset`
