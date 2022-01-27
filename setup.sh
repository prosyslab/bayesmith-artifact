#!/usr/bin/env bash

# Update bingo script
cp -r ~/update-scripts/bingo/* ~/bingo-ci-experiment/bingo/
rm ~/bingo-ci-experiment/bingo/src/generator.drake.ml
mv ~/bingo-ci-experiment/bingo/src/generator.dynaboost.ml ~/bingo-ci-experiment/bingo/src/generator.ml
pushd ~/bingo-ci-experiment/bingo
eval $(opam env) && make -j
popd
cp ~/update-scripts/bingo/derive-edb.py ~/bingo/scripts/bnet/
cp -r ~/update-scripts/bingo/* ~/drake/bingo/
rm ~/drake/bingo/src/generator.dynaboost.ml
mv ~/drake/bingo/src/generator.drake.ml ~/drake/bingo/src/generator.ml

# Update run.sh
cp ~/update-scripts/new-run.sh ~/bingo-ci-experiment/run.sh
cp ~/update-scripts/new-run.sh ~/drake/run.sh

# Update run_all.sh
cp ~/update-scripts/dynaboost-run_all.sh ~/bingo-ci-experiment/run_all.sh
cp ~/update-scripts/dynaboost-run_single.sh ~/bingo-ci-experiment/run_single.sh
cp ~/update-scripts/dynaboost-runsinglebingo.sh ~/dynaboost/utils/runsinglebingo.sh
cp ~/update-scripts/dynaboost-run-single.sh ~/dynaboost/eval/run-single.sh

cp ~/update-scripts/drake-run_all.sh ~/drake/run_all.sh
cp ~/update-scripts/drake-run_single.sh ~/drake/run_single.sh

# Copy learned rules
cp ~/datalog/TBufferOverflow.*.dl ~/datalog/TIntegerOverflow.*.dl ~/bingo-ci-experiment/datalog
cp ~/datalog/BufferOverflow.*.dl ~/datalog/IntegerOverflow.*.dl ~/drake/datalog

# Update build script in Drake
cp ~/update-scripts/delta.sh ~/drake/delta.sh
cp ~/update-scripts/delta_single.sh ~/drake/delta_single.sh
cp ~/update-scripts/delta_all.sh ~/drake/delta_all.sh
cp ~/update-scripts/delta/sem-eps.sh ~/drake/delta/sem-eps.sh
cp ~/update-scripts/drake-build.sh ~/drake/build.sh
