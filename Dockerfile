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
    curl \
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
    apt-get -y autoremove --purge && \
    apt-get -y clean

RUN mkdir -p /tmp/pcre-src && \
    curl -SL -o /tmp/pcre-src/repo.tbz2 ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre2-10.20.tar.bz2 && \
    tar xf /tmp/pcre-src/repo.tbz2 -C /tmp/pcre-src && \
    ln -s /tmp/pcre-src/*pcre* /tmp/pcre-src/pcre && \
    cd /tmp/pcre-src/pcre && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    rm -r /tmp/pcre-src/*pcre*

ARG PONYC_CONFIG=debug
ENV PONYC_CONFIG ${PONYC_CONFIG}

RUN rm -rf /build/*
RUN mkdir -p /build/pony
RUN mkdir -p /build/arm
WORKDIR /build/arm
RUN git clone https://github.com/ponylang/ponyc.git ponyc

WORKDIR /build/arm/ponyc

RUN CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ \
    make arch=armv7-a bits=32 config=${PONYC_CONFIG} libponyrt

WORKDIR /build
RUN git clone https://github.com/ponylang/ponyc.git ponyc && \
    cd /build/ponyc && \
    make config=${PONYC_CONFIG} ponyc && \
    make config=${PONYC_CONFIG} test && \
    rm -f /build/ponyc/build/${PONYC_CONFIG}/libgtest.a && \
    rm -f /build/ponyc/build/${PONYC_CONFIG}/libponyc.tests && \
    rm -f /build/ponyc/build/${PONYC_CONFIG}/libponyrt-pic.a && \
    rm -rf /build/ponyc/build/${PONYC_CONFIG}/obj

RUN mkdir bin && \
    cd bin && \
    ln -s /build/ponyc/build/${PONYC_CONFIG}/ponyc .

COPY runasuser.sh /root/
ENTRYPOINT ["/root/runasuser.sh"]

