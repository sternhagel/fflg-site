#!/bin/bash

#make -C gluon clean GLUON_TARGET=ar71xx-generic GLUON_SITEDIR=$(pwd)/site
make -C gluon clean GLUON_TARGET=ar71xx-tiny GLUON_SITEDIR=$(pwd)/site
