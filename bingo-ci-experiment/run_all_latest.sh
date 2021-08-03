#!/usr/bin/env bash

# Runs Bingo in batch mode on all the benchmarks
# Usage: ./run_all.sh [reuse]

set -e

if [[ "$@" =~ "reuse" ]]; then
  export REUSE=reuse
fi

work1=( "shntool-3.0.7" "latex2rtf-2.3.16" "optipng-0.7.6" "grep-3.0" "sed-4.4" )
work2=( "shntool-3.0.10" "latex2rtf-2.3.17" )
work3=( "optipng-0.7.7" "grep-3.1" "sed-4.5" )
work4=( "wget-1.19.4" "readelf-2.31" "urjtag-2018.06" "tar-1.29" )
work5=( "wget-1.19.5" "readelf-2.31.1" )
work6=( "urjtag-2018.09" "tar-1.30" )

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
