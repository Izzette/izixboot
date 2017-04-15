# Makefile

CC := gcc
OBJCOPY := objcopy
CFLAGS ?= -ggdb
CFLAGS := $(CFLAGS) -nostdlib

objects16 := dos.o errno_data.o fail.o gdt.o heap.o loadk.o memmap.o \
             reset.o stage1.o stage2.o start.o stdio.o string.o
objects16 := $(addprefix src/,$(objects16))

objects32 := pmode.o
objects32 := $(addprefix src/,$(objects32))

objects_debug := memmap.o
objects_debug := $(addprefix debug/,$(objects_debug))

bootobjects := $(objects16) $(objects32)

all: boot
debug: $(objects_debug)

$(objects_debug):%.o:%.c
	$(CC) $(CFLAGS) -I./include -m32 -c $< -o $@

$(objects16):%.o:%.s
	$(CC) $(CFLAGS) -Wa,-I./src -m16 -c $< -o $@

$(objects32):%.o:%.s
	$(CC) $(CFLAGS) -Wa,-I./src -m32 -c $< -o $@

include $(wildcard src/*.d)
include $(wildcard debug/*.d)

boot.elf: lds/linker.ld $(bootobjects)
	$(CC) $(CFLAGS) -m16 -Wl,-Tlds/linker.ld \
		$(bootobjects) \
		-o boot.elf

boot: boot.elf
	objcopy -j .text -O binary boot.elf boot

clean: clean_src clean_debug clean_boot_elf clean_boot

clean_src:
	rm -f src/*.o

clean_debug:
	rm -f debug/*.o

clean_boot_elf:
	rm -f boot.elf

clean_boot:
	rm -f boot

# vim: set ts=4 sw=4 noet syn=make:
