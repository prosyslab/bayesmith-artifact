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

### c. Running static analysis and baseline Bingo (optional)
```sh
cd bayesmith
script/bingo/run-all.sh
```
BayeSmith runs with static analysis results.
It needs to be done only once for the entire benchmark.
When the analysis is done, it runs Bingo based on the results.
Note that the analysis and baseline Bingo results are already shipped, so this step is optional.
It roughly takes an hour to finish.

Then, run the following command to check the Bingo results (Column Bingo_M, Table 2):
```sh
script/bingo/report.sh baseline
```

### d. Learning Bayesian networks
```sh
bingo/learn -reuse -analysis_type [ interval | taint ] <PROGRAM>
```
e.g. `bingo/learn -reuse -analysis_type interval sort`
The learned datalog rule (`rule-final.dl` file) will be generated under `learn-out/<PROGRAM>`.

### e. Running Bingo with the learned Bayesian networks
```sh
bingo/learn -test -analysis_type [ interval | taint ] -dl_from <DL_FILE> <PROGRAM>
```
e.g. `bingo/learn -test -analysis_type interval -dl_from learn-out/sort/rule-final.dl sort`

The number of iterations will be printed in stdout and logged in a file (`test.log`) under `test-out/<PROGRAM>`.

### f. Running other baselines (Table 2)
TODO

### g. Running Drake and DynaBoost
TODO

### h. Learning with different training set
TODO

### i. Comparing sizes of Bayesian neworks

### j. Comparing magnitude of false generalizations (FGs)
We compare the impact of FGs occurred between before and after the learning.

### k. Plots

```sh
cd bayesmith
./script/rank-history-plot/plot-all.sh baseline final -p   # Figure 6
./script/comparison-plot/bar-plot.py    # Figure 5
```
