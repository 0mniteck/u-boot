#!/bin/bash
sudo apt install -y bc dosfstools parted screen snapd && sudo snap install syft --classic
git remote remove origin && git remote add origin git@UBoot:0mniteck/U-Boot.git
./clean.sh $1
sudo screen -L -Logfile /tmp/builder.log bash -c './re-run.sh '$(($2))
cp /tmp/builder.log Builds/builder.log
status="$(cat /tmp/status.build)"
./clean.sh cleanup
read -p "$status: --> sign, commit, and push"
./git.sh "$status" "$3"
ls -la Builds/* && cd ..
