# BayeSmith: Learning Probabilistic Models for Static Analysis Alarms (Paper Artifact)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5890313.svg)](https://doi.org/10.5281/zenodo.5890313)

This is the artifact of the paper *Learning Probabilistic Models for Static Analysis Alarms* to appear in ICSE 2022.

## 1. Getting started
### System requirements
To run the experiments in the paper, we used a 64-core (Intel Xeon Processor Gold 6226R, 2.90 GHz) machine
with 128 GB of RAM and Ubuntu 20.04. We recommend running the experiments with at least 10-core machine with 32 GB of RAM.

### Loading Docker image
We provide the artifact as a Docker image. To launch the BayeSmith Docker image, run the following commands:
```
docker load < bayesmith.tar.gz
docker run -it bayesmith
```
It takes about 10 minutes to load the image.

### Notice
Most of the experiments take a long time. For convenience, all the data obtained from the instructions below are already shipped
in the Docker image. Also, we report the approximated running time of each instruction.

---
## 2. Directory structure
```
├─ README.md                         <- The top-level README (this file)
│
├─ datalog                           <- Learned Datalog rules
│  ├─ BufferOverflow.dl              <- The initial rule used for
|  |                                    the interval analysis
|  |
│  ├─ IntegerOverflow.dl             <- The initial rule used for
|  |                                    the taint analysis
|  |
│  ├─ BufferOverflow.<PROGRAM>.dl    <- The learned rules for the
|  |                                    interval analysis of <PROGRAM>
│  │                                     
│  ├─ IntegerOverflow.<PROGRAM>.dl   <- The learned rules for the 
|  |                                    taint analysis of <PROGRAM>
│  │                                     
│  ├─ TBufferOverflow.<PROGRAM>.dl   <- The modified versions of learned 
|  |                                    rules for the interval analysis
│  │                                    in a way that considers feedback
│  │                                    from dynamic analysis (FSE 2021)
|  |
│  └─ TIntegerOverflow.<PROGRAM>.dl  <- The modified versions of learned
|                                       rules for the taint analysis
|                                       in a way that considers feedback 
|                                       from dynamic analysis (FSE 2021)
│
├─ rank-plots                        
│  └─ <PROGRAM>.pdf                  <- Plots showing the ranking
|                                       performance for <PROGRAM>
|                                       (Figure 6)
│
├─ bayesmith                         <- Main implementation
│  ├─ sparrow                        <- The Sparrow static analyzer
│  │
│  ├─ bin                           
│  │   └─ run.py                     <- Script for running Sparrow and
|  |                                    Bingo
│  │
│  ├─ bingo                          <- Modules for learning and alarm
|  |                                    ranking algorithms
│  │
│  └─ benchmarks                     <- Benchmark programs
│     └─ <PROGRAM>/<VERSION>
│        ├─ sparrow/<PROGRAM>.c      <- Preprocessed program
│        └─ label.json               <- Bug label of the program
│ 
├─ dynaboost                         <- Implementation for Dynaboost
|                                       adapted from FSE 2021
└─ drake                             <- Implementation for Drake adapted
                                        from PLDI 2019
```
---
## 3. Preliminaries (column Alarm and Bingo_M in Table 2)
BayeSmith is based on static analysis results. The following command runs our static analyzer, Sparrow
on a benchmark program. Internally, when the analysis is done, it runs the baseline probabilistic model, Bingo:

```sh
cd ~/bayesmith
# run Sparrow (static analyzer) for one benchmark
bin/run.py analyze benchmarks/<PROGRAM>/<VERSION>
# run Bingo (probabilistic model) for one benchmark
bin/run.py rank benchmarks/<PROGRAM>/<VERSION>
# run both Sparrow and Bingo for all benchmarks
script/bingo/run-all.sh
```
For example, `bin/run.py analyze benchmarks/sort/7.2` and `bin/run.py rank benchmarks/sort/7.2` run Sparrow and Bingo
for `sort`, version `7.2`, respectively. In the case of `sort`, it takes about an hour to finish. Running all benchmarks
takes 3-4 hours to finish.

Then, run the following command to check the Bingo results (column Bingo_M, Table 2):
```
script/bingo/report.sh baseline
```
The last column reports the number of interactions.

---
## 4. Reproducing the main results (column BayeSmith in Table 2 and Table 5)
### Learning Bayesian networks
The following command runs BayeSmith for a certain type of analysis (`interval` or `taint`) and a program.
```
bingo/learn -reuse -analysis_type [ interval | taint ] <PROGRAM>
```
For example, `bingo/learn -reuse -analysis_type interval sort` launches a learning task for the interval
analysis for `sort` (i.e., all the other benchmark programs are used for training).

The learned Datalog rule (`rule-final.dl` file) with the above command will be generated under `learn-out/sort`.
In the case of `sort`, it takes about 6 hours to finish. In the worst case, it takes about 12 hours.

The shipped Datalog rules for pre-learned models are located in the following paths:
- Interval analysis: `~/datalog/BufferOverflow.<PROGRAM>.dl`
- Taint analysis: `~/datalog/IntegerOverflow.<PROGRAM>.dl`

### Running Bingo with the learned Bayesian networks
The following command runs Bingo with the learned rules.
```
bingo/learn -test -timestamp final -analysis_type [ interval | taint ] -dl_from <DL_FILE> <PROGRAM>
```
For example, one can run Bingo for `sort` with the learned rule with the following command.
```sh
# run Bingo with the set of rules generated by oneself 
bingo/learn -test -timestamp final -analysis_type interval -dl_from learn-out/sort/rule-final.dl sort
# run Bingo with the pre-learned set of rules
bingo/learn -test -timestamp final -analysis_type interval -dl_from ~/datalog/BufferOverflow.sort.dl sort
```
The number of interactions will be printed in `stdout` and the log file (`test-out/sort/test.log`).
In the case of `sort`, it takes about 30 min. to finish. In the worst case, it takes at most an hour to complete.

### Summarizing the results
The following command shows the performance of learned models (column BayeSmith in Table 2).
```
script/bingo/report.sh final
```
The last column reports the number of interactions.

The following command generates plots comparing the ranking performance of Bingo and BayeSmith in `script/rank-history-plot/images-final`.
```sh
script/rank-history-plot/plot-all.sh baseline final
```

The following command compares the size of Bayesian networks before and after the learning.
```sh
script/bnet/size.sh
```
It generates `bnet-size.csv` as the numbers reported in Table 5.
---
## 5. Reproducing the Bingo baselines (column Bingo_EM and Bingo_U in Table 2)
### Running Bingo_EM

  The following command runs an EM algorithm to find optimal weights with the fixed set of rules.
  We set a timeout of 12 hours for convergence.
  When the training is done, it runs the test with the trained model.
  ```sh
  # run EM algorithm and test for one benchmark
  script/bingo/run-em.sh [ interval | taint ] <PROGRAM>
  # run EM algorithm and test for all benchmarks
  script/bingo/run-em-all.sh
  ```
  For example, `script/bingo/run-em.sh interval sort` trains a model using EM algorithm for the interval
  analysis for `sort` (i.e., all the other benchmark programs are used for training).
  Then, the trained model is tested, and the result can be found in `benchmarks/sort/7.2/sparrow-out/interval/bingo_stats-em.txt`.
  The number of interactions is `#(lines of the result file) - 1`.
  In the case of `sort`, it takes 12 hours to finish.
  Running all benchmarks takes about 13 hours to complete.

  The following command shows the performance of weight-learned models while preserving the structures (column Bingo_EM, Table 2).
  ```
  script/bingo/report.sh em
  ```
  Note that we repeated five times for each program and reported the average in the paper.
  The numbers may differ from those reported in the paper because of the randomness in initial weights.

