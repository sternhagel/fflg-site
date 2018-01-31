#!/bin/bash

echo 
echo "intended use for experimental releases:"
echo "./doit.sh"
echo 
echo "intended use for stable releases:"
echo "./doit.sh <release number> delete 2>&1 >logfile"
echo 
echo "after changing gluon version or packages"
echo "rm -rf gluon"
echo "./doit.sh"
echo 
echo
echo

touch running
date 
echo "-----------------------------" 
echo -n "Start:" >results_in_a_nutshell.log
date >>results_in_a_nutshell.log

export GLUON_SITEDIR=$(pwd)/site

if [ ! -d gluon ] ;
then
	git clone https://github.com/freifunk-gluon/gluon.git gluon -b v2016.2.x
fi

export GLUON_BRANCH=experimental
if [ $1"x" != "x" ] ;
then
	export GLUON_RELEASE=$1	
	export GLUON_BRANCH=stable
fi

echo "GLUON_RELEASE=" $GLUON_RELEASE  >>results_in_a_nutshell.log
echo "GLUON_BRANCH="  $GLUON_BRANCH   >>results_in_a_nutshell.log

cd gluon
echo "-----------------------------" 
echo "rm -rf output/*" 
echo "-----------------------------" 
rm -rf output/*

if [ $2"x" == "deletex" ] ;
then
	echo "-----------------------------" 
	echo " make dirclean " 
	echo "-----------------------------" 
	make dirclean 
fi

echo "-----------------------------" 
echo "make update GLUON_TARGET=ar71xx-generic" 
echo "-----------------------------" 
make update GLUON_TARGET=ar71xx-generic 

echo "update done" >>../results_in_a_nutshell.log

if [ $2"x" == "deletex" ] ;
then
	echo "-----------------------------" 
	echo " make clean  GLUON_TARGET=ar71xx-generic" 
	echo "-----------------------------" 
	make clean  GLUON_TARGET=ar71xx-generic 
	echo "-----------------------------" 
	echo " make clean  GLUON_TARGET=x86-generic" 
	echo "-----------------------------" 
	make clean  GLUON_TARGET=x86-generic 
fi

echo "-----------------------------" 
echo "make -j$(nproc) GLUON_TARGET=ar71xx-generic" 
echo "-----------------------------" 
make -j$(nproc) GLUON_TARGET=ar71xx-generic  

if [ $? -ne 0 ] ;
then
	echo "error during ar71xx-generic producing " >>../results_in_a_nutshell.log

	echo "-----------------------------" 
	echo "make  -j1 V=s GLUON_TARGET=ar71xx-generic" 
	echo "-----------------------------" 
	make  -j1 V=s GLUON_TARGET=ar71xx-generic  
else
	echo "ar71xx-generic produced without error " >>../results_in_a_nutshell.log

	echo "-----------------------------" 
	echo "make -j$(nproc) GLUON_TARGET=x86-generic" 
	echo "-----------------------------" 
	make -j$(nproc) GLUON_TARGET=x86-generic  
	if [ $? -ne 0 ] ;
	then
		echo "error during x86-generic producing " >>../results_in_a_nutshell.log
	else
		echo "x86-generic produced without error " >>../results_in_a_nutshell.log

		echo "-----------------------------" 
		echo "  make manifest " 
		echo "-----------------------------" 
		make manifest
		contrib/sign.sh ~/autoupdater/secret output/images/sysupgrade/$GLUON_BRANCH.manifest
	fi
fi

echo "-----------------------------" 
date 
echo "-----------------------------" 

cd ..
echo -n "finished :" >>results_in_a_nutshell.log
date >>results_in_a_nutshell.log

ls -lrt gluon/output/images/sysupgrade/
rm running 

