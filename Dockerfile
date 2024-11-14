ARG HUB=0mniteck/debian
ARG BASE=default
ARG BASE_EXTRA=default

FROM $HUB:$BASE AS base

FROM $HUB-extra:$BASE_EXTRA AS optee
ARG SOURCE_DATE_EPOCH
ENV SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH
RUN mkdir /.cache && chmod -R 777 /.cache
ARG OPT_VER
ARG OPT_SUM
ENV OPT_VER=$OPT_VER
ENV OPT_SUM=$OPT_SUM
RUN /bin/bash -c 'wget https://github.com/OP-TEE/optee_os/archive/refs/tags/$OPT_VER.zip && echo "$OPT_SUM  $OPT_VER.zip" > $OPT_VER.zip.sum && if [[ $(sha512sum -c $OPT_VER.zip.sum) == "$OPT_VER.zip: OK" ]]; then echo "OP-TEE Checksum Matched!"; else echo "OP-TEE Checksum Mismatched!" & exit 1; fi;'
ARG ENTRYPOINT
COPY Buildscripts/$ENTRYPOINT-buildscript.sh /

FROM base AS arm-trusted
ARG SOURCE_DATE_EPOCH
ENV SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH
ARG BUILD_MESSAGE_TIMESTAMP
ENV BUILD_MESSAGE_TIMESTAMP="$BUILD_MESSAGE_TIMESTAMP"
RUN mkdir /.cache && chmod -R 777 /.cache
ARG ATF_VER
ARG ATF_SUM
ARG ARCHS
ENV ARCHS=$ARCHS
ENV ATF_VER=$ATF_VER
ENV ATF_SUM=$ATF_SUM
RUN /bin/bash -c 'wget https://github.com/ARM-software/arm-trusted-firmware/archive/$ATF_VER.zip && echo "$ATF_SUM  $ATF_VER.zip" > $ATF_VER.zip.sum && if [[ $(sha512sum -c $ATF_VER.zip.sum) == "$ATF_VER.zip: OK" ]]; then echo "TF-A Checksum Matched!"; else echo "TF-A Checksum Mismatched!" & exit 1; fi;'
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
ARG UB_SUM
ENV UB_VER=$UB_VER
ENV UB_SUM=$UB_SUM
RUN /bin/bash -c 'wget https://github.com/u-boot/u-boot/archive/refs/tags/v$UB_VER.zip && echo "$UB_SUM  v$UB_VER.zip" > $UB_VER.zip.sum && if [[ $(sha512sum -c $UB_VER.zip.sum) == "v$UB_VER.zip: OK" ]]; then echo "U-Boot Checksum Matched!"; else echo "U-Boot Checksum Mismatched!" & exit 1; fi;'
ENV TEE=/Builds/rk3399/tee.bin
COPY Builds/rk* /Builds/
COPY Includes/* /
COPY Configs/* /
ARG ENTRYPOINT
COPY Buildscripts/$ENTRYPOINT-buildscript.sh /
