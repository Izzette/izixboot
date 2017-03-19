# Makefile

CC := gcc
CFLAGS ?= -ggdb
CFLAGS := $(CFLAGS) -nostdlib

all: boot

boot.s:
pmode.s:
linker.ld:

boot.o:
	$(CC) $(CFLAGS) -m16 -c boot.s -o boot.o
pmode.o:
	$(CC) $(CFLAGS) -m32 -c pmode.s -o pmode.o

boot.elf: boot.o pmode.o linker.ld
	$(CC) $(CFLAGS) -m16 -T linker.ld boot.o pmode.o -o boot.elf

boot: boot.elf
	objcopy -j .text -O binary boot.elf boot

clean:
	rm -f *.o boot.elf boot

# vim: set ts=4 sw=4 noet syn=make:
