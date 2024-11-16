#!/bin/bash

export HUB="0mniteck/debian"
export BASE="11-11-2024@sha256:bec06f3f431ddb41a879956d00caacad6ab23a899fc495ec6d27af5f490e6b43"
export BASE_EXTRA="11-11-2024@sha256:fc26a6d3e47e65d63b62f91840ac8b151dff871df8d68093ec2329654ada0d2d"

export OPT_VER="4.4.0"
export OPT_SUM="2fae73356770a0eb6e519a8b9ef32e566dd900778e3b52ccb79a63d767cc9dfaa52b920ee94955ef32bbe30304636dc6c26d3f2615483bdd8d4d1d76cdfdaed9"
export ATF_VER="2.12-rc0"
export ATF_SUM="c9c2c44cf8a412c228fcce87949ce155500743e7f39bed505e7416058738ab9c67afbcb447f9f6706d7e57779485b1d811648c1636fdd1eae0d7d0da7808ee17"
export UB_VER="2025.01-rc2"
export UB_SUM="0ba126110942f1d5bb3dec3f0f17fab0fa13fce9f4e532e4387167e8e1325ee4b63a17accdbeb102dd2a6fbe70a48dd488953169919da8a4c5d052b250df464d"

export BUILD_LIST="RP64-rk3399:rockpro64-rk3399_defconfig PBP-rk3399:pinebook-pro-rk3399_defconfig PT2-rk3566:pinetab2-rk3566_defconfig R5B-rk3588:rock5b-rk3588_defconfig"
export LIST="RP64-rk3399 PBP-rk3399 PT2-rk3566 R5B-rk3588"
export ARCHS="rk3399 rk3568 rk3588"
if [ "$4" = "yes" ]; then
  export BUILD_LIST="RP64-rk3399:rockpro64-rk3399_defconfig"
  export LIST="RP64-rk3399"
  export ARCHS="rk3399"
fi

> vars.env
for env in HUB^$HUB BASE^$BASE BASE_EXTRA^$BASE_EXTRA OPT_VER^$OPT_VER OPT_SUM^$OPT_SUM ATF_VER^$ATF_VER ATF_SUM^$ATF_SUM UB_VER^$UB_VER UB_SUM^$UB_SUM
do
  env1=$(echo $env | cut -d'^' -f1)
  env2=$(echo $env | cut -d'^' -f2)
  env3=$(echo "setenv $env1 \"$env2\"")
  echo $env3 >> vars.env
done

printf "\"" >> vars.env
for lis in BUILD_LIST^$BUILD_LIST LIST^$LIST ARCHS^$ARCHS
do
  lis1=$(echo $lis | cut -d'^' -f1)
  lis2=$(echo $lis | cut -d'^' -f2)
  if [ $lis1 = BUILD_LIST ] || [ $lis1 = LIST ] || [ $lis1 = ARCHS ]; then
    printf "\"" >> vars.env
    echo "" >> vars.env
    printf "setenv $lis1 \"" >> vars.env
  fi
  printf "$lis2 " >> vars.env
done
echo "$lis1 \"" >> vars.env
sed -i '10d' vars.env

sudo apt install -y bc dosfstools parted screen snapd
git remote remove origin && git remote add origin git@UBoot:0mniteck/U-Boot.git
./clean.sh $1 && sudo screen -c vars.env -L -Logfile builder.log bash -c './re-run.sh '$(($2))' '$4
mv builder.log Results/builder.log && status="$(cat status.build)" && ./clean.sh cleanup
if [ "$3" != "" ]; then
  ls -la Builds/*
  read -p "$status: --> sign/commit/push" && ./git.sh "$status" "$3"
fi
