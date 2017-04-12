// string.s
// String and memory manipulation.

.file		"string.s"

.code16

.section	.globals

	.globl	memcpy
	.type	memcpy,		@function
// Copy memory.
// void *memcpy (void *dest, void *src, size_t n) {
memcpy:
	push	%bp
	mov	%sp,		%bp

// Store registers.
	push	%bx
	push	%cx
	push	%dx
	push	%si

// Our destination address.
	mov	0x4(%bp),	%cx
// Our source address.
	mov	0x6(%bp),	%si

// Our number of bytes.
	mov	0x8(%bp),	%dx

// size_t i = 0;
	mov	$0,		%bx

.Lmemcpy_movb:
// Load the next byte into %al from the source index, then increment %si.
	lodsb

// Move the byte.
	mov	%al,		(%ecx)

// Increment the destination pointer, the source has already been incremented.
	inc	%cx

// Increment i, and compare against n for continuation.
	inc	%bx
	cmp	%dx,		%bx
	jl	.Lmemcpy_movb

// Return dest.
	mov	0x4(%bp),	%ax

// Restore registers.
	pop	%si
	pop	%dx
	pop	%cx
	pop	%bx

	mov	%bp,		%sp
	pop	%bp
	ret
// }
	.size	memcpy,		.-memcpy

// vim: set ts=8 sw=8 noet syn=asm:
