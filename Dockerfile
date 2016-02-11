FROM ubuntu:vivid
MAINTAINER Markus Fix <lispmeister@gmail.com>

RUN echo "Is this a 32 or 64 bit platform: `/usr/bin/getconf LONG_BIT`"

RUN dpkg --add-architecture armhf && \
    grep -i '^deb http' /etc/apt/sources.list | \
    sed -e 's/archive/ports/' -e 's!/ubuntu!/ubuntu-ports!' \
    -e 's/deb http/deb [arch=armhf] http/' | \
    tee /etc/apt/sources.list.d/armhf.list && \
    sed -i -e 's/deb http/deb [arch=amd64,i386] http/' /etc/apt/sources.list && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    automake \
    autotools-dev \
    build-essential \
    file \
    g++-multilib \
    gcc-multilib \
    git \
    libicu-dev \
    libncurses5-dev \
    libpcre3 \
    libssl-dev \
    libxml2-dev \
    llvm-3.6 \
    llvm \
    zlib1g-dev \
    software-properties-common \
    libicu-dev:armhf \
    libncurses5-dev:armhf \
    libxml2-dev:armhf \
    zlib1g-dev:armhf && \
    add-apt-repository -y ppa:linaro-maintainers/toolchain && \
# hack to make apt-get update not fail due to ppa not having proper Packages files
    (apt-get update || true) && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN rm -rf /build/*
RUN mkdir -p /build/pony
RUN mkdir -p /build/arm
WORKDIR /build/arm
RUN git  clone https://github.com/dipinhora/ponyc.git ponyc

WORKDIR /build/arm/ponyc
RUN git checkout cross_compiling

RUN CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ \
    make arch=armv7-a bits=32 verbose=true libponyrt

WORKDIR /build
RUN git clone https://github.com/dipinhora/ponyc.git ponyc && \
    cd /build/ponyc && \
    git checkout cross_compiling && \
    make verbose=true ponyc && \
    make install && \
    rm -rf /build/ponyc && rm -rf /build/pony

RUN mkdir /data
WORKDIR /data
COPY runasuser.sh /root/ 
COPY build.sh /build/ 
RUN chmod ugo+x /build/*.sh
ENTRYPOINT ["/root/runasuser.sh"]


