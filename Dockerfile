FROM ubuntu:18.04
RUN apt update&&apt install -y sudo wget software-properties-common&&add-apt-repository ppa:ubuntu-toolchain-r/test && apt update && apt install -y g++-10 unp python3-pip && python3 -m pip install tclib
RUN adduser --disabled-password --gecos '' ubuntu&&adduser ubuntu sudo&&echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# for                                                
RUN DEBIAN_FRONTEND="noninteractive" apt install -y dejagnu \
#binutil
r-base-dev libcurl4-openssl-dev
#R; R,git
USER ubuntu
