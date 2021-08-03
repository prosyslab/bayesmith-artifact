#!/bin/bash

old_programs=(
"shntool-3.0.4/sparrow-out/taint"
"latex2rtf-2.1.0/sparrow-out/taint"
"urjtag-0.7/sparrow-out/taint"
"optipng-0.5.2/sparrow-out/taint"
"wget-1.11.4/sparrow-out/interval"
"grep-2.18/sparrow-out/interval"
"readelf-2.23.2/sparrow-out/interval"
"sed-4.2.2/sparrow-out/interval"
"sort-7.1/sparrow-out/interval"
"tar-1.27/sparrow-out/interval"
)

new_programs=(
"shntool-3.0.5/sparrow-out/taint"
"latex2rtf-2.1.1/sparrow-out/taint"
"urjtag-0.8/sparrow-out/taint"
"optipng-0.5.3/sparrow-out/taint"
"wget-1.12/sparrow-out/interval"
"grep-2.19/sparrow-out/interval"
"readelf-2.24/sparrow-out/interval"
"sed-4.3/sparrow-out/interval"
"sort-7.2/sparrow-out/interval"
"tar-1.28/sparrow-out/interval"
)

echo "Old BNet"
for p in "${old_programs[@]}"; do
  clauses=$(grep "clauses" benchmark/$p/bnet/prune-cons.log | head -n 1 | cut -f 9 -d ' ')
  tuples=$(grep "tuples" benchmark/$p/bnet/prune-cons.log | head -n 1 | cut -f 9 -d ' ')
  opt_clauses=$(grep "clauses" benchmark/$p/bnet/cons_all2bnet.log | head -n 1 | cut -f 5 -d ' ')
  opt_tuples=$(grep "tuples" benchmark/$p/bnet/cons_all2bnet.log | head -n 1 | cut -f 5 -d ' ')
  printf "%15s %8s tuples %8s clauses | %8s tuples (opt) %8s clauses (opt) %8s sec\n" \
    ${p%%/*} $tuples $clauses $opt_tuples $opt_clauses $o$avg
done

echo "New BNet"
for p in "${new_programs[@]}"; do
  clauses=$(grep "clauses" benchmark/$p/bnet/prune-cons.log | head -n 1 | cut -f 9 -d ' ')
  tuples=$(grep "tuples" benchmark/$p/bnet/prune-cons.log | head -n 1 | cut -f 9 -d ' ')
  opt_clauses=$(grep "clauses" benchmark/$p/bnet/cons_all2bnet.log | head -n 1 | cut -f 5 -d ' ')
  opt_tuples=$(grep "tuples" benchmark/$p/bnet/cons_all2bnet.log | head -n 1 | cut -f 5 -d ' ')
  interactions=$(tail -n +2 benchmark/$p/bingo_stats.txt | wc -l | cut -f 1 -d ' ')
  time=$(tail -n +2 benchmark/$p/bingo_stats.txt | cut -f 9 | paste -sd+ | bc)
  avg=$(($time/$interactions))
  printf "%15s %8s tuples %8s clauses | %8s tuples (opt) %8s clauses (opt) %8s sec\n" \
    ${p%%/*} $tuples $clauses $opt_tuples $opt_clauses $o$avg
done

echo "Merged BNet"
for p in "${new_programs[@]}"; do
  clauses=$(grep "clauses" benchmark/$p/merged_bnet_0.01/prune-cons.log | head -n 1 | cut -f 9 -d ' ')
  tuples=$(grep "tuples" benchmark/$p/merged_bnet_0.01/prune-cons.log | head -n 1 | cut -f 9 -d ' ')
  opt_clauses=$(grep "clauses" benchmark/$p/merged_bnet_0.01/cons_all2bnet.log | head -n 1 | cut -f 5 -d ' ')
  opt_tuples=$(grep "tuples" benchmark/$p/merged_bnet_0.01/cons_all2bnet.log | head -n 1 | cut -f 5 -d ' ')
  interactions=$(tail -n +2 benchmark/$p/bingo_delta_sem-eps_strong_0.001_stats.txt | wc -l | cut -f 1 -d ' ')
  time=$(tail -n +2 benchmark/$p/bingo_delta_sem-eps_strong_0.001_stats.txt | cut -f 9 | paste -sd+ | bc)
  avg=$(($time/$interactions))
  printf "%15s %8s tuples %8s clauses | %8s tuples (opt) %8s clauses (opt) %8s sec\n" \
    ${p%%/*} $tuples $clauses $opt_tuples $opt_clauses $o$avg
done
