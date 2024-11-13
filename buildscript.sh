#!/bin/bash
sudo apt install -y bc dosfstools parted screen snapd && sudo snap install syft --classic
git remote remove origin && git remote add origin git@UBoot:0mniteck/U-Boot.git
./clean.sh $1 $4
sudo screen -L -Logfile builder.log bash -c './re-run.sh '$(($2))' '$4
mv builder.log Builds/builder.log
status="$(cat status.build)"
./clean.sh cleanup $4
read -p "$status: --> sign/commit/push"
if [ "$4" = "yes" ]; then
  ./git.sh "$status" "$3"
fi
ls -la Builds/* && cd ..
