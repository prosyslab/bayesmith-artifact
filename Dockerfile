FROM ubuntu:18.04
RUN apt update&&apt install -y sudo wget software-properties-common&&add-apt-repository ppa:ubuntu-toolchain-r/test && apt update && apt install -y g++-10 unp lzip python3-pip && python3 -m pip install tclib==0.0.3
RUN adduser --disabled-password --gecos '' ubuntu&&adduser ubuntu sudo&&echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
SHELL ["/bin/bash", "-c"]
USER root
RUN cd /dev/shm && wget https://github.com/souffle-lang/souffle/releases/download/2.0.2/souffle_2.0.2-1_amd64.deb ; \
echo deb "[ arch=amd64 ] https://downloads.skewed.de/apt bionic main">>/etc/apt/sources.list; \
apt-key adv --keyserver keys.openpgp.org --recv-key 612DEFB798507F25 &&apt-get update; \
DEBIAN_FRONTEND="noninteractive" apt install -y dejagnu \
#binutil
./souffle_2.0.2-1_amd64.deb ant python3-graph-tool \
# ci-exp dependency
time \
#bc
#r-base-dev libcurl4-openssl-dev r-cran-rjava \
#R; R,git
#libpcre3 libpcre3-dev libpcrecpp0v5 libssl-dev zlib1g-dev \
#nginx
#libapr1-dev libaprutil1-dev \
#apache
flex libssl-dev \
# bc, wget
texinfo help2man \
# makeinfo,libtasn1-4.3
libtool m4 automake mcpp bison libsqlite3-dev libboost-dev
#sparrow
RUN apt install -y ant nano git bc libboost-dev libboost-program-options-dev libboost-test-dev libgmp-dev \
htop nano texlive-latex-extra cm-super dvipng && pip3 install matplotlib
# plot and utils
USER ubuntu
WORKDIR /home/ubuntu
RUN sudo add-apt-repository -y ppa:avsm/ppa && \
sudo apt install -y  ocaml opam make m4 git&&pushd /tmp &&git clone https://github.com/prosyslab/sparrow.git && \
cd sparrow && git checkout c9865fba0440ea362b38c71780ee8ccc42605729 && git status && \
sed -i 's/opam init /opam init --disable-sandboxing /g' build.sh; \
yes|./build.sh ; opam install clangml.4.1.0 ocamlgraph.1.8.8; \
eval $(opam env) ;make;sudo mv $(readlink -f bin/sparrow) /usr/bin/sparrow ; rm -rf /tmp/sparrow
RUN mkdir llvm && cd /dev/shm && wget https://github.com/TianyiChen/llvm-build/releases/download/48a8c7dc/clang11-virtualroot.tar.gz && tar -xzf clang11-virtualroot.tar.gz -C ~/llvm/
COPY --chown=ubuntu:ubuntu . dynaboost
RUN mv dynaboost/bingo-ci-experiment .
RUN mv dynaboost/vanilla-experiment .
RUN git clone --single-branch --branch DynamicBingo https://github.com/difflog-project/bingo && cd bingo && scripts/build.sh
RUN git clone --recurse-submodules https://github.com/nichrome-project/nichrome.git && cd nichrome && git checkout cc4eafa3c58e1175134392ffe7fe2e2ffb6b233f && cd main && ant && cd libsrc; pushd libdai; mv  Makefile.LINUX  Makefile.conf;popd; make -j8
#RUN cd dynaboost && . init.sh && cd dfsan-plugin && ./go.sh grep-2.19 grep-2.19 1 0

# htop