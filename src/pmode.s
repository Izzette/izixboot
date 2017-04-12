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
// * Finally far jump to our kernels _start.
// void pmode () {
pmode:
// Setup our protected mode stack.
	mov	$pmodestack,	%bp
	mov	%bp,		%sp

// Set all segment registers for our GDTs data segment.
	mov	$dataseg,	%ax
	mov	%ax,		%ds
	mov	%ax,		%es
	mov	%ax,		%fs
	mov	%ax,		%gs
	mov	%ax,		%ss

// Far jump to our kernels entry point.
// There is no need to call, as the kernels _start should never _ret.
	ljmp	$codeseg,	$kentryoffset
// }
	.size	pmode,		.-pmode

// vim: set ts=8 sw=8 noet syn=asm:
