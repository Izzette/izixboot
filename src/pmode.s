// pmode.s
// Protected mode bootloader code.

// Kernel entry point
.set	kentryseg,	0x08
.set	kentryoffset,	0x9000

// We're moving into 32-bit protected mode.
.code32

.section	.stage2

	.global pmode
	.type	pmode,		@function
// Protected mode code, just setup segement registers and far jump to main.
// void pmode () {
pmode:
	mov	$0x10,		%ax
	mov	%ax,		%ds
	mov	%ax,		%es
	mov	%ax,		%fs
	mov	%ax,		%gs
	mov	%ax,		%ss

	ljmp	$kentryseg,	$kentryoffset
// }
	.size	pmode,		.-pmode

// vim: set ts=8 sw=8 noet syn=asm:
