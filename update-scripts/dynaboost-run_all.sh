#!/usr/bin/env bash

# Runs Bingo in batch mode on all the benchmarks
# Usage: ./run_all.sh [reuse] [--bayesmith]

set -e

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
  work=("$@")
  for p in "${work[@]}"; do
    echo $p
    ./run.sh benchmark/$p/$p.c interval $REUSE $OPT_BAYESMITH >& result/$p.interval.batch.log
  done
}

function run_taint() {
  work=("$@")
  for p in "${work[@]}"; do
    echo $p
    ./run.sh benchmark/$p/$p.c taint $REUSE $OPT_BAYESMITH >&result/$p.taint.batch.log
  done
}

run_taint ${taint_benchmarks[@]}
run_interval ${interval_benchmarks[@]}