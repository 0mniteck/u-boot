FROM debian:bookworm-20241016-slim@sha256:936ea04e67a02e5e83056bfa8c7331e1c9ae89d4a324bbc1654d9497b815ae56 AS optee
RUN sed -i 's,http://deb.debian.org/debian-security,http://snapshot.debian.org/archive/debian-security/20241024T023334Z,g' /etc/apt/sources.list.d/debian.sources
RUN sed -i 's,http://deb.debian.org/debian,http://snapshot.debian.org/archive/debian/20241024T023111Z,g' /etc/apt/sources.list.d/debian.sources
RUN echo 'Acquire::Check-Valid-Until "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'Acquire::Languages "none";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'Binary::apt-get::Acquire::AllowInsecureRepositories "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'APT::Install-Recommends "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'APT::Immediate-Configure "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN apt update && apt install -y apt-transport-https ca-certificates
RUN sed -i 's,http://snapshot.debian.org/archive/debian-security/20241024T023334Z,https://snapshot.debian.org/archive/debian-security/20241024T023334Z,g' /etc/apt/sources.list.d/debian.sources
RUN sed -i 's,http://snapshot.debian.org/archive/debian/20241024T023111Z,https://snapshot.debian.org/archive/debian/20241024T023111Z,g' /etc/apt/sources.list.d/debian.sources
RUN apt update && apt upgrade -y
RUN apt install -y adb acpica-tools autoconf automake bc bison build-essential ccache cpio cscope curl device-tree-compiler e2tools expect fastboot flex ftp-upload gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi \
gdisk git libattr1-dev libcap-ng-dev libfdt-dev libftdi-dev libglib2.0-dev libgmp3-dev libhidapi-dev libmpc-dev libncurses5-dev libpixman-1-dev libslirp-dev libssl-dev libtool libusb-1.0-0-dev lsb-release make mtools netcat-openbsd ninja-build python3-cryptography \
python3-pip python3-pyelftools python3-serial python-is-python3 rsync swig unzip uuid-dev wget xalan xdg-utils xterm xz-utils zlib1g-dev
ARG SOURCE_DATE_EPOCH
ENV SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH
RUN mkdir /.cache && chmod -R 777 /.cache
ARG OPT_VER
ENV OPT_VER=$OPT_VER
RUN /bin/bash -c 'wget https://github.com/OP-TEE/optee_os/archive/refs/tags/$OPT_VER.zip && echo "2fae73356770a0eb6e519a8b9ef32e566dd900778e3b52ccb79a63d767cc9dfaa52b920ee94955ef32bbe30304636dc6c26d3f2615483bdd8d4d1d76cdfdaed9  $OPT_VER.zip" > $OPT_VER.zip.sum && if [[ $(sha512sum -c $OPT_VER.zip.sum) == "$OPT_VER.zip: OK" ]]; then echo "OP-TEE Checksum Matched!"; else echo "OP-TEE Checksum Mismatched!" & exit 1; fi;'
RUN unzip $OPT_VER.zip
ARG ENTRYPOINT
COPY Buildscripts/$ENTRYPOINT-buildscript.sh /

FROM debian:bookworm-20241016-slim@sha256:936ea04e67a02e5e83056bfa8c7331e1c9ae89d4a324bbc1654d9497b815ae56 AS arm-trusted
RUN sed -i 's,http://deb.debian.org/debian-security,http://snapshot.debian.org/archive/debian-security/20241024T023334Z,g' /etc/apt/sources.list.d/debian.sources
RUN sed -i 's,http://deb.debian.org/debian,http://snapshot.debian.org/archive/debian/20241024T023111Z,g' /etc/apt/sources.list.d/debian.sources
RUN echo 'Acquire::Check-Valid-Until "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'Acquire::Languages "none";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'Binary::apt-get::Acquire::AllowInsecureRepositories "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'APT::Install-Recommends "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'APT::Immediate-Configure "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN apt update && apt install -y apt-transport-https ca-certificates
RUN sed -i 's,http://snapshot.debian.org/archive/debian-security/20241024T023334Z,https://snapshot.debian.org/archive/debian-security/20241024T023334Z,g' /etc/apt/sources.list.d/debian.sources
RUN sed -i 's,http://snapshot.debian.org/archive/debian/20241024T023111Z,https://snapshot.debian.org/archive/debian/20241024T023111Z,g' /etc/apt/sources.list.d/debian.sources
RUN apt update && apt upgrade -y
RUN apt install -y bc bison build-essential device-tree-compiler dosfstools flex gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi libncurses-dev libssl-dev parted python3-dev python3-pyelftools python3-setuptools swig unzip wget zip
ARG SOURCE_DATE_EPOCH
ENV SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH
RUN mkdir /.cache && chmod -R 777 /.cache
ARG ATF_VER
ENV ATF_VER=$ATF_VER
RUN /bin/bash -c 'wget https://github.com/ARM-software/arm-trusted-firmware/archive/refs/tags/lts-v$ATF_VER.zip && echo "2bc9ca1bd00b852dc26819d34626a1d540ee7ed378dc804a85ba6e1ac8725cbf2d3a9ce4398a5bad3285debe5d0fdb8d31d343d6f97c1f4cd351aeecf98acd74  lts-v$ATF_VER.zip" > $ATF_VER.zip.sum && if [[ $(sha512sum -c $ATF_VER.zip.sum) == "lts-v$ATF_VER.zip: OK" ]]; then echo "TF-A Checksum Matched!"; else echo "TF-A Checksum Mismatched!" & exit 1; fi;'
RUN unzip lts-v$ATF_VER.zip
ARG ENTRYPOINT
COPY Buildscripts/$ENTRYPOINT-buildscript.sh /

