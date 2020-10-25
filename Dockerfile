FROM ubuntu:18.04
RUN apt update&&apt install -y sudo wget software-properties-common&&add-apt-repository ppa:ubuntu-toolchain-r/test && apt update && apt install -y g++-10 unp lzip python3-pip && python3 -m pip install tclib==0.0.3
RUN adduser --disabled-password --gecos '' ubuntu&&adduser ubuntu sudo&&echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
SHELL ["/bin/bash", "-c"]
USER root
RUN echo "deb https://dl.bintray.com/souffle-lang/deb-unstable bionic main" | sudo tee -a /etc/apt/sources.list; \
echo deb "[ arch=amd64 ] https://downloads.skewed.de/apt bionic main">>/etc/apt/sources.list; \
apt-key adv --keyserver keys.openpgp.org --recv-key 612DEFB798507F25; \
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 379CE192D401AB61&&apt-get update; \
DEBIAN_FRONTEND="noninteractive" apt install -y dejagnu \
#binutil
souffle ant python3-graph-tool \
# ci-exp dependency
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
USER ubuntu
RUN sudo add-apt-repository -y ppa:avsm/ppa && \
sudo apt install -y  ocaml opam make m4 git&&pushd /tmp &&git clone https://github.com/prosyslab/sparrow.git && \
cd sparrow && git checkout c9865fba0440ea362b38c71780ee8ccc42605729 && git status && \
sed -i 's/opam init /opam init --disable-sandboxing /g' build.sh; \
yes|./build.sh ; opam install clangml.4.1.0 ; \
eval $(opam env) ;make;sudo mv $(readlink -f bin/sparrow) /usr/bin/sparrow
