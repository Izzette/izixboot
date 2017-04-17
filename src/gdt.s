// gdt.s
// Working with the GDT and GDT Registry.

.include	"heap.s"
.include	"gdtproto.s"

.file		"gdt.s"

.code16

.section	.stage2

	.globl	init_gdt
	.type	init_gdt,	@function
// Initialize the GDT
// See include/izixboot/gdt32.h for a definition of gdt32_entry_t.
// void init_gdt (const gdt_register_t *registry, const gdt32_entry_t *gdt_entries) {
init_gdt:
// There is no need to mess with the stack, this function accepts no arguments.
	push	%bp
	mov	%sp,		%bp

// Store registers.
	push	%bx

// Move the gdt_entries pointer to %ax
	mov	0x4(%bp),	%bx
	mov	0x6(%bp),	%ax

// Copy the GDT prototype.
	push	$gdtlen
	push	$gdtproto
	push	%ax
	call	memcpy
	pop	%ax
	add	$0x4,		%sp


// Create the descriptor registry.
	movw	$gdtlen-1,	0x00(%bx)
	movw	%ax,		0x02(%bx)
	movw	$0x0000,	0x04(%bx)

// Load the GDT, doesn't take effect until next ljmp, lcall, or lret
	lgdt	(%bx)

// Restore registers.
	pop	%bx

	mov	%bp,		%sp
	pop	%bp
	ret
// }
	.size	init_gdt,	.-init_gdt

// vim: set ts=8 sw=8 noet syn=asm:
