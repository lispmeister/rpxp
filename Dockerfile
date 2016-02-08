FROM ubuntu:vivid
MAINTAINER Markus Fix <lispmeister@gmail.com>

RUN echo "Is this a 32 or 64 bit platform: `/usr/bin/getconf LONG_BIT`"

RUN dpkg --add-architecture i386
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    automake \
    autotools-dev \
    build-essential \
    file \
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

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /build
WORKDIR /build
RUN git clone git://github.com/raspberrypi/tools.git rpi-tools
ENV PATH=/build/rpi-tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin:$PATH
RUN ls /build/rpi-tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin

RUN mkdir -p /build/pony
WORKDIR /build/arm
RUN git clone https://github.com/ponylang/ponyc.git

WORKDIR /build/arm/ponyc
COPY ponyc_armcc.patch /build/pony
RUN patch -p0 < /build/pony/ponyc_armcc.patch

RUN CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ \
    make arch=armv7-a bits=32 verbose=true libponyrt

WORKDIR /build
COPY ponyc_cross_compiler.patch /build/pony
RUN git clone https://github.com/ponylang/ponyc.git ponyc
WORKDIR /build/ponyc
RUN patch -p0 < /build/pony/ponyc_cross_compiler.patch

RUN CXX="g++ -m32" make config=debug bits=32 verbose=true ponyc

RUN make install
RUN which ponyc
RUN which llvm-as
RUN which llc

RUN mkdir /data
WORKDIR /data
COPY runasuser.sh /root/ 
ENTRYPOINT ["/root/runasuser.sh"]
