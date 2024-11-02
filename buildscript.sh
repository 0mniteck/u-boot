#!/bin/bash
sudo apt install bc git git-lfs screen snapd -y
git remote remove origin && git remote add origin git@UBoot:0mniteck/U-Boot.git
git-lfs install
echo "Starting Build "$(date -u '+on %D at %R UTC')
./increment.sh $1
sudo screen -L -Logfile /tmp/builder.log bash -c './re-run.sh '$(($2))
cp /tmp/builder.log builds/builder.log && rm -f /tmp/builder.log
echo "# Base Build System: $(uname -o) $(uname -r) $(uname -p) $(lsb_release -ds) $(lsb_release -cs) $(uname -v)"  >> builds/release.sha512sum
awk '{a[i++]=$0}END{for(j=0;j<i-2;j++)print a[j];print a[i-1];print a[i-2]}' builds/release.sha512sum > tmp && mv tmp builds/release.sha512sum
ls -la builds/*
cd ..
