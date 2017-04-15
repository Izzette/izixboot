// gdt.s
// Working with the GDT and GDT Registry.

.include	"heap.s"

.file		"gdt.s"

// The GDT registry.
	.set	gdtr,		heapstart
// The GDT.  The GDT registry is only 6 bytes long,
// but lets just make sure it's aligned to 4.
	.set	gdt,		heapstart+0x08

.code16

.section	.stage2

	.globl	init_gdt
	.type	init_gdt,	@function
// Initialize the GDT
// void init_gdt () {
init_gdt:
// There is no need to mess with the stack, this function accepts no arguments.
//	push	%bp
//	mov	%sp,		%bp

// Copy the GDT prototype.
	push	$gdtlen
	push	$gdtproto
	push	$gdt
	call	memcpy
	add	$0x6,		%sp

// Create the descriptor registry.
	movw	$gdtlen-1,	gdtr
	movl	$gdt,		gdtr+0x02

// Load the GDT, doesn't take effect until next ljmp, lcall, or lret
	lgdt	gdtr

//	mov	%bp,		%sp
//	pop	%bp
	ret
// }
	.size	init_gdt,	.-init_gdt

.section	.rodata

	.type	gdtproto,	@object
// GDT prototype
gdtproto:
// NULL descriptor
	.long   0x00000000
	.long   0x00000000
// Code descriptor
	.long	0x0000FFFF
	.long	0x00CF9A00
// Data descriptor
	.long	0x0000FFFF
	.long	0x00CF9200
// END gdtproto
	.set	gdtlen,		.-gdtproto
	.size	gdtproto,	gdtlen

// vim: set ts=8 sw=8 noet syn=asm:
