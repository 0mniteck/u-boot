#!/bin/bash
sudo apt install -y bc dosfstools parted screen snapd && sudo snap install syft --classic
git remote remove origin && git remote add origin git@UBoot:0mniteck/U-Boot.git
./clean.sh $1
sudo screen -L -Logfile /tmp/builder.log bash -c './re-run.sh '$(($2))
cp /tmp/builder.log Builds/builder.log
./clean.sh cleanup
read -p "$(cat /tmp/status.build): --> sign and commit"
./git.sh "$(cat /tmp/status.build)" "$3"
rm -f /tmp/status.build && ls -la Builds/* && cd ..
