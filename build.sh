#!/bin/bash

module_name=$(basename `pwd`)

/build/bin/ponyc --triple arm-unknown-linux-gnueabihf -robj

arm-linux-gnueabihf-gcc \
        -o ${module_name} \
        -O3 -march=armv7-a -flto -fuse-linker-plugin \
        -fuse-ld=gold \
        ${module_name}.o \
        -L"/usr/local/lib" \
        -L"/build/arm/ponyc/build/debug/" \
        -L"/build/arm/ponyc/build/release/" \
        -L"/build/arm/ponyc/packages" \
        -Wl,--start-group \
        -l"rt" \
        -Wl,--end-group  \
        -lponyrt -lpthread -ldl -lm