### Running Bingo_U
  The following command runs Bingo using a pre-refined set of rules that are derived by uniformly unrolling all the components
  of the initial set of rules by once (Bingo_U).
  ```
  # run Bingo_U for one benchmark
  script/bingo/run-unroll.sh [ interval | taint ] <PROGRAM>
  # run Bingo_U for all benchmarks
  script/bingo/run-unroll-all.sh
  ```
  For example, `script/bingo/run-unroll.sh interval sort` runs Bingo for interval analysis for `sort`
  with the uniformly refined set of rules.
  The result can be found in `benchmarks/sort/7.2/sparrow-out/interval/bingo_stats-unroll.txt`.
  The number of interactions is `#(lines of the result file) - 1`.
  In the case of `sort`, it takes about 30 min. to finish.
  Running all benchmarks takes about 2 hours to complete.

  The shipped Datalog rules for pre-refined models are located in the following paths:
  - Interval analysis: `~/bayesmith/datalog/BufferOverflow.unroll.dl`
  - Taint analysis: `~/bayesmith/datalog/IntegerOverflow.unroll.dl`

  The following command shows the performance of uniformly refined models while preserving the weights (column Bingo_U, Table 2).
  ```
  script/bingo/report.sh unroll
  ```
---
## 6. Reproducing the results with Drake and DynaBoost (Figure 5)
### Running Drake 

  To run Drake only, run the following commands:
  ```
  cd ~/drake
  . setenv
  ./run_all.sh
  ./delta_all.sh sound 0.001
  ```
  It takes about 12 hours to finish.

  To run Drake with learned models by BayeSmith, run the following commands:
  ```
  ./run_all.sh --bayesmith
  ./delta_all.sh sound 0.001 --bayesmith
  ```
  It takes about 6 hours to finish.

  TODO: add for signle benchmark

### Running DynaBoost

  To run DynaBoost only, run the following commands:
  ```
  cd ~/dynaboost
  source init.sh
  cd ~/bingo-ci-experiment
  ./run_all.sh
  cd ~/dynaboost/eval
  ./instrument-all.sh
  ./run-all.sh
  ```
  It takes about 18 hours to finish.

  To run DynaBoost with learned models by BayeSmith, run the following commands:
  ```
  cd ~/bingo-ci-experiment
  ./run_all.sh --bayesmith
  cd ~/dynaboost/eval
  ./run-all.sh --bayesmith
  ```
  It takes about 12 hours to finish.

  TODO: add for signle benchmark

  The following command generates `drake-bayesmith.pdf` and `dynaboost-bayesmith.pdf`, showing the effectiveness of BayeSmith in each application (Figure 5).
  ```sh
  cd ~/bayesmith
  script/comparison-plot/bar-plot.py
  ```
---
## 7. Comparing the magnitude of false generalizations (Table 3)
The following command compares the number of observed false generalizations and their average magnitude before and after the learning.
```
cd ~/bayesmith
script/bnet/fg.sh
```
It generates `bnet-fg.csv` as the numbers reported in Table 3.

---
## 8. Learning with different training sets (Table 4)

One can run BayeSmith (i.e., train a probabilistic model) with leave-N-out settings by specifying N programs.
The set of N programs becomes the test set, and the rest is the training set.
In Table 4, `BayeSmith_80` uses about 80% of the benchmarks as training data, i.e., N = 2.
We repeated ten times per analysis to report the numbers in `BayeSmith_80` column.
Those combinations tried by us can be found in `bayesmith-80-combi.txt`.
The following command runs BayeSmith with the specified training sets.

```
cd ~/bayesmith
script/bingo/diff-train.sh bayesmith-80-combi.txt
```
It takes about 12 hours to finish.

The following command compares the statistics (average and standard deviation) of the number of user interactions between the cases of
90% and 80% of benchmark programs are used as training sets.
```
cd ~/bayesmith
script/bnet/table-diff-train.py
```
It generates `diff-train.csv`, as the numbers reported in Table 4.

Moreover, the following command runs BayeSmith with the variant of the training sets.

```
bingo/learn -reuse -analysis_type [ interval | taint ] <PROGRAM_1> .. <PROGRAM_N>
```
For example, `bingo/learn -reuse -analysis_type interval sort grep` launches a learning task for the interval
analysis for `sort` and `grep` (i.e., all the other benchmark programs are used for training).

The learned Datalog rule (`rule-final.dl` file) with the above command will be generated under `learn-out/sort-grep`.
In the case of `sort` and `grep`, it takes about 2 hours to finish.
In the worst case, it takes about 4 hours to complete.
