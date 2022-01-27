# BayeSmith: Learning Probabilistic Models for Static Analysis Alarms (Paper Artifact)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5890313.svg)](https://doi.org/10.5281/zenodo.5890313)

A research artifact submitted to ICSE 2022.
The corresponding paper is *Learning Probabilistic Models for Static Analysis Alarms, H. Kim, M. Raghothaman, K. Heo*.

## 1. Getting started
### System requirements
To run the experiments that were reported in the paper, we used a 64-core (Intel Xeon Processor Gold 6226R, 2.90 Ghz) machine with 128 GB of RAM with the 20.04 version of Ubuntu Linux. We recommend to run the experiments with at least 10-core machine with 32 GB of RAM.

### Loading Docker image
To launch a BayeSmith Docker container, run the following commands:
```
docker load < bayesmith.tar.gz
docker run -it bayesmith
```
It takes about 10 minutes to load the image.

### Results shipped altogether
The data obtained from the commands below that run either learning or inference are shipped in the Docker image.
In each section, we report the duration for those commands together.

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
├─ drake                             <- Implementation for Drake adapted
|                                       from PLDI 2019
└─ script                            <- Scripts for debugging
```
---
## 3. Preliminaries (column Alarm and Bingo_M, Table 2)
### Running static analysis and baseline Bingo
```
cd bayesmith
script/bingo/run-all.sh
```
BayeSmith runs with static analysis results.
It needs to be done only once for the entire benchmark.
When the analysis is done, it runs Bingo based on the results.
Note that the analysis and baseline Bingo results are already shipped, so this step is optional.
It takes 3-4 hours to finish.

Then, run the following command to check the Bingo results (column Bingo_M, Table 2):
```
script/bingo/report.sh baseline
```
The last column reports the number of interactions.

---
## 4. Reproducing the main results (column BayeSmith, Table 2)
### Learning Bayesian networks
```
bingo/learn -reuse -analysis_type [ interval | taint ] <PROGRAM>
```
e.g. `bingo/learn -reuse -analysis_type interval sort`

The learned Datalog rule (`rule-final.dl` file) will be generated under `learn-out/sort`.
In the case of `sort`, it takes about 6 hours to finish.
In the worst case, it takes at most 12 hours to complete.

### Running Bingo with the learned Bayesian networks
```
bingo/learn -test -timestamp final -analysis_type [ interval | taint ] -dl_from <DL_FILE> <PROGRAM>
```
e.g. `bingo/learn -test -timestamp final -analysis_type interval -dl_from learn-out/sort/rule-final.dl sort`

The number of interactions will be printed in stdout and logged in a file (`test.log`) under `test-out/sort`.
To run with the learned Bayesian networks reported in the paper, set `-dl_from` option as the following:
- Interval analysis: `-dl_from ~/datalog/BufferOverflow.<PROGRAM>.dl`
- Taint analysis: `-dl_from ~/datalog/IntegerOverflow.<PROGRAM>.dl`
In the case of `sort`, it takes about 30 min. to finish.
In the worst case, it takes at most an hour to complete.

### Summarizing the results
The following command shows the performance of learned models (column BayeSmith, Table 2):
```
script/bingo/report.sh final
```
The last column reports the number of interactions.

The following command generates plots comparing the ranking performance of Bingo and BayeSmith in `script/rank-history-plot/images-final`.
```sh
script/rank-history-plot/plot-all.sh baseline final
```

The following generates `bnet-size.csv` showing the size of Bayesian networks before and after the learning (Table 5).
```sh
script/bnet/size.sh
```
---
## 5. Reproducing the Bingo baselines (column Bingo_EM and Bingo_U, Table 2)
### Running Bingo_EM

  It runs an EM algorithm to find optimal weights while preserving the rules.
  We set a timeout of 12 hours for convergence.
  ```
  script/bingo/run-em.sh [ interval | taint ] <PROGRAM>
  ```
  e.g. `script/bingo/run-em.sh interval sort`

  The result can be found in `benchmarks/sort/7.2/sparrow-out/interval/bingo_stats-em.txt`.
  The number of interactions is `#(lines of the result file) - 1`.
  In the case of interval analysis benchamrks (including `sort`), it reaches timeout to finish.
  In the case of taint analysis benchamrks, it takes less than 6 hours to finish.

  To run over entire benchmarks, user can run the following command:
  ```
  script/bingo/run-em-all.sh
  ```
  It takes 12 hours to complete.

  Run the following command to check the overall results of weight learning (column Bingo_EM, Table 2):
  ```
  script/bingo/report.sh em
  ```
  Note that we repeated five times for each program and reported the average in the paper.
  The numbers may differ from the paper because of the randomness in initial weights.

### Running Bingo_U
  It uses pre-refined rules that are derived by uniformly unrolling all the components of the initial rules by once.
  The rules are `BufferOverflow.unroll.dl` (interval) and `IntegerOverflow.unroll.dl` (taint) in `~/bayesmith/datalog`.
  ```
  script/bingo/run-unroll.sh [ interval | taint ] <PROGRAM>
  ```
  e.g. `script/bingo/run-unroll.sh interval sort`

  The result can be found in `benchmarks/sort/7.2/sparrow-out/interval/bingo_stats-unroll.txt`.
  The number of interactions is `#(lines of the result file) - 1`.
  In the case of `sort`, it takes about 30 min. to finish.
  In the worst case, it takes at most an hour to complete.

  To run over entire benchmarks, user can run the following command:
  ```
  script/bingo/run-unroll-all.sh
  ```
  It takes about 2 hours to complete.

  Run the following command to check the overall results of uniformly refined models (column Bingo_U, Table 2):
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

  The following command generates `drake-bayesmith.pdf` and `dynaboost-bayesmith.pdf` showing the effectiveness of BayeSmith in each application (Figure 5).
  ```sh
  cd ~/bayesmith
  script/comparison-plot/bar-plot.py
  ```
---
## 7. Comparing magnitude of false generalizations (Table 3)
```
script/bnet/fg.sh
```
It generates `bnet-fg.csv` showing the negative impact of false generalizations before and after the learning.

---
## 8. Learning with different training sets (Table 4)

One can run BayeSmith (i.e., train a probabilistic model) with leave-N-out settings by specifying N programs.
The set of N programs becomes the test set, and the rest is the training set.
In Table 4, `BayeSmith_80` uses about 80% of the benchmarks as training data, i.e. N = 2.
We repeated ten times per analysis to report the numbers in `BayeSmith_80` column.
Those combinations tried by us can be found in `bayesmith-80-combi.txt`.
The following command runs with the specified training sets and shows the table.

```
cd ~/bayesmith
script/bingo/diff-train.sh bayesmith-80-combi.txt
script/bnet/table-diff-train.sh
```
It takes about 12 hours to finish.

Moreover, here is the command to run with the variant of the training sets.

```
bingo/learn -reuse -analysis_type [ interval | taint ] <PROGRAM_1> .. <PROGRAM_N>
```
e.g. `bingo/learn -reuse -analysis_type interval sort grep`

The learned rule, `rule-final.dl` will be generated under `learn-out/sort-grep`.
In the case of `sort` and `grep`, it takes about 2 hours to finish.
In the worst case, it takes at most 4 hours to complete.
