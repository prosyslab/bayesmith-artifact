# BayeSmith-artifact

## 1. Directory structure
### a. `datalog` - Learned Datalog rules
- `BufferOverflow.dl`, `IntegerOverflow.dl`: **initial** rules used for the interval analysis and taint analysis, respectively.
- `BufferOverflow.<PROGRAM>.dl`, `IntegerOverflow.<PROGRAM>.dl`: **learned** rules for `<PROGRAM>`, which is one of the benchmarks.
- `TBufferOverflow.<PROGRAM>.dl`, `TIntegerOverflow.<PROGRAM>.dl`: **modified** version of learned rules(*2*) in a way that considers feedback from dynamic instrumentation (FSE 2021).

### b. `rank-plots` - Rank plots
Each file named `<PROGRAM>.pdf` is a plot showing the ranking performance for `<PROGRAM>` (Figure 6).
The plots represent the ranks of true alarms (*Y*) changing over user interactions (*X*).

### c. `bayesmith` - Main implementations
The implementation of Bayesian structure learning algorithm together and the modified version of Bayesian alarm ranking system are here.
- `sparrow`: Sparrow static analyzer
- `bingo/src`: Main program for learning algorithm (e.g. `learn.ml`, `bNet.ml`, `datalog.ml`)

### d. `bayesmith/bin` - Main scripts
- `run.py`: Analyze (Sparrow) and run Bingo for input program
- `plot.sh`: Plot rank changes comparison between before and after the learning procedure for benchmarks (Figure 6)

### e. `bayesmith/benchmarks` - Benchmarks
Programs used for evaluation can be found here.
- `<PROGRAM>/<VERSION>/sparrow/*.c`: Program source code
- `<PROGRAM>/<VERSION>/label.json`: Bug label for the program

### f. `dynaboost` - Implementation for DynaBoost adapted from FSE 2021

### g. `drake` - Implementation for Drake adapted from PLDI 2019

### h. `bayesmith/script` - Debug scripts

## 2. Reproducing the results
### a. System requirements

To run the experiments that were reported in the paper, we used a 64-core (Intel Xeon Processor Gold 6226R, 2.90 Ghz) machine with 128 GB of RAM with the 20.04 version of Ubuntu Linux. We recommend to run the experiments with at least 10-core machine with 32 GB of RAM.

### b. Loading docker image
**(TODO: Add descriptions for where/how to downlaod tar.gz file)** To launch a BayeSmith docker container, run the following commands:
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

Then, run the following command to check the Bingo results (column Bingo_M, Table 2):
```sh
script/bingo/report.sh baseline
```
The last column reports the number of interactions.

### d. Learning Bayesian networks
```sh
bingo/learn -reuse -analysis_type [ interval | taint ] <PROGRAM>
```
e.g. `bingo/learn -reuse -analysis_type interval sort`

The learned datalog rule (`rule-final.dl` file) will be generated under `learn-out/sort`.

### e. Running Bingo with the learned Bayesian networks
```sh
bingo/learn -test -timestamp final -analysis_type [ interval | taint ] -dl_from <DL_FILE> <PROGRAM>
```
e.g. `bingo/learn -test -timestamp final -analysis_type interval -dl_from learn-out/sort/rule-final.dl sort`

The number of interactions will be printed in stdout and logged in a file (`test.log`) under `test-out/sort`.
To run with the learned Bayesian networks reported in the paper, set `-dl_from` option as the following:
- Interval analysis: `-dl_from ~/datalog/BufferOverflow.<PROGRAM>.dl`
- Taint analysis: `-dl_from ~/datalog/IntegerOverflow.<PROGRAM>.dl`

Then, run the following command to check the results of learned models (column BayeSmith, Table 2):
```sh
script/bingo/report.sh final
```
The last column reports the number of interactions.

