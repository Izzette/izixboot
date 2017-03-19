// stage2.s
// Stage 2 (LBA 1) boot-loader for the izix kernel.

.include	"errno.s"

.file		"stage2.s"

.code16

.section	.stage2

	.globl	stage2
	.type	stage2,		@function
// Do the thing, Julie.
// void stage2 (uint16_t *driveindex) {
stage2:
// This function should never return,
// so forget about saving the base pointer.
// Thsi will of course change the offset of variables in the stack.
//	push	%bp
	mov	%sp,		%bp

// Initialize the lbapack.
	call	init_lba_pack

// If an error occured, it's either because
// we failed to find a bootable partition,
// or because it's either because the DOS is bad.
	cmpw	$ENOBOOTABLE,	errno
	je	noboot
	cmpw	$ENOERR,	errno
	jne	baddos

// Show that we're booting before we start the read
// (which may be long on slow media).
	push	$validmsg
	call	puts
	add	$2,		%sp

// Push the drive index as the first argument of load_kernel.
	push	0x2(%bp)
	call	load_kernel
	add	$2,		%sp

// If an error occured, it's because the BIOS failed to read the drive.
	cmpw	$ENOERR,	errno
	jne	readerr

// Switch to 32-bit protected mode and execute the kernel.
	call	kexec

// This function should never return,
// so forget about restoring the stack and base pointers.
//	mov	%bp,		%sp
//	pop	%bp
//	ret
// }
	.size	stage2,		.-stage2

// NOTE: The data segment goes into the MBR along with .stage1.
.section	.rodata

// Valid input booting message.
validmsg:
	.asciz	"Booting ...\r\n"

// vim: set ts=8 sw=8 noet syn=asm:
