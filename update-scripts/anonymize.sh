#!/usr/bin/env bash
  
targets=(
  "LICENSE"
  "STATUS"
  "INSTALL"
  "drake/.git"
  "drake/.gitmodules"
  "drake/nichrome/.git"
  "drake/nichrome/.gitmodules"
  "drake/LICENSE"
  "bingo/.git"
  "bingo/libdai/.git"
  "nichrome/.git"
  "nichrome/.gitmodules"
  "bayesmith/.git"
  "bayesmith/.gitmodules"
  "bayesmith/sparrow/.git"
  "bayesmith/sparrow/LICENSE"
  "bayesmith/souffle/.git"
  "bayesmith/libdai/.git"
  "bayesmith/bug-bench"
)

for p in ${targets[@]}; do
  if [[ $p != "" ]]; then
    echo $p
    rm -rf /home/ubuntu/$p
  else
    echo "WARN"
  fi
done
