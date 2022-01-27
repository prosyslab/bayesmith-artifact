#!/usr/bin/env bash

# Runs Bingo in batch mode on all the benchmarks
# Usage: ./run_single.sh [program] [reuse] [--bayesmith]

set -e

PROG=$1
mkdir -p result

if [[ "$@" =~ "reuse" ]]; then
  export REUSE=reuse
fi

if [[ "$@" =~ "--bayesmith" ]]; then
  OPT_BAYESMITH="--bayesmith"
fi

taint_benchmarks=(
  "optipng-0.5.3"
  "latex2rtf-2.1.1"
  "shntool-3.0.5"
)

interval_benchmarks=(
  "bc-1.06"
  "cflow-1.5"
  "grep-2.19"
  "gzip-1.2.4a"
  "patch-2.7.1"
  "readelf-2.24"
  "sed-4.3"
  "sort-7.2"
  "tar-1.28"
)

function run_interval() {
  p=$1
  echo $p
  ./run.sh benchmark/$p/$p.c interval $REUSE $OPT_BAYESMITH >& result/$p.interval.batch.log
}

function run_taint() {
  p=$1
  echo $p
  ./run.sh benchmark/$p/$p.c taint $REUSE $OPT_BAYESMITH >& result/$p.taint.batch.log
}

function run_optipng() {
  run_taint optipng-0.5.3
}

function run_latex2rtf() {
  run_taint latex2rtf-2.1.1
}

function run_shntool() {
  run_taint shntool-3.0.5
}

function run_bc() {
  run_interval bc-1.06
}

function run_cflow() {
  run_interval cflow-1.5
}

function run_grep() {
  run_interval grep-2.19
}

function run_gzip() {
  run_interval gzip-1.2.4a
}

function run_patch() {
  run_interval patch-2.7.1
}

function run_readelf() {
  run_interval readelf-2.24
}

function run_sed() {
  run_interval sed-4.3
}

function run_sort() {
  run_interval sort-7.2
}

function run_tar() {
  run_interval tar-1.28
}

run_$PROG