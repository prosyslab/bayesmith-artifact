#!/usr/bin/env bash

set -e

# Usage: ./delta_all.sh [syn | sem] [strong | inter | weak]

MODE=$1
FB_MODE=$2

analysis=( "interval" "taint" )
function run_shntool () {
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/shntool-3.0.7 benchmark/shntool-3.0.10 $ANALYSIS $MODE $FB_MODE \
      >& result/shntool-3.0.10.$ANALYSIS.delta.$MODE.$FB_MODE.log
  done
}

function run_latex2rtf () {
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/latex2rtf-2.3.16 benchmark/latex2rtf-2.3.17 $ANALYSIS $MODE $FB_MODE \
      >& result/latex2rtf-2.3.17.$ANALYSIS.delta.$MODE.$FB_MODE.log
  done
}

function run_optipng () {
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/optipng-0.7.6 benchmark/optipng-0.7.7 $ANALYSIS $MODE $FB_MODE \
      >& result/optipng-0.7.7.$ANALYSIS.delta.$MODE.$FB_MODE.log
  done
}

function run_grep () {
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/grep-3.0 benchmark/grep-3.1 $ANALYSIS $MODE $FB_MODE \
      >& result/grep-3.1.$ANALYSIS.delta.$MODE.$FB_MODE.log
  done
}

function run_sed () {
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/sed-4.4 benchmark/sed-4.5 $ANALYSIS $MODE $FB_MODE \
      >& result/sed-4.5.$ANALYSIS.delta.$MODE.$FB_MODE.log
  done
}

function run_wget () {
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/wget-1.19.4 benchmark/wget-1.19.5 $ANALYSIS $MODE $FB_MODE \
      >& result/wget-1.19.5.$ANALYSIS.delta.$MODE.$FB_MODE.log
  done
}

function run_readelf () {
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/readelf-2.30 benchmark/readelf-2.31 $ANALYSIS $MODE $FB_MODE \
      >& result/readelf-2.31.$ANALYSIS.delta.$MODE.$FB_MODE.log
  done
}

function run_urjtag () {
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/urjtag-2018.06 benchmark/urjtag-2018.09 $ANALYSIS $MODE $FB_MODE \
      >& result/urjtag-2018.09.$ANALYSIS.delta.$MODE.$FB_MODE.log
  done
}

function run_tar () {
  for ANALYSIS in "${analysis[@]}"; do
    ./delta.sh benchmark/tar-1.29 benchmark/tar-1.30 $ANALYSIS $MODE $FB_MODE \
      >& result/tar-1.30.$ANALYSIS.delta.$MODE.$FB_MODE.log
  done
}

run_shntool & run_latex2rtf & run_optipng & run_grep & run_sed & run_wget \
  & run_readelf & run_urjtag & run_tar
wait
