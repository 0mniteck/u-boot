# U-Boot RockChip rk3399
Status:
* [x] Build SPM StandaloneMM from EDK2 with GCC5 (Reproducable)
* [x] Build Optee with StandaloneMM support (Reproducable)
* [ ] Build TF-A with StandaloneMM support (DEBUG)
  * [x] Transition to xlat_v2 to add dynamic translation table support (Builds)
  * [ ] Configure sm_mem_map regions (SEG_FAULT)
* [ ] Test Optee MM Communicate
* [ ] Setup Secure Bootflow:
  * [ ] U-Boot Secure boot with signed FIT -> TF-A -> Optee_MM -> UEFI Secure Boot
* [ ] Add support for ARM FFA MM
* [ ] Add support for infineon TPM

## U-Boot Prebuilt Release v2024.07 W/ ATF lts-v2.10.4 & OP-TEE v4.3.0

Prebuilt u-boot-rockchip.bin & u-boot-rockchip-spi.bin are included in `Builds/` for convenience

# RockPro64 SPI U-Boot Assembler

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
