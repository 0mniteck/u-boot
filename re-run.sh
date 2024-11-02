#!/bin/bash

rm -f -r /var/snap/docker/*
rm -f -r /var/snap/docker
snap remove docker --purge
mkdir /var/snap/docker
chown root:root /var/snap/docker
snap install docker --revision=2936
ufw disable
sleep 10

source_date_epoch=1
if [ "$1" != 0 ]; then
  echo "Using override timestamp for SOURCE_DATE_EPOCH."
  source_date_epoch=$(($2))
else
  git_timestamp=$(git log -1 7.20.0 --pretty=%ct)
  if [ "${git_timestamp}" != "" ]; then
    echo "Setting SOURCE_DATE_EPOCH from commit: $(git log -1 7.20.0 --oneline)"
    source_date_epoch=$((git_timestamp))
  else
    echo "Can't get latest commit timestamp. Defaulting to 1."
    source_date_epoch=1
  fi
fi

docker build -t TEMPLATE \
  --build-arg SOURCE_DATE_EPOCH=$source_date_epoch \
  --build-arg ENTRYPOINT=rk3399-efi .

docker run -it --cpus=$(nproc) \
  --name TEMPLATE \
  --user "$(id -u):$(id -g)" \
  -e SOURCE_DATE_EPOCH=$source_date_epoch \
  TEMPLATE

rm -fr builds/release/
mkdir -p builds/release
docker cp TEMPLATE:/TEMPLATE/release/ builds/
snap disable docker
rm -f -r /var/snap/docker/*
rm -f -r /var/snap/docker
sleep 10
snap remove docker --purge
snap remove docker --purge
ufw -f enable
read -p "Close Screen Session: Continue to Signing-->"
