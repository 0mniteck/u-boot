# U-Boot RockChip rk3399
Status:
* [x] Build SPM StandaloneMM from EDK2
* [ ] Config Optee MM Communicate
* [ ] Add support for ARM FFA MM
* [ ] Add support for infineon TPM


Prebuilt u-boot-rockchip.bin & u-boot-rockchip-spi.bin are included together for convenience

## RockPro64 SPI U-Boot Assembler
## U-Boot (WIP)
### Prebuilt Release v2024.07 W/ ATF lts-v2.10.4 & OP-TEE v4.3.0


## Pinebook Pro SPI U-Boot Assembler 
## U-Boot (WIP)
### Prebuilt Release v2024.07 W/ ATF lts-v2.10.4 & OP-TEE v4.3.0


Requirements:

* [ ] Debian based OS already running on an ARM64 CPU

* [ ] Any microSD in the /dev/mmcblk1 slot


# Post-Build
## Initial-Flash From Bypassed and Erased SPI (Recommended)
## or Update-Flash From Existing U-Boot


### Erase current SPI, then boot into U-Boot Via SD/eMMC with Combined SD

`Stop Autoboot by hitting any key`

`Insert SD Card`

`Bypass SPI`

`reset`

### Wait untill you see the environment fail to load from SPI

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
