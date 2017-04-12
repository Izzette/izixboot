// memmap.s

#include "izixboot/nonexist.h"

.include	"errno.s"
.include	"bool.s"

.file		"memmap.s"

	.set	acpi3x_start,	0x14
	.set	acpi3x_xattrs,	0x000000001
	.set	smap,		0x0534D4150

.code16

.section	.stage2

	.globl	get_memmap
	.type	get_memmap,	@function
// Use the INT 0x15, eax=0xE820 BIOS function to get a memory map.
// Place it into entry_dest, and fake ACPI 3.x format even if it's not supported.
// See include/izixboot/memmap.h for a definition of e820_3x_entry_t.
// Returns the exclusive maximum address of of the e820_3x_entry_t entries.
// short get_memmap (e820_3x_entry_t *entry_dest) {
get_memmap:
	push	%bp
	mov	%sp,		%bp

// Store registers.
	push	%di

// First argument is the location of the memmap array.
	mov	0x4(%bp),	%di

// The state must be 0 to start.
	xorl	%eax,		%eax

// Make the call, set first=$true.
	pushl	%eax
	push	%di
	call	e820
// The new state is stored in %eax, don't overwrite it.
	add	$0x6,		%sp

// Carry set on first call means "unsupported function".
	jc	.Lmemmap_err

	jmp	.Lmemmap_inc

.Lmemmap_e820:
// Make the call.
	pushl	%eax
	push	%di
	call	e820
// The new state is stored in %eax, don't overwrite it.
	add	$0x6,		%sp

// Check for error.
	cmpw	$ENOERR,	errno
	jne	.Lmemmap_err

// Carry flag set means end *already* of list reached.
	jc	.Lmemmap_fin

//	jmp	.Lmemmap_inc

.Lmemmap_inc:
// Increment our entry pointer.
	add	$0x18,		%di

// If ebx is back to zero, we've reached the end of the list.
	or	%eax,		%eax
	jz	.Lmemmap_fin

// Otherwise make another call.
	jmp	.Lmemmap_e820

.Lmemmap_err:
// Set errno to ENOMEMMAP
	movw	$ENOMEMMAP,	errno
//	jmp	.Lmemmap_fin

.Lmemmap_fin:
// Set the entry length as the return value.
	mov	%di,		%ax

// Restore registers.
	pop	%di

	mov	%bp,		%sp
	pop	%bp
	ret
// }
	.size	get_memmap,	.-get_memmap

// e820 doesn't really belong in .globals, but we're out of room in .stage2.
.section	.globals

	.globl	e820
	.type	e820,		@function
// Returns the new state.
// int e820 (e820_3x_entry_t *entry, const int state) {
e820:
	push	%bp
	mov	%sp,		%bp

// Store registers.
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	push	%di

// Entry pointer needs to go into %di
	mov	0x4(%bp),	%di
// State needs to return to %ebx.
	movl	0x6(%bp),	%ebx

// Place "SMAP" into edx.
	movl 	$smap,		%edx

// Fake a valid ACPI 3.X entry if its not supported.
	movl	$acpi3x_xattrs,	acpi3x_start(%di)

// ask for 24 bytes
	movl	$0x18,		%ecx

// Make BIOS function call.
	movl	$0xe820,	%eax
	int	$0x15

// On success, eax must have been reset to "SMAP"
	cmpl	$smap,		%eax
	je	.Le820_fin

.Le820_err:
	movw	$ENOMEMMAP,	errno
//	jmp	.Le820_fin

.Le820_fin:
// Return the new state.
	mov	%ebx,		%eax

// Retore registers.
	pop	%di
	popl	%edx
	popl	%ecx
	popl	%ebx

	mov	%bp,		%sp
	pop	%bp
	ret
// }
	.size	e820,	.-e820

// vim: set ts=8 sw=8 noet syn=asm:
