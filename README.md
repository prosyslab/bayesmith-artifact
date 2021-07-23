# BayeSmith-artifact

## Launch

To build BayeSmith docker image, run below command:

```sh
docker build . -t bayesmith --shm-size 4G
```

To launch the docker container, run below command:

```sh
docker run -it bayesmith
```

DockerFile itself manages to build `DynaBoost` and `Drake`.
For now, one should manually git-clone the [BayeSmith repository](https://github.com/prosyslab/continuous-reasoning.git), then build.

```sh
cd ~
git clone https://github.com/prosyslab/continuous-reasoning.git bayesmith
cd bayesmith
./build.sh
```

One may do the following to build BayeSmith:

- delete `opam install depext` from `sparrow`

## Overview

### Learned rules (Datalog)

Every pre-learned rule can be found in `datalog` directory.

1. `BufferOverflow.dl` and `IntegerOverflow.dl` are the **initial** rules used for interval analysis and taint analysis, respectively.
2. `BufferOverflow.<PROGRAM>.dl` and `IntegerOverflow.<PROGRAM>.dl` are the **learned** rule for `<PROGRAM>`, which is one of the benchmarks starting from *1*.
3. `TBufferOverflow.<PROGRAM>.dl` and `TIntegerOverflow.<PROGRAM>.dl` are the **modified** version of learned rules(*2*) in a way that considering feedback from dynamic instrumentation.

### Rank plots

Every plot showing the change of true bug ranking(*Y*) over the interactions(*X*) for each program can be found in `rank-plots` directory.

- `<PROGRAM>.pdf` is the plot for `<PROGRAM>`.
