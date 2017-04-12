// start.s
// _start entry point for MBR stage 1 boot-loader.

.include	"errno.s"
.include	"mbr.s"

.file		"start.s"

.code16

.section	.start

	.globl	_start
	.type	_start,		@function
// The _start function, our entry point.
// void _start () {
_start:
// The stack won't be initialized yet, so don't do anything with it.
//	push	%bp
//	mov	%sp,		%bp

// Disable those pesky interupts.
	cli

// Set all segments to 0, except %cs which requires a far jump/call.
	mov	$0x00,		%ax
	mov	%ax,		%ds
	mov	%ax,		%es
	mov	%ax,		%fs
	mov	%ax,		%gs
	mov	%ax,		%ss

// Ensure %cs is 0x00.
	ljmp	$0x00,		$.L_start_reload_cs

// Reload the code segment.
.L_start_reload_cs:

// Initialize the stack.
	mov	$mbrstart,	%sp
	mov	%sp,		%bp

// Drive index should be in %dl already.
//	xchg	%dl,		%dl

// Initialize errno
	movw	$ENOERR,	errno

// Start the stage1 bootloader using the drive_index in %dx.
	push	%dx
	call	stage1
// This function should never return.
//	add	$2,		%sp

//	mov	%bp,		%sp
//	pop	%bp
//	ret
// }
	.size	_start,		.-_start

// vim: set ts=8 sw=8 noet syn=asm:
