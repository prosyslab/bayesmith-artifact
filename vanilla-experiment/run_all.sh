#!/usr/bin/env bash

# Runs Bingo in batch mode on all the benchmarks
# Usage: ./run_all.sh [reuse]

set -e

if [[ "$@" =~ "reuse" ]]; then
  export REUSE=reuse
fi

work1=( "shntool-3.0.4" "latex2rtf-2.1.0" "optipng-0.5.2" "grep-2.18" "sed-4.2.2" )
work2=( "shntool-3.0.5" "latex2rtf-2.1.1" "sort-7.1" "sort-7.2")
work3=( "optipng-0.5.3" "grep-2.19" "sed-4.3" )
work4=( "wget-1.11.4" "readelf-2.23.2" "urjtag-0.7" "tar-1.27" )
work5=( "wget-1.12" "readelf-2.24" )
work6=( "urjtag-0.8" "tar-1.28" )

function run () {
  work=("$@")
  for p in "${work[@]}"; do
    echo $p
    ./run.sh benchmark/$p/$p.c interval $REUSE >& result/$p.interval.batch.log
    ./run.sh benchmark/$p/$p.c taint reuse >& result/$p.taint.batch.log
  done
}

run ${work1[@]} & run ${work2[@]} & run ${work3[@]} & run ${work4[@]} \
  & run ${work5[@]} & run ${work6[@]}
wait
