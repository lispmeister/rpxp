FROM ubuntu:vivid
MAINTAINER Markus Fix <lispmeister@gmail.com>

RUN echo "Is this a 32 or 64 bit platform: `/usr/bin/getconf LONG_BIT`"

RUN dpkg --add-architecture i386
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    automake \
    autotools-dev \
    build-essential \
    g++-multilib \
    gcc-multilib \
    git \
    libicu-dev:i386 \
    libncurses5-dev \
    libncurses5-dev:i386 \
    libpcre3 \
    libssl-dev \
    libxml2-dev:i386 \
    llvm-3.6:i386 \
    llvm:i386 \
    zlib1g-dev:i386 

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    software-properties-common
RUN add-apt-repository -y ppa:linaro-maintainers/toolchain
RUN dpkg --add-architecture armhf
RUN grep -i '^deb http' /etc/apt/sources.list | \
    sed -e 's/archive/ports/' -e 's!/ubuntu!/ubuntu-ports!' \
    -e 's/deb http/deb [arch=armhf] http/' | \
    tee /etc/apt/sources.list.d/armhf.list
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libicu-dev:armhf \
    libncurses5-dev:armhf \
    libxml2-dev:armhf \
    llvm-3.6:armhf \
    llvm:armhf \
    zlib1g-dev:armhf
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN rm -rf /build/*
RUN mkdir -p /build/pony
RUN mkdir -p /build/arm
WORKDIR /build/arm
RUN git clone https://github.com/ponylang/ponyc.git

WORKDIR /build/arm/ponyc
COPY ponyc_armcc.patch /build/pony
RUN patch -p0 < /build/pony/ponyc_armcc.patch

RUN CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ \
    make arch=armv7-a bits=32 verbose=true libponyrt

rm -rf /home/vagrant/ponyc
cd /home/vagrant
git clone https://github.com/ponylang/ponyc.git
cd /home/vagrant/ponyc
patch -p0 < /vagrant/pony/ponyc_cross_compiler.patch

CXX="g++ -m32" make bits=32 verbose=true ponyc
