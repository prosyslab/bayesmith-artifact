# BayeSmith-artifact

To build BayeSmith docker image, run below command:

```sh
docker build . -t bayesmith --shm-size 4G
```

To launch the docker container, run below command:

```sh
docker run -it bayesmith
```

DockerFile itself manages to build DynaBoost and Drake.
For now, one should manually git-clone the BayeSmith repository, then build.

```sh
cd ~
git clone https://github.com/prosyslab/continuous-reasoning.git bayesmith
cd bayesmith
./build.sh
```

One may do the following to build BayeSmith:

- delete `opam install depext` from `sparrow`