### f. Running other baselines (Table 2)
- Bingo_EM

  It runs EM algorithm to find optimal weights while prserving the rules.
  We set timeout of 12 hours for convergence.
  ```sh
  script/bingo/run-em.sh [ interval | taint ] <PROGRAM>
  ```
  e.g. `script/bingo/run-em.sh interval sort`

  The result can be found in `benchmarks/sort/7.2/sparrow-out/interval/bingo_stats-em.txt`.
  The number of interactions is `#(lines of the result file) - 1`.

  To run over entire benchmarks, user can run the following command:
  ```sh
  script/bingo/run-em-all.sh
  ```

  Run the following command to check the overall results of weight learning (column Bingo_EM, Table 2):
  ```sh
  script/bingo/report.sh em
  ```
  Note that we repeated five times for each program and reported the average in the paper.
  The numbers may differ from the paper because of the randomness in initial weights.

- Bingo_U

  It uses pre-refined rules that are derived by uniformly unrolling all the components of the initial rules by once.
  The rules are `BufferOverflow.unroll.dl` (interval) and `IntegerOverflow.unroll.dl` (taint) in `~/bayesmith/datalog`.
  ```sh
  script/bingo/run-unroll.sh [ interval | taint ] <PROGRAM>
  ```
  e.g. `script/bingo/run-unroll.sh interval sort`

  The result can be found in `benchmarks/sort/7.2/sparrow-out/interval/bingo_stats-unroll.txt`.
  The number of interactions is `#(lines of the result file) - 1`.

  To run over entire benchmarks, user can run the following command:
  ```sh
  script/bingo/run-unroll-all.sh
  ```

  Run the following command to check the overall results of uniformly refined models (column Bingo_U, Table 2):
  ```sh
  script/bingo/report.sh unroll
  ```

### g. Running Drake and DynaBoost
- Drake

  To run Drake only, run the following commands:
  ```sh
  cd ~/drake
  . setenv
  ./run_all.sh
  ./delta_all.sh sound 0.001
  ```

  To run Drake with learned models by BayeSmith, run the following commands:
  ```sh
  ./run_all.sh --bayesmith
  ./delta_all.sh sound 0.001 --bayesmith
  ```

- DynaBoost

  To run DynaBoost only, run the following commands:
  ```sh
  cd ~/dynaboost
  source init.sh
  cd ~/bingo-ci-experiment
  ./run_all.sh
  cd ~/dynaboost/eval
  ./instrument-all.sh
  ./run-all.sh
  ```

  To run DynaBoost with learned models by BayeSmith, run the following commands:
  ```sh
  cd ~/bingo-ci-experiment
  ./run_all.sh --bayesmith
  cd ~/dynaboost/eval
  ./run-all.sh --bayesmith
  ```

The comparison results for each application can be obtained as bar plots (Figure 5).
To obtain the plots, see [section k](#k-plots).

### h. Learning with different training set (Table 4)
```sh
bingo/learn -reuse -analysis_type [ interval | taint ] <PROGRAM_1> .. <PROGRAM_N>
```
e.g. `bingo/learn -reuse -analysis_type interval sort grep`

The learned rule, `rule-final.dl` will be generated under `learn-out/sort-grep`.

One can run BayeSmith with leave-N-out settings by specifing N programs.
`BayeSmith_80` uses about 80% of benchmarks as training data, i.e. N = 2.
We repeated ten times per analysis to report the numbers in `BayeSmith_80` column, Table 4.
Those combinations tried by us can be found in `bayesmith-80-combi.txt`.

### i. Comparing magnitude of false generalizations (Table 3)
```sh
script/bnet/fg.sh
```
It generates `bnet-fg.csv` showing the negative impact of false generalizations before and after the learning.

### j. Comparing sizes of Bayesian networks (Table 5)
```sh
script/bnet/size.sh
```
It generates `bnet-size.csv` showing the size of Bayesian networks before and after the learning.

### k. Plots
- Bar plots (Figure 5)
  ```sh
  script/comparison-plot/bar-plot.py
  ```
  It generates `drake-bayesmith.pdf` and `dynaboost-bayesmith.pdf` showing the effectiveness of BayeSmith in each application.

- Rank plots (Figure 6)
  ```sh
  script/rank-history-plot/plot-all.sh baseline final
  ```
  It generates plots comparing ranking performance of Bingo and BayeSmith in `script/rank-history-plot/images-final`.
