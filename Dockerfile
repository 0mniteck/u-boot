# Fetch Arm64 Debian Bookworm Slim Image
FROM debian:bookworm-20241016-slim@sha256:936ea04e67a02e5e83056bfa8c7331e1c9ae89d4a324bbc1654d9497b815ae56

# Sync Repo Info and Install build tools
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
RUN apt install -y build-essential

# Reproducibility
ARG SOURCE_DATE_EPOCH
ENV SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH
RUN mkdir /.cache && chmod -R 777 /.cache

# TEMPLATE Checkout Tag 7.31.0
RUN git clone https://github.com/ /TEMPLATE.git
RUN cd /TEMPLATE/ && git checkout tags/v7.31.0

ARG ENTRYPOINT

# Copy Files
COPY $ENTRYPOINT-buildscript.sh /

ENTRYPOINT ["/$ENTRYPOINT-buildscript.sh"]
