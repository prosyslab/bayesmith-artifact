# BayeSmith-artifact

## 1. Directory Structure
### a. `datalog` - Learned Datalog rules
- `BufferOverflow.dl`, `IntegerOverflow.dl`: **initial** rules used for the interval analysis and taint analysis, respectively.
- `BufferOverflow.<PROGRAM>.dl`, `IntegerOverflow.<PROGRAM>.dl`: **learned** rules for `<PROGRAM>`, which is one of the benchmarks.
- `TBufferOverflow.<PROGRAM>.dl`, `TIntegerOverflow.<PROGRAM>.dl`: **modified** version of learned rules(*2*) in a way that considers feedback from dynamic instrumentation (FSE 2021).

### b. `rank-plots` - Rank plots
Each file named `<PROGRAM>.pdf` is a plot showing the ranking performance for `<PROGRAM>` (Figure 6).
The plots represent the ranks of true alarms (*Y*) changing over user interactions (*X*).

### c. `bayesmith` - Main implementations
The implementation of Bayesian structure learning algorithm together with the modified version of Bayesian alarm ranking system are here.
- `src`: Main program for learning algorithm (e.g. `learn.ml`, `bNet.ml`, `datalog.ml`)

### d. `bayesmith/bin` - Main scripts
- `run.py`: Analyze (Sparrow) and rank (Bingo) a program
- `plot.sh`: Plot rank changes comparison between before and after the learning procedure for benchmarks (Figure 6)

### e. `bayesmith/benchmarks` - Benchmarks
Programs used for evaluation can be found here.
- `<PROGRAM>/<VERSION>/sparrow/*.c`: Program source code
- `<PROGRAM>/<VERSION>/label.json`: Bug label for the program

### f. `dynaboost` - Implementation for DynaBoost adapted from FSE 2021

### g. `drake` - Implementation for Drake adapted from PLDI 2019

### h. `bayesmith/script` - Debug scripts

## 2. Reproducing the results
### a. System Requirements

To run the experiments that were reported in the paper, we used a 64-core (Intel Xeon Processor Gold 6226R, 2.90 Ghz) machine with 128 GB of RAM with the 20.04 version of Ubuntu Linux. We recommend to run the experiments with at least 10-core machine with 32 GB of RAM.

### b. Building the docker image
To build and launch the BayeSmith docker container, run the following commands:
```sh
docker load < bayesmith.tar.gz
docker run -it bayesmith
```

### Running static analysis (optional)
```sh
cd bayesmith
script/pldi19/run-all.sh
```
BayeSmith runs with static analysis results.
It needs to be done only once for the entire benchmark
Note that the analysis results are already shipped, so this step is optional.
It roughly takes an hour to finish.

### Learning Bayesian networks
```sh
bingo/learn -reuse -analysis_type [ interval | taint ] <BENCH_NAME>
```
e.g. `bingo/learn -reuse -analysis_type interval sort`
The learned datalog rules (`.dl` file) will be generated under `learn-out`.

One may run the learning process with the following options:
- `-debug` runs on debug mode. It produces verbose logs and takes more time.
- `-out_dir <DIRNAME>` changes the name of the output directory (default: `learn-out`).

### Running Bingo with the learned Bayesian networks
```sh
bingo/learn -test -analysis_type [ interval | taint ] -out_dir test-out <BENCH_NAME>
```
e.g. `bingo/learn -test -analysis_type interval -out_dir test-out -dl_from ~/datalog/BufferOverflow.sort.dl sort`

Logs (`learn.log`) and output (`.dl` file) will be generated under `test-out` (by default).

One may run test with the following options:
- `-dl_from <DATALOG_FILE>` runs test with the specified datalog rule file.
- `-rule_prob_from <RULE_PROB_TXT_FILE>` runs test with custom rule weights.
- `-out_dir <DIRNAME>` changes the name of the output directory (default: `test-out`).
- `-timestamp <TS>` gives a custom timestamp (default: current time). This is useful for drawing ranking plots.

### Plots

```sh
$ cd bayesmith
$ ./script/plot.sh <BINGO_TIMESTAMP> <BAYESMITH_TIMESTAMP> -p   # Figure 6
$ ./bar-plot.sh   # Figure 5
```
