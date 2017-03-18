#!/bin/bash

CC="${CC:-gcc}"

"$CC" -nostdlib -m16 -ggdb                                       boot.s -c -o boot.o
"$CC" -nostdlib -m16       -Wl,--oformat,binary -Wl,-T,linker.ld boot.o    -o boot

# vim: set ts=2 sw=2 et syn=sh:
