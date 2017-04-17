# Makefile

CC := gcc
HOSTCC := gcc
OBJCOPY := objcopy
CFLAGS ?= -ggdb -Wall -Wextra
CFLAGS := $(CFLAGS) -nostdlib
DEBUG_CFLAGS ?= -ggdb -Wall -Wextra
DEBUG_CFLAGS := $(DEBUG_CFLAGS)
HOST_CFLAGS ?= -O2 -Wall -Wextra
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

exec_build := generate_gdtproto
exec_build := $(addprefix build/,$(exec_build))

exec_test := gdt_recode
run_test := $(addprefix test_,$(exec_test))
exec_test := $(addprefix test/,$(exec_test))

include $(wildcard src/*.d)
include $(wildcard debug/*.d)
include $(wildcard build/*.d)
include $(wildcard test/*.d)

all: boot
extra: prepare all debug test
prepare: generated/gdtproto.s
debug: $(objects_debug)
test: $(run_test)
clean: clean_build clean_generated clean_src clean_debug clean_boot_elf clean_boot clean_test

$(objects_debug):%.o:%.c
	$(HOSTCC) $(DEBUG_CFLAGS) -I./include -m32 -c $< -o $@

$(objects16):%.o:%.s
	$(CC) $(CFLAGS) -Wa,-I./src -Wa,-I./generated -m16 -c $< -o $@

$(objects32):%.o:%.s
	$(CC) $(CFLAGS) -m32 -c $< -o $@

boot.elf: lds/linker.ld $(bootobjects)
	$(CC) $(CFLAGS) -m16 -Wl,-Tlds/linker.ld \
		$(bootobjects) \
		-o boot.elf

boot: boot.elf
	objcopy -j .text -O binary boot.elf boot

$(exec_build):%:%.c
	$(HOSTCC) $(HOST_CFLAGS) -I./include $< -o $@

generated:
	mkdir -p generated

generated/gdtproto.s: generated build/generate_gdtproto
	./build/generate_gdtproto > generated/gdtproto.s

$(exec_test):%:%.c
	$(HOSTCC) $(HOST_CFLAGS) -I./include $< -o $@

$(run_test):test_%:test/%
	./$<

clean_build:
	rm -f $(exec_build)

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

clean_test:
	rm -f $(exec_test)

# vim: set ts=4 sw=4 noet syn=make:
