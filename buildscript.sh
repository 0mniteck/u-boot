#!/bin/bash
# chmod +x *.sh
# chmod +x Buildscripts/*.sh
# chmod +x Configs/*.sh
for loc in RP64-rk3399 PBP-rk3399 RP64-rk3399-SB PBP-rk3399-SB
do
mkdir Builds/$loc
done
sudo apt install bc dosfstools git git-lfs parted screen snapd -y
snap install syft --classic
git remote remove origin && git remote add origin git@UBoot:0mniteck/U-Boot.git
git-lfs install
echo "Starting Build "$(date -u '+on %D at %R UTC')
./clean.sh $1
sudo screen -L -Logfile /tmp/builder.log bash -c './re-run.sh '$(($2))
cp /tmp/builder.log Builds/builder.log && rm -f /tmp/builder.log
./git.sh "Build Artifact Added"
ls -la Builds/*
cd ..
