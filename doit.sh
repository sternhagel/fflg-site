#!/bin/bash

touch running
date
echo "-----------------------------"
echo -n "Start:" >results_in_a_nutshell.log
date >>results_in_a_nutshell.log

export GLUON_SITEDIR=$(pwd)/site
export GLUON_SITE_VERSION=$(git --git-dir=.git describe --always --dirty=+)

if [ ! -d gluon ]; then
  git clone https://github.com/freifunk-gluon/gluon.git gluon -b v2021.1.1
fi
cd gluon
for f in ../site/patch/*; do
  patch -fp1 <$f >>../results_in_a_nutshell.log
done

if [ $1"x" != "x" ]; then
  export GLUON_RELEASE=$1
  export GLUON_AUTOUPDATER_BRANCH=stable
else
  export GLUON_RELEASE=1.4.5pre-exp$(date '+%Y%m%d%H%M')
  export GLUON_AUTOUPDATER_BRANCH=experimental
fi

export GLUON_AUTOUPDATER_ENABLED=1

echo "GLUON_RELEASE=" $GLUON_RELEASE >>../results_in_a_nutshell.log
echo "GLUON_AUTOUPDATER_BRANCH=" $GLUON_AUTOUPDATER_BRANCH >>../results_in_a_nutshell.log
echo "GLUON_SITE_VERSION=" $GLUON_SITE_VERSION >>../results_in_a_nutshell.log

echo "-----------------------------"
echo "rm -rf output/*"
echo "-----------------------------"
rm -rf output/*

if [ $2"x" == "deletex" ]; then
  echo "-----------------------------"
  echo " make dirclean "
  echo "-----------------------------"
  make dirclean
fi

ERRORFLAG=no

ARM="ar71xx-generic ar71xx-tiny ar71xx-nand"
ATH="ath79-generic"
RASPBPI="brcm2708-bcm2708 brcm2708-bcm2709 sunxi-cortexa7"
AVM="ipq40xx-generic lantiq-xrx200 lantiq-xway"
NGR7800="ipq806x-generic"
TPNG="ramips-mt76x8 ramips-mt7620 ramips-mt7621 ramips-rt305x mpc85xx-generic mpc85xx-p1020"
X86="x86-64 x86-generic x86-geode x86-legacy"

# this builds all supported targets - customize if needed..
TARGETS="$ARM $ATH $RASPBPI $AVM $NGR7800 $TPNG $X86"

for TARGET in $TARGETS; do

  echo "-----------------------------"
  echo " make update GLUON_TARGET=$TARGET"
  echo "-----------------------------"
  make update GLUON_TARGET=$TARGET

  echo "update done ($TARGET)" >>../results_in_a_nutshell.log

  if [ $2"x" == "deletex" ]; then
    echo "-----------------------------"
    echo " make clean  GLUON_TARGET=$TARGET"
    echo "-----------------------------"
    make clean GLUON_TARGET=$TARGET
  fi

  echo "-----------------------------"
  echo "make -j$(nproc) GLUON_TARGET=$TARGET"
  echo "-----------------------------"
  make -j$(nproc) GLUON_TARGET=$TARGET

  if [ $? -ne 0 ]; then
    ERRORFLAG=yes
    echo "error during $TARGET producing " >>../results_in_a_nutshell.log

    echo "-----------------------------"
    echo "make  -j1 V=sc GLUON_TARGET=$TARGET"
    echo "-----------------------------"
    make -j1 V=sc GLUON_TARGET=$TARGET
    break
  else
    echo "$TARGET produced without error " >>../results_in_a_nutshell.log
    echo -n "total number of files:" >>../results_in_a_nutshell.log
    ls -lrt output/images/sysupgrade/ | wc -l >>../results_in_a_nutshell.log

    if [ $(df --output=pcent /dev/sda1 | grep -E '([0-9])' | cut -c 3-4) -gt 90 ]; then
      echo "-----------------------------"
      echo "disk is nearly full (>90%)"
      echo "make  clean GLUON_TARGET=$TARGET"
      echo "-----------------------------"
      echo "disk cleanup ($TARGET)" >>../results_in_a_nutshell.log
      make clean GLUON_TARGET=$TARGET
    fi
  fi
done

if [ $ERRORFLAG == "no" ]; then
  echo "-----------------------------"
  echo "  make manifest "
  echo "-----------------------------"
  make manifest
  contrib/sign.sh ~/autoupdater/secret output/images/sysupgrade/$GLUON_AUTOUPDATER_BRANCH.manifest
  echo "$GLUON_AUTOUPDATER_BRANCH.manifest written " >>../results_in_a_nutshell.log
fi

echo "-----------------------------"
date
echo "-----------------------------"

cd ..
echo -n "finished :" >>results_in_a_nutshell.log
date >>results_in_a_nutshell.log

if [ $ERRORFLAG == "no" ]; then
  ls -lrt gluon/output/images/sysupgrade/
  echo -n "no files:"
  ls -lrt gluon/output/images/sysupgrade/ | wc -l
  touch gluon/output/images/*/*
fi

rm running
