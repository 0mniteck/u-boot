`truncate --size 2M seed.iso`

`mkfs.vfat -n CIDATA seed.iso`

`mount -t vfat seed.iso /mnt`

`cp user-data.txt /mnt/user-data`

`cp network-config.txt /mnt/network-config`

`umount /mnt`
