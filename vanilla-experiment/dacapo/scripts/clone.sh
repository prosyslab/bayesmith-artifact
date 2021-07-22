#!/usr/bin/env bash

# Requires: git, hg (Mercurial), svn, cvs, wget

# Intended to be run from the bingo-ci-experiment/dacapo/ folder:
# git clone https://github.com/petablox-project/bingo-ci-experiment.git
# cd ./bingo-ci-experiment/dacapo
# ./scripts/clone.sh [update] [clean]

if [[ "$@" =~ "clean" ]]; then
  rm -rf jdk dacapobench
  exit 0
fi

for cmd in wget git hg svn cvs; do
  if ! [ -x "$(command -v $cmd)" ]; then
    echo "Error: $cmd is not installed." >&2
    exit 1
  fi
done

if [[ ! "$@" =~ "update" ]]; then
  if [ ! -d "jdk" ]; then
    mkdir -p jdk
  fi

  pushd jdk
    if [ ! -d "jdk1.7.0_80" ]; then
      wget -c http://www.cis.upenn.edu/~rmukund/delta/resources/jdk-7u80-linux-x64.tar.gz
      tar -xf jdk-7u80-linux-x64.tar.gz
    fi

    if [ ! -d "apache-ant-1.10.5" ]; then
      wget -c http://archive.apache.org/dist/ant/binaries/apache-ant-1.10.5-bin.tar.gz
      tar -xf apache-ant-1.10.5-bin.tar.gz
    fi
  popd
fi

source scripts/setpaths.sh

if ! git clone https://github.com/dacapobench/dacapobench.git; then
  echo "Error cloning Dacapobench!"
  exit 1
fi
pushd dacapobench

find ./benchmarks/libs/daytrader -name '*.MD5' -exec rm {} \;
cat <<EOF > $BASE_DIR/dacapobench/benchmarks/local.properties
build.failonerror=false
jdk7home=$JAVA7_HOME
EOF

popd
