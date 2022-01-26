FROM ubuntu:18.04
RUN apt update&&apt install -y sudo wget software-properties-common&&add-apt-repository ppa:ubuntu-toolchain-r/test && apt update && apt install -y g++-10 unp lzip python3-pip && python3 -m pip install tclib==0.0.3
RUN adduser --disabled-password --gecos '' ubuntu&&adduser ubuntu sudo&&echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
SHELL ["/bin/bash", "-c"]
USER root

# dynaboost dependencies
RUN cd /dev/shm && wget https://github.com/souffle-lang/souffle/releases/download/2.0.2/souffle_2.0.2-1_amd64.deb ; \
echo deb "[ arch=amd64 ] https://downloads.skewed.de/apt bionic main">>/etc/apt/sources.list; \
apt-key adv --keyserver keys.openpgp.org --recv-key 612DEFB798507F25 &&apt-get update; \
DEBIAN_FRONTEND="noninteractive" apt install -y dejagnu \
./souffle_2.0.2-1_amd64.deb ant python3-graph-tool \
time \
flex libssl-dev \
texinfo help2man \
libtool m4 automake mcpp bison libsqlite3-dev libboost-dev

# sparrow dependencies and utils
RUN apt install -y ant nano vim git bc libboost-dev libboost-program-options-dev libboost-test-dev libgmp-dev \
htop texlive-latex-extra cm-super dvipng
RUN pip3 install --upgrade pip
RUN python3 -m pip install matplotlib

USER ubuntu
WORKDIR /home/ubuntu

ENV OPAMYES=1

# build sparrow
RUN sudo add-apt-repository -y ppa:avsm/ppa && \
sudo apt install -y ocaml opam make m4 git && pushd /tmp && git clone https://github.com/prosyslab/sparrow.git && \
cd sparrow && git checkout e53e846f4eb2a1a4c410461452264a7d242f410a && \
sed -i 's/opam init /opam init --disable-sandboxing /g' build.sh && \
echo 'eval $(opam env)' >> ~/.bashrc && source ~/.bashrc && \
sed -i '/opam install depext/d' build.sh && \
sed -i 's/opam depext/opam install --depext-only/g' build.sh && \
yes|./build.sh; opam install -y clangml.4.1.0 ocamlgraph.1.8.8 linenoise && \
eval $(opam env) && make -j; sudo mv $(readlink -f bin/sparrow) /usr/bin/sparrow

# build dynaboost
RUN mkdir llvm && cd /dev/shm && wget https://github.com/TianyiChen/llvm-build/releases/download/48a8c7dc/clang11-virtualroot.tar.gz && tar -xzf clang11-virtualroot.tar.gz -C ~/llvm/ && \
wget https://github.com/TianyiChen/PL-assets/releases/download/main/fse2021-workspace.zip && unzip fse2021-workspace.zip -d /tmp
COPY --chown=ubuntu:ubuntu . dynaboost
RUN rm -rf dynaboost/.git; mv dynaboost/bingo-ci-experiment .; mv dynaboost/datalog .; mv dynaboost/rank-plots .
RUN mv dynaboost/README.md .; mv dynaboost/LICENSE .; mv dynaboost/STATUS .; mv dynaboost/INSTALL .; mv dynaboost/REQUIREMENTS .
RUN pushd bingo-ci-experiment/bingo/prune-cons; make -j; popd

# build bingo and nichrome
RUN git clone --single-branch --branch DynamicBingo https://github.com/difflog-project/bingo && cd bingo && scripts/build.sh; \
cd ~; git clone --recurse-submodules https://github.com/nichrome-project/nichrome.git && cd nichrome && git checkout cc4eafa3c58e1175134392ffe7fe2e2ffb6b233f && cd main && ant && cd libsrc; pushd libdai; mv Makefile.LINUX Makefile.conf;popd; make -j8

# build dfsan-plugin
RUN pushd dynaboost; . init.sh; cd dfsan-plugin; make -j4; popd

# drake
RUN sudo apt-get update && \
      sudo add-apt-repository ppa:avsm/ppa && \
      sudo apt-get update && \
      sudo apt-get install -y curl
RUN cd ~ && git clone -b bayesmith --single-branch https://github.com/prosyslab/pldi19-artifact.git drake
RUN rm -rf drake/.git

# build drake
RUN mv dynaboost/update-scripts .; mv dynaboost/setup.sh .; ./setup.sh
RUN pushd drake; ./build.sh; popd

# download libstdc++6.0.25 and set LD_LIBRARY_PATH env var
RUN mkdir tmp; pushd tmp; wget http://archive.ubuntu.com/ubuntu/pool/main/g/gcc-8/libstdc++6_8-20180414-1ubuntu2_amd64.deb; ar x libstdc++6_8-20180414-1ubuntu2_amd64.deb; tar -xvf data.tar.xz; popd
RUN echo 'export LD_LIBRARY_PATH=/home/ubuntu/tmp/usr/lib/x86_64-linux-gnu' >> ~/.bashrc && source ~/.bashrc
RUN sudo update-scripts/install-llvm.sh

# build bayesmith
RUN git clone https://github.com/prosyslab/bayesmith.git && cd bayesmith && git submodule update --init --recursive && mv ../update-scripts/new-sparrow-build.sh sparrow/build.sh && eval $(opam env) && ./build.sh
RUN rm -rf bayesmith/.git
RUN cd bayesmith && export LD_LIBRARY_PATH=/home/ubuntu/tmp/usr/lib/x86_64-linux-gnu && script/bingo/run-all.sh && script/bingo/run-all.sh --skip-analysis --skip-compress

