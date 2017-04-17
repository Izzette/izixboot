// gdt.s
// Working with the GDT and GDT Registry.

.include	"heap.s"
.include	"gdtproto.s"

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

// vim: set ts=8 sw=8 noet syn=asm:
