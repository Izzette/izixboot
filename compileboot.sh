gcc -m16 -Wl,--oformat,binary -Wl,-T,linker.ld -nostdlib boot.s -o boot
