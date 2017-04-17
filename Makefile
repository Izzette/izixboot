# Makefile

CC := gcc
HOSTCC := gcc
OBJCOPY := objcopy
CFLAGS ?= -ggdb
CFLAGS := $(CFLAGS) -nostdlib
HOST_CFLAGS ?= -O2
HOST_CFLAGS := $(HOST_CFLAGS)

ifdef COMPILER_PATH
override CC := COMPILER_PATH=$(COMPILER_PATH) $(CC)
endif
ifdef HOST_COMPILER_PATH
override HOSTCC := COMPILER_PATH=$(HOST_COMPILER_PATH) $(HOSTCC)
endif

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
	$(CC) $(CFLAGS) -Wa,-I./src -Wa,-I./generated -m16 -c $< -o $@

$(objects32):%.o:%.s
	$(CC) $(CFLAGS) -m32 -c $< -o $@

include $(wildcard src/*.d)
include $(wildcard debug/*.d)
include $(wildcard build/*.d)

boot.elf: lds/linker.ld $(bootobjects)
	$(CC) $(CFLAGS) -m16 -Wl,-Tlds/linker.ld \
		$(bootobjects) \
		-o boot.elf

boot: boot.elf
	objcopy -j .text -O binary boot.elf boot

prepare: build/generate_gdtproto

build/generate_gdtproto.o:%.o:%.c
	$(HOSTCC) $(HOST_CFLAGS) -I./include -c $< -o $@

build/generate_gdtproto:%:%.o
	$(HOSTCC) $(HOST_CFLAGS) $< -o $@

generated:
	mkdir -p generated

generated/gdtproto.s: generated build/generate_gdtproto
	./build/generate_gdtproto > generated/gdtproto.s

clean: clean_build clean_generate_gdtproto clean_generated clean_src clean_debug clean_boot_elf clean_boot

clean_build:
	rm -f build/*.o

clean_generate_gdtproto:
	rm -f build/generate_gdtproto

clean_generated:
	rm -f generated/*
	if [ -d generated ]; then \
	  rmdir generated; \
	fi

clean_src:
	rm -f src/*.o

clean_debug:
	rm -f debug/*.o

clean_boot_elf:
	rm -f boot.elf

clean_boot:
	rm -f boot

# vim: set ts=4 sw=4 noet syn=make:
