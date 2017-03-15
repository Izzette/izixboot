gcc -m16 -nostdlib -ggdb                                 boot.s -c -o boot.o
gcc -m16 -nostdlib -Wl,--oformat,binary -Wl,-T,linker.ld boot.o    -o boot
