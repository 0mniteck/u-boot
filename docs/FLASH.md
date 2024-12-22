# Flashing Recipe

[Asciinema Demo](https://asciinema.org/a/kSWswlC3jxwgrxGbu8Lc0redZ)

### Always do an Initial Flash From Bypassed and Erased SPI/eMMC

#### Erase current SPI, then boot into U-Boot Via SD with sdcard.img

`Insert SD Card`

`Bypass SPI & eMMC`

`Power-on`

#### Wait untill you see the environment fail to load from SPI

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
