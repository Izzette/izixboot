# Makefile

CC := gcc
OBJCOPY := objcopy
CFLAGS ?= -ggdb
CFLAGS := $(CFLAGS) -nostdlib

export

all: boot

subsystem:
	$(MAKE) -C src

boot.elf: lds/linker.ld subsystem
	$(CC) $(CFLAGS) -m16 -T lds/linker.ld \
		src/start.o $(filter-out src/start.o,$(wildcard src/*.o)) \
		-o boot.elf

boot: boot.elf
	objcopy -j .text -O binary boot.elf boot

clean: clean_local clean_subsystem

clean_subsystem:
	$(MAKE) -C src clean

clean_local:
	rm -f boot.elf boot

# vim: set ts=4 sw=4 noet syn=make:
