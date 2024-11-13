#!/bin/bash

export HUB="0mniteck/debian"
export BASE="11-9-2024@sha256:626b200e5b82d0319d0177831f74bd67996e9ddc38968cc72a317e7ac38057cc"
export BASE_EXTRA="11-9-2024@sha256:a31cee6cb1c0eab71ac3f881da954f517af562db8657642664afe8bc1b118c11"

export OPT_VER="4.4.0"
export OPT_SUM="2fae73356770a0eb6e519a8b9ef32e566dd900778e3b52ccb79a63d767cc9dfaa52b920ee94955ef32bbe30304636dc6c26d3f2615483bdd8d4d1d76cdfdaed9"
export ATF_VER="dc5d485206e168c7e86ede646e512c761bf1752e"
export ATF_SUM="bc15ed0ed03c83fb426f85a000076eb812872a8337f79f943a4b1cacea6e8ac78d39804df48849134fcd447ea675dd3df15a83df009d1b4dce907c01c7fe5d58"
export UB_VER="2024.10"
export UB_SUM="6502c5773d0470ad380496c181b802b19d1d7ba151098b7644df2528be5311a52e4b0838746b1661a7b173ef79b1e4afa6c87091eda2bfd3bf36ccfae8a09c40"

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

sudo apt install -y bc dosfstools parted screen snapd && sudo snap install syft --classic
git remote remove origin && git remote add origin git@UBoot:0mniteck/U-Boot.git
./clean.sh $1 && sudo screen -c vars.env -L -Logfile builder.log bash -c './re-run.sh '$(($2))' '$4
mv builder.log Builds/builder.log && status="$(cat status.build)" && ./clean.sh cleanup
if [ "$4" = "yes" ]; then
  read -p "$status: --> sign/commit/push" && ./git.sh "$status" "$3"
fi
ls -la Builds/* && cd ..
