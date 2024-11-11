# U-Boot RockChip rk3399 & rk3566
Development Branch

### Project Goals
* [ ] Enable TPM Support
* [x] Enable UEFI Secure Boot with Root CA only on a Yubikey
* [x] Generate SBOM at buildtime
* [x] Fine tune for reproducibility
  * [x] Convert to docker build
    * [x] Build variants in one branch
    * [x] Make reproducable debian docker images

## Build Instructions/Usage:

### Build:

`buildscript.sh {yes/no: make clean} {time: source_date_epoch} {tag: release tag}`:

To build current release clone the repo and run:

```sudo su && git clone git@github.com:0mniteck/U-Boot.git && cd U-Boot && ./buildscript.sh yes "v2024.10+v2.10.9+v4.4.0"```
