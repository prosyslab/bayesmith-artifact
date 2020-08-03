FROM ubuntu:18.04
RUN apt update&&apt install -y sudo wget software-properties-common&&add-apt-repository ppa:ubuntu-toolchain-r/test && apt update && apt install -y g++-10 unp python3-pip && python3 -m pip install tclib
RUN adduser --disabled-password --gecos '' ubuntu&&adduser ubuntu sudo&&echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
SHELL ["/bin/bash", "-c"]
USER ubuntu
RUN sudo add-apt-repository -y ppa:avsm/ppa && \
sudo apt install -y  ocaml opam make m4 git&&pushd /tmp &&git clone https://github.com/KihongHeo/sparrow.git && \
cd sparrow&& git checkout 5580437e53fffdb25056dc43cc9193ddab68039d && \
sed -i 's/opam init /opam init --disable-sandboxing /g' build.sh&&yes|./build.sh && sudo mv bin/sparrow /usr/bin && popd
USER root
RUN DEBIAN_FRONTEND="noninteractive" apt install -y dejagnu \
#binutil
r-base-dev libcurl4-openssl-dev r-cran-rjava \
#R; R,git
#libpcre3 libpcre3-dev libpcrecpp0v5 libssl-dev zlib1g-dev \
#nginx
libapr1-dev libaprutil1-dev \
#apache
flex
# bc
USER ubuntu
