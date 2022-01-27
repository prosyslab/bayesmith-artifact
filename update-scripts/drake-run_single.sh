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

shntool_bench=(
  "shntool-3.0.4"
  "shntool-3.0.5"
)
latex2rtf_bench=(
  "latex2rtf-2.1.0"
  "latex2rtf-2.1.1"
)
urjtag_bench=(
  "urjtag-0.7"
  "urjtag-0.8"
)
optipng_bench=(
  "optipng-0.5.2"
  "optipng-0.5.3"
)

wget_bench=(
  "wget-1.11.4"
  "wget-1.12"
)
readelf_bench=(
  "readelf-2.23.2"
  "readelf-2.24"
)
grep_bench=(
  "grep-2.18"
  "grep-2.19"
)
sed_bench=(
  "sed-4.2.2"
  "sed-4.3"
)
sort_bench=(
  "sort-7.1"
  "sort-7.2"
)
tar_bench=(
  "tar-1.27"
  "tar-1.28"
)

function run_interval() {
  work=("$@")
  for p in "${work[@]}"; do
    echo $p
    ./run.sh benchmark/$p/$p.c interval $REUSE $OPT_BAYESMITH >&result/$p.batch.log &
  done
}

function run_taint() {
  work=("$@")
  for p in "${work[@]}"; do
    echo $p
    ./run.sh benchmark/$p/$p.c taint $REUSE $OPT_BAYESMITH >&result/$p.batch.log &
  done
}

function run_shntool() {
  run_taint ${shntool_bench[@]}
}

function run_latex2rtf() {
  run_taint ${latex2rtf_bench[@]}
}

function run_urjtag() {
  run_taint ${urjtag_bench[@]}
}

function run_optipng() {
  run_taint ${optipng_bench[@]}
}

function run_wget() {
  run_interval ${wget_bench[@]}
}

function run_readelf() {
  run_interval ${readelf_bench[@]}
}

function run_grep() {
  run_interval ${grep_bench[@]}
}

function run_sed() {
  run_interval ${sed_bench[@]}
}

function run_sort() {
  run_interval ${sort_bench[@]}
}

function run_tar() {
  run_interval ${tar_bench[@]}
}

run_$PROG
wait
