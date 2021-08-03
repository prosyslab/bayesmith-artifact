#!/usr/bin/env bash

# Intended to be run from the bingo-ci-experiment/dacapo folder:
# cd ./bingo-ci-experiment/dacapo
# source scripts/setpaths.sh [java7]

export BASE_DIR=`pwd`

export JAVA7_HOME=$BASE_DIR/jdk/jdk1.7.0_80
export ANT_HOME=$BASE_DIR/jdk/apache-ant-1.10.5
export PATH=$ANT_HOME/bin:$PATH
