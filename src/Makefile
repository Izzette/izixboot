# src/Makefile

objects16 := dos.o errno_data.o fail.o gdt.o heap.o loadk.o \
             reset.o stage1.o stage2.o start.o stdio.o string.o
objects32 := pmode.o

all: $(objects16) $(objects32)

$(objects16):%.o:%.s
	$(CC) $(CFLAGS) -m16 -c $< -o $@

$(objects32):%.o:%.s
	$(CC) $(CFLAGS) -m32 -c $< -o $@

clean:
	rm -f *.o

# vim: set ts=4 sw=4 noet syn=make:
