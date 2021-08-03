# bingo-ci-experiment

## Requirements
- [OPAM](http://opam.ocaml.org) (to build Sparrow)
- [Sparrow](https://github.com/KihongHeo/sparrow)
```
$ git clone git@github.com:KihongHeo/sparrow.git
$ cd sparrow
$ git checkout datalog
$ ./build.sh
```
- [Souffle](http://souffle-lang.org)
- [Nichrome](https://github.com/nichrome-project/nichrome) (to run Bingo)
```
$ git clone --recurse-submodules git@github.com:nichrome-project/nichrome.git
$ cd nichrome/main; ant
$ cd libsrc; make
$ cd ../..
$ export NICHROME_HOME=`pwd`
```

## Example
### Setup the repository
```
$ git clone git@github.com:petablox-project/bingo-ci-experiment.git
$ cd bingo-ci-experiment
$ cd bingo/prune-cons && make
$ cd ../../
```
### Run batch-mode Bingo with Sparrow
```
$ ./run.sh benchmark/optipng-0.5.2/optipng-0.5.2.c
$ ./run.sh benchmark/optipng-0.5.3/optipng-0.5.3.c
# all the output will be in "benchmark/[program]/sparrow-out/"
```
### Run CI-mode Bingo with Sparrow
```
# Once you have the batch results for version n and n+1
$ ./delta.sh benchmark/optipng-0.5.2/ benchmark/optipng-0.5.3/ syn   # syntactic alarm screening
$ ./delta.sh benchmark/optipng-0.5.2/ benchmark/optipng-0.5.3/ sem   # semantic alarm screening
```
