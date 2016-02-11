#!/bin/bash

module_name=$(basename `pwd`)

ponyc --triple arm-unknown-linux-gnueabihf -robj

arm-linux-gnueabihf-gcc -v \
        -o ${module_name} \
        -O3 -march=armv7-a -flto -fuse-linker-plugin \
        -fuse-ld=gold \
        ${module_name}.o \
        -L"/usr/local/lib" \
        -L"/build/arm/ponyc/build/debug/" \
        -L"/build/arm/ponyc/build/debug/../../packages" \
        -Wl,--start-group \
        -l"rt" \
        -Wl,--end-group  \
        -lponyrt -lpthread -ldl -lm

