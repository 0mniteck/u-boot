## Signing Recipe

openssl req -x509 -sha256 -engine pkcs11 -keyform ENGINE -key 1 -subj /CN=OMNITECK_PK/ -out PK.crt -nodes -days 1826
cert-to-efi-sig-list -g cc1e39bc-7c39-11ef-b26d-9b41b973d7e9 PK.crt PK.esl;
sign-efi-sig-list -c PK.crt -e "pkcs11:1" PK PK.esl PK.auth

openssl req -x509 -sha256 -engine pkcs11 -keyform ENGINE -key 1 -subj /CN=OMNITECK_KEK/ -out KEK.crt -nodes -days 1826
cert-to-efi-sig-list -g cc1e39bc-7c39-11ef-b26d-9b41b973d7e9 KEK.crt KEK.esl
sign-efi-sig-list -c PK.crt -e "pkcs11:1" KEK KEK.esl KEK.auth

openssl req -x509 -sha256 -engine pkcs11 -keyform ENGINE -key 1 -subj /CN=OMNITECK_db/ -out db.crt -nodes -days 1826
cert-to-efi-sig-list -g cc1e39bc-7c39-11ef-b26d-9b41b973d7e9 db.crt db.esl
sign-efi-sig-list -c KEK.crt -e "pkcs11:1" db db.esl db.auth


rm -f /boot/efi/EFI/ubuntu/shimaa64.efi.signed && cd tmp && sbsign --key db.key --cert db.crt /usr/lib/shim/shimaa64.efi --output /boot/efi/EFI/ubuntu/shimaa64.efi.signed
rm -f /boot/efi/EFI/ubuntu/shimaa64.efi.signed && cd tmp && sbsign --engine "pkcs11:1" --key 1 --cert db.crt /usr/lib/shim/shimaa64.efi --output /boot/efi/EFI/ubuntu/shimaa64.efi.signed

fatload mmc 0:1 $kernel_addr_r PK.auth
setenv -e -nv -bs -rt -at -i $kernel_addr_r:$filesize PK
fatload mmc 0:1 $kernel_addr_r KEK.auth
setenv -e -nv -bs -rt -at -i $kernel_addr_r:$filesize KEK
fatload mmc 0:1 $kernel_addr_r db.auth
setenv -e -nv -bs -rt -at -i $kernel_addr_r:$filesize db
run bootcmd
