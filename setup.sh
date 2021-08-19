#!/usr/bin/env bash

# Update bingo script
cp -r ~/update-scripts/bingo/* ~/bingo-ci-experiment/bingo/
pushd ~/bingo-ci-experiment/bingo
eval $(opam env) && make -j
popd
cp ~/update-scripts/bingo/derive-edb.py ~/bingo/scripts/bnet/
cp -r ~/update-scripts/bingo/* ~/drake/bingo/
sed -i 's/TBufferOverflow/BufferOverflow/g' ~/drake/bingo/src/generator.ml
sed -i 's/TIntegerOverflow/IntegerOverflow/g' ~/drake/bingo/src/generator.ml

# Update run.sh
cp ~/update-scripts/new-run.sh ~/bingo-ci-experiment/run.sh
cp ~/update-scripts/new-run.sh ~/drake/run.sh

# Update run_all.sh
cp ~/update-scripts/dynaboost-run_all.sh ~/bingo-ci-experiment/run_all.sh
cp ~/update-scripts/drake-run_all.sh ~/drake/run_all.sh

# Copy learned rules
cp ~/datalog/TBufferOverflow.*.dl ~/datalog/TIntegerOverflow.*.dl ~/bingo-ci-experiment/datalog
cp ~/datalog/BufferOverflow.*.dl ~/datalog/IntegerOverflow.*.dl ~/drake/datalog

# Update build script in Drake
cp ~/update-scripts/drake-build.sh ~/drake/build.sh
