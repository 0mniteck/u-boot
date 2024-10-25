# U-Boot - RockChip rk3399
## Rockchip rk3399 SPI U-Boot Assembler

### U-Boot Prebuilt Release
### [v2024.10 W/ ATF lts-v2.10.7 & OP-TEE v4.3.0](https://github.com/0mniteck/U-Boot/releases/tag/v2024.10%2Bv2.10.7%2Bv4.3.0)
Prebuilt u-boot-rockchip.bin & u-boot-rockchip-spi.bin are included in a bootable `sdcard.img` for convenience
#### RockPro64 - [`Builds/RP64/`](https://github.com/0mniteck/U-Boot/tree/v2024.10%2Bv2.10.7%2Bv4.3.0/Builds/RP64-rk3399)
#### PinebookPro - [`Builds/PBP/`](https://github.com/0mniteck/U-Boot/tree/v2024.10%2Bv2.10.7%2Bv4.3.0/Builds/PBP-rk3399)

### Project Goals
* [x] Enable UEFI Secure Boot with Root CA only on a Yubikey
* [ ] Enable TPM Support
* [ ] Generate SBOM at buildtime
* [ ] Fine tune for reproducibility

### Requirements:

* [ ] Debian based OS already running on an ARM64 CPU

* [ ] Any microSD in the /dev/mmcblk1 slot


### [Docs:](https://github.com/0mniteck/U-Boot/tree/rk3399-A/docs)

--> [FLASHING](https://github.com/0mniteck/U-Boot/blob/rk3399-A/docs/FLASH.md)  --> [FLASHING DEMO](https://u-boot.omniteck.com/#content)

--> [SIGNING](https://github.com/0mniteck/U-Boot/blob/rk3399-A/docs/SIGN.md)
