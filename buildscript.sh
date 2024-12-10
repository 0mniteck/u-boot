#!/bin/bash

export HUB="0mniteck/debian"
export BASE="12-2-2024@sha256:2746563d94f92faac307da344c0ba430cdb4176128c70c0f10d3a8b71cb3946d"
export BASE_EXTRA="12-2-2024@sha256:f8b95aa60064bedfb77f580144cbfca5d42052ff7eb237e79cb7eb0c4fb669e4"

export OPT_VER="4.4.0"
export OPT_SUM="2fae73356770a0eb6e519a8b9ef32e566dd900778e3b52ccb79a63d767cc9dfaa52b920ee94955ef32bbe30304636dc6c26d3f2615483bdd8d4d1d76cdfdaed9"
export ATF_VER="2.12.0"
export ATF_SUM="3940d565ec2d7918a6e943261fff2a05d9886dea46a15c966f691a07ed20a31d45c5c154f12d437db34bf229dc80d697632155dc11dcb52a9e09568fad2bb655"
export UB_VER="2025.01-rc4"
export UB_SUM="53751f9feeff1fd9a6780f6bfc5034d77c9bdd256dde59cdc3c38603521e453fb834683f57473c5cbcc86513cbe9d9ee9eeeecfeefdf41a8c8e721df0e06f1bd"

export BUILD_LIST="PT2-rk3566:pinetab2-rk3566_defconfig RP64-rk3399:rockpro64-rk3399_defconfig PBP-rk3399:pinebook-pro-rk3399_defconfig R5B-rk3588:rock5b-rk3588_defconfig"
export LIST="PT2-rk3566 RP64-rk3399 PBP-rk3399 R5B-rk3588"
export ARCHS="rk3568 rk3399 rk3588"

while getopts ":c:d:r:t:" opt; do
    case $opt in
        c)
            CLEAN="$OPTARG"
            ;;
        d)
            EPOCH="$OPTARG"
            ;;
        r)
            TAG="$OPTARG"
            ;;
        t)
            TEST="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$opt" >&2
            ;;
        :)
            echo "Option -$opt requires an argument." >&2
            ;;
    esac
done

if [ "$CLEAN" = "" ]; then
    CLEAN="yes"
fi
if [ "$TEST" = "" ]; then
    TEST="no"
fi

if [ "$TEST" = "yes" ]; then
  export BUILD_LIST="PT2-rk3566:pinetab2-rk3566_defconfig"
  export LIST="PT2-rk3566"
  export ARCHS="rk3568"
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

echo "Clean Build: $CLEAN"
echo "Override Source Epoch: $EPOCH"
echo "Tag Release: $TAG"
echo "Test Build: $TEST"
sleep 5

sudo apt install -y bc dosfstools parted screen snapd
git remote remove origin && git remote add origin git@UBoot:0mniteck/U-Boot.git
./clean.sh $CLEAN && sudo screen -c vars.env -L -Logfile builder.log bash -c './re-run.sh '$(($EPOCH))' '$CLEAN' '$TEST
mv builder.log Results/builder.log && status="$(cat status.build)" && ./clean.sh cleanup && ls -la Builds/*
read -p "$status: --> sign/commit/push" && ./git.sh "$status" "$TAG"
