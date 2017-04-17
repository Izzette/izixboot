// pmode.s
// Protected mode bootloader code.

.file		"pmode.s"

// The start of the 32-bit protected mode stack, formally the end of our bootloader.
	.set	pmodestack,	0x8000

// Data and code segments.
	.set	dataseg,	0x10
	.set	codeseg,	0x08

// Kernel entry point.
	.set	kentryoffset,	0x9000

// We're moving into 32-bit protected mode.
.code32

.section	.pmode

	.global pmode
	.type	pmode,		@function
// Our snippet of protected mode code.
// * Setup the new stack reclaiming the MBR bootstrap code.
// * Set the segment registers to something compatible with our flat GDT.
// * Finally far call to our kernels _start.
// void pmode (short entry_count, e820_3x_entry_t *memmap_entries[]) {
pmode:
// This function will not be returning,
// so forget about saving the base pointer or other registers,
// this will of course change the location of argmuments on the stack.
//	push	%ebp
// This function was far-called from 16-bit mode, so let's make sure the upper
// half of our base and stack pointers are clean.  We can from here on out pretend
// that this code was short called from 32-bit code.
	and	$0x0000ffff,	%esp
//	mov	%esp,		%ebp

// Set all segment registers for our GDTs data segment.
	mov	$dataseg,	%ax
	mov	%ax,		%ds
	mov	%ax,		%es
	mov	%ax,		%fs
	mov	%ax,		%gs
	mov	%ax,		%ss

// Save our old "base" pointer containing our parameters in %eax.
	mov	%esp,		%eax

// Setup our protected mode stack.
	mov	$pmodestack,	%ebp
	mov	%ebp,		%esp

// Far call to our kernels entry point.
	pushl	0x0c(%eax)
	pushl	0x08(%eax)
	pushl	0x04(%eax)
	lcall	$codeseg,	$kentryoffset
// This function should never return,
// so forget about restoring the registers.
//	add	$0x12,		%esp

//	mov	%bp,		%sp
//	pop	%bp
//	ret
// }
	.size	pmode,		.-pmode

// vim: set ts=8 sw=8 noet syn=asm:
