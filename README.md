# BayeSmith-artifact

## 1. Directory Structure
#### `~/datalog` - Learned rules (Datalog)
1. `BufferOverflow.dl` and `IntegerOverflow.dl` are the **initial** rules used for the interval analysis and taint analysis, respectively.
2. `BufferOverflow.<PROGRAM>.dl` and `IntegerOverflow.<PROGRAM>.dl` are the **learned** rules for `<PROGRAM>`, which is one of the benchmarks.
3. `TBufferOverflow.<PROGRAM>.dl` and `TIntegerOverflow.<PROGRAM>.dl` are the **modified** version of learned rules(*2*) in a way that considering feedback from dynamic instrumentation (FSE 2021).

#### `~/rank-plots` - Rank plots
Each file named `<PROGRAM>.pdf` is the plot showing the ranking performance for `<PROGRAM>` (Figure 6).
The plots represent the ranks of true alarms (*Y*) changing over user interactions (*X*).

#### `~/bayesmith` - Main implementations
The implementaion for Bayesian struture learning algorithm together with the modified version of Bayesian alarm ranking system are here.
- `*/src`: Main program for learning algorithm (e.g. `learn.ml`, `bNet.ml`, `datalog.ml`)
- `*.py`, `*/prune-cons`: Bayesian alarm ranking system (Modified version of Bingo, PLDI 2018)

#### `~/bayesmith/bin` - Main scripts
- `run.py`: Analyze (Sparrow) and rank (Bingo) a program
- `plot.sh`: Plot rank changes comparison between before and after the learning procedure for benchmarks (Figure XX)

#### `~/bayesmith/benchmarks` - Benchmarks
Programs used for evaluation can be found here.
- `*/<PROGRAM>/<VERSION>/sparrow/*.c`: Program source code
- `*/<PROGRAM>/<VERSION>/label.json`: Bug label for the program

#### `~/dynaboost` - Implementation for DynaBoost (FSE 2021)

#### `~/drake` - Implementation for Drake (PLDI 2019)

#### `~/bayesmith/script` - Debug scripts

## 2. Reproducing the results
#### System Requirements

To run the experiments that were reported in the paper, we used a 64-core (Intel Xeon Processor Gold 6226R, 2.90 Ghz) machine with 128 GB of RAM with the 20.04 version of Ubuntu Linux. We recommend to run the experiments with at least 10-core machine with 32 GB of RAM.

#### Building the docker image
To build the BayeSmith docker image, run the following command:
```sh
docker build . -t bayesmith --shm-size 4G
```

To launch the docker container, run the following command:

```sh
docker run -it bayesmith
```

#### Learning Bayesian networks
```sh
$ cd ~/bayesmith
$ bingo/learn -reuse -analysis_type [ interval | taint ] -debug $BENCH_NAME
```

e.g. `bingo/learn -reuse -analysis_type interval -debug sort`

Logs (`learn.log`) and output (`.dl` file) will be generated under `learn-out`.
One may change the name of the output directory with option `-out_dir $DIRNAME`.

#### Running Bingo with the learned Bayesian network

```sh
$ bingo/learn -test -analysis_type [ interval | taint ] -out_dir test-out $BENCH_NAME
```

e.g. `bingo/learn -test -analysis_type interval -out_dir test-out -dl_from $PATH_TO_DL_FILE sort`

Logs (`learn.log`) and output (`.dl` file) will be generated under `test-out` directory (by default).
One may run test with existing datalog rule file with option `-dl_from $PATH_TO_DATALOG_FILE`.
One may run test with custom rule weights with option `-rule_prob_from $PATH_TO_RULE_PROB_TXT_FILE`.
One may change the name of the directory with option `-out_dir $DIRNAME`.
One may give a timestamp with optipn `-timestamp`.

#### Plots

```sh
$ cd bayesmith
$ ./script/plot.sh <BINGO_TIMESTAMP> <BAYESMITH_TIMESTAMP> -p   # Figure 6
$ ./bar-plot.sh   # Figure 5
```
