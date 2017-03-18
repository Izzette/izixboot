# Makefile

CC := gcc
CFLAGS := -ggdb -Wl,-T,linker.ld -Wl,--oformat,binary -nostdlib

all: boot

boot.s:
pmode.s:
linker.ld:

boot.o:
	$(CC) $(CFLAGS) -m16 -c boot.s -o boot.o
pmode.o:
	$(CC) $(CFLAGS) -m32 -c pmode.s -o pmode.o

boot: boot.o pmode.o linker.ld
	$(CC) $(CFLAGS) -m16 boot.o pmode.o -o boot

# vim: set ts=4 sw=4 noet syn=make:
