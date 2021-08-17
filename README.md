# BayeSmith-artifact

## 1. Directory Structure
#### `datalog` - Learned rules (Datalog)
- `BufferOverflow.dl`, `IntegerOverflow.dl`: **initial** rules used for the interval analysis and taint analysis, respectively.
- `BufferOverflow.<PROGRAM>.dl`, `IntegerOverflow.<PROGRAM>.dl`: **learned** rules for `<PROGRAM>`, which is one of the benchmarks.
- `TBufferOverflow.<PROGRAM>.dl`, `TIntegerOverflow.<PROGRAM>.dl`: **modified** version of learned rules(*2*) in a way that considering feedback from dynamic instrumentation (FSE 2021).

#### `rank-plots` - Rank plots
Each file named `<PROGRAM>.pdf` is the plot showing the ranking performance for `<PROGRAM>` (Figure 6).
The plots represent the ranks of true alarms (*Y*) changing over user interactions (*X*).

#### `bayesmith` - Main implementations
The implementaion for Bayesian struture learning algorithm together with the modified version of Bayesian alarm ranking system are here.
- `src`: Main program for learning algorithm (e.g. `learn.ml`, `bNet.ml`, `datalog.ml`)

#### `bayesmith/bin` - Main scripts
- `run.py`: Analyze (Sparrow) and rank (Bingo) a program
- `plot.sh`: Plot rank changes comparison between before and after the learning procedure for benchmarks (Figure 6)

#### `bayesmith/benchmarks` - Benchmarks
Programs used for evaluation can be found here.
- `<PROGRAM>/<VERSION>/sparrow/*.c`: Program source code
- `<PROGRAM>/<VERSION>/label.json`: Bug label for the program

#### `dynaboost` - Implementation for DynaBoost (FSE 2021)

#### `drake` - Implementation for Drake (PLDI 2019)

#### `bayesmith/script` - Debug scripts

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
cd ~/bayesmith
# Run static analysis (using Sparrow)
script/pldi19/run-all.sh
bingo/learn -reuse -analysis_type [ interval | taint ] $BENCH_NAME
```

e.g. `bingo/learn -reuse -analysis_type interval sort`

Logs (`learn.log`) and output (`.dl` file) will be generated under `learn-out`.

One may run learning with the following options:
- `-debug` runs on debug mode. It produces verbose logs and takes more time.
- `-out_dir $DIRNAME` changes the name of the output directory (default: `learn-out`).

#### Running Bingo with the learned Bayesian network

```sh
bingo/learn -test -analysis_type [ interval | taint ] -out_dir test-out $BENCH_NAME
```

e.g. `bingo/learn -test -analysis_type interval -out_dir test-out -dl_from $PATH_TO_DL_FILE sort`

Logs (`learn.log`) and output (`.dl` file) will be generated under `test-out` directory (by default).

One may run test with the following options:
- `-dl_from $DATALOG_FILE` runs test with the specified datalog rule file.
- `-rule_prob_from $RULE_PROB_TXT_FILE` runs test with custom rule weights.
- `-out_dir $DIRNAME` changes the name of the output directory (default: `test-out`).
- `-timestamp $TS` gives a custom timestamp (default: current time). This is useful for drawing ranking plots.

#### Plots

```sh
$ cd bayesmith
$ ./script/plot.sh <BINGO_TIMESTAMP> <BAYESMITH_TIMESTAMP> -p   # Figure 6
$ ./bar-plot.sh   # Figure 5
```
