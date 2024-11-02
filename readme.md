# U-Boot RockChip rk3399
Development Branch

### Project Goals
* [ ] Enable TPM Support
* [x] Enable UEFI Secure Boot with Root CA only on a Yubikey
* [x] Generate SBOM at buildtime
* [x] Fine tune for reproducibility
  * [x] Convert to docker build
    * [x] Build variants in one branch

## Build Instructions/Usage:

### Build:

`buildscript.sh {yes/no: make clean} {time: source_date_epoch}`:

To build current release clone the repo and run:

```sudo su && git clone git@github.com:0mniteck/Signal-Desktop-Mobian.git && cd Signal-Desktop-Mobian && ./buildscript.sh yes```