FROM debian:bookworm-20241016-slim@sha256:936ea04e67a02e5e83056bfa8c7331e1c9ae89d4a324bbc1654d9497b815ae56 AS u-boot
RUN sed -i 's,http://deb.debian.org/debian-security,http://snapshot.debian.org/archive/debian-security/20241024T023334Z,g' /etc/apt/sources.list.d/debian.sources
RUN sed -i 's,http://deb.debian.org/debian,http://snapshot.debian.org/archive/debian/20241024T023111Z,g' /etc/apt/sources.list.d/debian.sources
RUN echo 'Acquire::Check-Valid-Until "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'Acquire::Languages "none";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'Binary::apt-get::Acquire::AllowInsecureRepositories "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'APT::Install-Recommends "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN echo 'APT::Immediate-Configure "false";' >> /etc/apt/apt.conf.d/secure_apt
RUN apt update && apt install -y apt-transport-https ca-certificates
RUN sed -i 's,http://snapshot.debian.org/archive/debian-security/20241024T023334Z,https://snapshot.debian.org/archive/debian-security/20241024T023334Z,g' /etc/apt/sources.list.d/debian.sources
RUN sed -i 's,http://snapshot.debian.org/archive/debian/20241024T023111Z,https://snapshot.debian.org/archive/debian/20241024T023111Z,g' /etc/apt/sources.list.d/debian.sources
RUN apt update && apt upgrade -y
RUN apt install -y bc bison build-essential device-tree-compiler dosfstools flex gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf gcc-arm-none-eabi libgnutls28-dev libncurses-dev libssl-dev lzop parted python3-dev python3-pyelftools python3-setuptools swig unzip uuid-dev wget zip
ARG SOURCE_DATE_EPOCH
ENV SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH
ENV SOURCE_DATE="@$SOURCE_DATE_EPOCH";
ENV FORCE_SOURCE_DATE=1;
RUN mkdir /.cache && chmod -R 777 /.cache
ARG UB_VER
ENV UB_VER=$UB_VER
RUN /bin/bash -c 'wget https://github.com/u-boot/u-boot/archive/refs/tags/v$UB_VER.zip && echo "6502c5773d0470ad380496c181b802b19d1d7ba151098b7644df2528be5311a52e4b0838746b1661a7b173ef79b1e4afa6c87091eda2bfd3bf36ccfae8a09c40  v$UB_VER.zip" > $UB_VER.zip.sum && if [[ $(sha512sum -c $UB_VER.zip.sum) == "v$UB_VER.zip: OK" ]]; then echo "U-Boot Checksum Matched!"; else echo "U-Boot Checksum Mismatched!" & exit 1; fi;'
RUN unzip v$UB_VER.zip -d /RP64
RUN unzip v$UB_VER.zip -d /PBP
ENV TEE=/tee.bin
ENV BL31=/bl31.elf
COPY Builds/tee.bin /
COPY Builds/bl31.elf /
COPY Configs/config.sh /
COPY Configs/sb-config.sh /
COPY Includes/efi.var /
COPY Includes/logo.bmp /
COPY Includes/rk3399-pinebook-pro-u-boot.dtsi /
ARG ENTRYPOINT
COPY Buildscripts/$ENTRYPOINT-buildscript.sh /
