#!/bin/bash
./ponyc --triple arm-linux-gnueabihf -rir

./llvm-as rpxp.ll
./llc -mtriple=arm-linux-gnueabihf \
      rpxp.bc \
      -o rpxp.o \
      -filetype=obj

./arm-linux-gnueabihf-gcc -v \
        -o ./helloworld \
        -O3 -march=armv7-a -flto -fuse-linker-plugin \
        -fuse-ld=gold \
        ./rpxp.o \
        -L"/usr/local/lib" \
        -L"/home/vagrant/arm/ponyc/build/debug/" \
        -L"/home/vagrant/arm/ponyc/build/debug/../../packages" \
        -L"/usr/local/lib" \
        -Wl,--start-group \
        -l"rt" \
        -Wl,--end-group  \
        -lponyrt -lpthread -ldl -lm
