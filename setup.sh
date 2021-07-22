#!/usr/bin/env bash

# Update bingo script
cp -r ~/update-scripts/bingo/* ~/bingo-ci-experiment/bingo/
cp ~/update-scripts/bingo/derive-edb.py ~/bingo/scripts/bnet/
cp -r ~/update-scripts/bingo/* ~/drake/bingo/

# Update run.sh
cp ~/update-scripts/new-run.sh ~/bingo-ci-experiment/run.sh
cp ~/update-scripts/new-run.sh ~/drake/run.sh

# Update build script in Drake
cp ~/update-scripts/drake-build.sh ~/drake/build.sh
