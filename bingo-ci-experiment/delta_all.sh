#!/usr/bin/env bash

set -e

# Usage: ./delta_all.sh [syn | sem] [strong | inter | weak]

MODE=$1
FB_MODE=$2
EPS=$3

if [[ "$MODE" == "sem-eps" ]]; then
  SUFFIX=delta.$MODE.$FB_MODE.$EPS
else
  SUFFIX=delta.$MODE.$FB_MODE
fi

if [[ "$@" =~ "reuse-trans" ]]; then
  REUSE_TRANS="reuse-trans"
fi

if [[ "$@" =~ "reuse-bnet" ]]; then
  REUSE_BNET="reuse-bnet"
fi

function run_shntool () {
  analysis=( "taint" )
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/shntool-3.0.4 benchmark/shntool-3.0.5 $ANALYSIS $MODE $FB_MODE $EPS $REUSE_TRANS $REUSE_BNET \
      >& result/shntool-3.0.5.$ANALYSIS.$SUFFIX.log
  done
}

function run_latex2rtf () {
  analysis=( "taint" )
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/latex2rtf-2.1.0 benchmark/latex2rtf-2.1.1 $ANALYSIS $MODE $FB_MODE $EPS $REUSE_TRANS $REUSE_BNET \
      >& result/latex2rtf-2.1.1.$ANALYSIS.$SUFFIX.log
  done
}

function run_optipng () {
  analysis=( "taint" )
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/optipng-0.5.2 benchmark/optipng-0.5.3 $ANALYSIS $MODE $FB_MODE $EPS $REUSE_TRANS $REUSE_BNET \
      >& result/optipng-0.5.3.$ANALYSIS.$SUFFIX.log
  done
}

function run_grep () {
  analysis=( "interval" )
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/grep-2.18 benchmark/grep-2.19 $ANALYSIS $MODE $FB_MODE $EPS $REUSE_TRANS $REUSE_BNET \
      >& result/grep-2.19.$ANALYSIS.$SUFFIX.log
  done
}

function run_sed () {
  analysis=( "interval" )
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/sed-4.2.2 benchmark/sed-4.3 $ANALYSIS $MODE $FB_MODE $EPS $REUSE_TRANS $REUSE_BNET \
      >& result/sed-4.3.$ANALYSIS.$SUFFIX.log
  done
}

function run_wget () {
  analysis=( "interval" )
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/wget-1.11.4 benchmark/wget-1.12 $ANALYSIS $MODE $FB_MODE $EPS $REUSE_TRANS $REUSE_BNET \
      >& result/wget-1.12.$ANALYSIS.$SUFFIX.log
  done
}

function run_readelf () {
  analysis=( "interval" )
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/readelf-2.23.2 benchmark/readelf-2.24 $ANALYSIS $MODE $FB_MODE $EPS $REUSE_TRANS $REUSE_BNET \
      >& result/readelf-2.24.$ANALYSIS.$SUFFIX.log
  done
}

function run_urjtag () {
  analysis=( "taint" )
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/urjtag-0.7 benchmark/urjtag-0.8 $ANALYSIS $MODE $FB_MODE $EPS $REUSE_TRANS $REUSE_BNET \
      >& result/urjtag-0.8.$ANALYSIS.$SUFFIX.log
  done
}

function run_tar () {
  analysis=( "interval" )
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/tar-1.27 benchmark/tar-1.28 $ANALYSIS $MODE $FB_MODE $EPS $REUSE_TRANS $REUSE_BNET \
      >& result/tar-1.28.$ANALYSIS.$SUFFIX.log
  done
}

function run_sort () {
  analysis=( "interval" )
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/sort-7.1 benchmark/sort-7.2 $ANALYSIS $MODE $FB_MODE $EPS $REUSE_TRANS $REUSE_BNET \
      >& result/sort-7.2.$ANALYSIS.$SUFFIX.log
  done
}

run_shntool & run_latex2rtf & run_optipng & run_grep & run_sed & run_wget \
  & run_readelf & run_urjtag & run_tar & run_sort
wait
