FROM 0mniteck/debian:11-9-2024@sha256:626b200e5b82d0319d0177831f74bd67996e9ddc38968cc72a317e7ac38057cc AS base

FROM 0mniteck/debian-extra:11-9-2024@sha256:a31cee6cb1c0eab71ac3f881da954f517af562db8657642664afe8bc1b118c11 AS optee
ARG SOURCE_DATE_EPOCH
ENV SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH
RUN mkdir /.cache && chmod -R 777 /.cache
ARG OPT_VER
ENV OPT_VER=$OPT_VER
RUN /bin/bash -c 'wget https://github.com/OP-TEE/optee_os/archive/refs/tags/$OPT_VER.zip && echo "2fae73356770a0eb6e519a8b9ef32e566dd900778e3b52ccb79a63d767cc9dfaa52b920ee94955ef32bbe30304636dc6c26d3f2615483bdd8d4d1d76cdfdaed9  $OPT_VER.zip" > $OPT_VER.zip.sum && if [[ $(sha512sum -c $OPT_VER.zip.sum) == "$OPT_VER.zip: OK" ]]; then echo "OP-TEE Checksum Matched!"; else echo "OP-TEE Checksum Mismatched!" & exit 1; fi;'
RUN unzip -q $OPT_VER.zip
ARG ENTRYPOINT
COPY Buildscripts/$ENTRYPOINT-buildscript.sh /

FROM base AS arm-trusted
ARG SOURCE_DATE_EPOCH
ENV SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH
ARG BUILD_MESSAGE_TIMESTAMP
ENV BUILD_MESSAGE_TIMESTAMP="$BUILD_MESSAGE_TIMESTAMP"
RUN mkdir /.cache && chmod -R 777 /.cache
ARG ATF_VER
ENV ATF_VER=$ATF_VER
RUN /bin/bash -c 'wget https://github.com/ARM-software/arm-trusted-firmware/archive/$ATF_VER.zip && echo "bc15ed0ed03c83fb426f85a000076eb812872a8337f79f943a4b1cacea6e8ac78d39804df48849134fcd447ea675dd3df15a83df009d1b4dce907c01c7fe5d58  $ATF_VER.zip" > $ATF_VER.zip.sum && if [[ $(sha512sum -c $ATF_VER.zip.sum) == "$ATF_VER.zip: OK" ]]; then echo "TF-A Checksum Matched!"; else echo "TF-A Checksum Mismatched!" & exit 1; fi;'
RUN for atf_plat in rk3399 rk3568 rk3588; do unzip -q $ATF_VER.zip -d /$atf_plat; done;
ARG ENTRYPOINT
COPY Buildscripts/$ENTRYPOINT-buildscript.sh /

FROM base AS u-boot
RUN apt install -y libgnutls28-dev lzop
ARG SOURCE_DATE_EPOCH
ENV SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH
ENV SOURCE_DATE="@$SOURCE_DATE_EPOCH";
ENV FORCE_SOURCE_DATE=1;
RUN mkdir /.cache && chmod -R 777 /.cache
ARG UB_VER
ENV UB_VER=$UB_VER
RUN /bin/bash -c 'wget https://github.com/u-boot/u-boot/archive/refs/tags/v$UB_VER.zip && echo "6502c5773d0470ad380496c181b802b19d1d7ba151098b7644df2528be5311a52e4b0838746b1661a7b173ef79b1e4afa6c87091eda2bfd3bf36ccfae8a09c40  v$UB_VER.zip" > $UB_VER.zip.sum && if [[ $(sha512sum -c $UB_VER.zip.sum) == "v$UB_VER.zip: OK" ]]; then echo "U-Boot Checksum Matched!"; else echo "U-Boot Checksum Mismatched!" & exit 1; fi;'
RUN for dev in RP64-rk3399 PBP-rk3399 PT2-rk3566 R5B-rk3588; do for loc in $dev $dev-SB $dev-MU-SB; do unzip -q v$UB_VER.zip -d /$loc; done; done;
ENV TEE=/tee.bin
COPY Builds/tee.bin /
ENV BL31=/rk3399-bl31.elf
COPY Builds/rk3399/bl31.elf /rk3399-bl31.elf
COPY Builds/rk3568/bl31.elf /rk3566-bl31.elf
COPY Builds/rk3588/bl31.elf /rk3588-bl31.elf
COPY Includes/efi.var /
COPY Includes/logo.bmp /
COPY Includes/rk3399-pinebook-pro-u-boot.dtsi /
COPY Configs/* /
ARG ENTRYPOINT
COPY Buildscripts/$ENTRYPOINT-buildscript.sh /
