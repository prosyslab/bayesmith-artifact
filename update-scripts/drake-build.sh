#!/bin/bash

set -e

echo "Build Nichrome"
git clone --recurse-submodules https://github.com/nichrome-project/nichrome.git
pushd nichrome/main
ant
pushd libsrc
cp libdai/Makefile.LINUX libdai/Makefile.conf
make -j
popd
popd

echo "Build Bingo"
pushd bingo
opam install -y linenoise
eval $(opam env) && make -j
popd
pushd bingo/prune-cons
make -j
popd
