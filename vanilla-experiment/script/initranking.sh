#!/bin/bash
echo "Semantic Masking"
for d in `find . -name "bingo_delta_sem-eps_strong_0.001_combined"`; do
  echo $d
  grep "TrueGround" $d/0.out | tail -n 1
done

echo "Syntactic Masking"
for d in `find . -name "bingo_delta_syn_strong_combined"`; do
  echo $d
  grep "TrueGround" $d/0.out | tail -n 1
done
