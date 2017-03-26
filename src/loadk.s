// loadk.s
// Load and execute the kernel.

.include	"errno.s"

.file		"loadk.s"

.code16

.section	.stage2

	.globl	load_kernel
	.type	load_kernel,	@function
// Load the kernel.
// void load_kernel (const uint16_t drive_index) {
load_kernel:
	push	%bp
	mov	%sp,		%bp

// Save registers.
	push	%si
	push	%dx

// Drive index
	mov	0x4(%bp),	%dl

// Reset the drive.
	push	%dx
	call	reset_drive
	add	$2,		%sp

// LBA load info.
	mov	$lbapack,	%si
// %dl should already be correct.
//	xchg	%dl,		%dl
// int 13h ah=42h, load by LBA into memory.
	mov	$0x42,		%ah
	int	$0x13

// Set the $EREADERR errno flag if something goes wrong.
	jc	.Lload_kernel_readerr
	or	%ah,		%ah
// If all looks good return.
	jz	.Lload_kernel_fin
// 	jmp	.Lload_kernel_readerr

.Lload_kernel_readerr:
	orw	$EREADERR,	errno
//	jmp	.Lload_kernel_fin

.Lload_kernel_fin:
// Restore registers.
	pop	%dx
	pop	%si

	mov	%bp,		%sp
	pop	%bp
	ret
// }
	.size	load_kernel,	.-load_kernel

	.globl	kexec
	.type	kexec,		@function
// Enter protected mode and execute the kernel.
// void kexec () {
kexec:
// There's no coming back from here,
// so forget about saving the base pointer.
//	push	%bp
// There is no need to mess with the stack, this function accepts no arguments.
//	mov	%sp,		%bp

// Load the GDT registry.
	call	init_gdt

// set PE (Protection Enable) bit in CR0 (Control Register 0)
	mov	%cr0,		%eax
	or	$1,		%eax
	mov	%eax,		%cr0

// Jump to 32-bit protected mode code
	ljmp	$0x08,		$pmode

// This function should never return,
// so forget about restoring the stack and base pointers.
//	mov	%bp,		%sp
//	pop	%bp
//	ret
// }
	.size	kexec,		.-kexec

	.globl	init_lba_pack
	.type	init_lba_pack,	@function
// Intialize the lbapack.
// Sets the $EINVALDOS errno flag if the DOS partition is invalid.
// Sets the $ENOBOOTABLE errno flag if the DOS partition does not
// void init_lba_pack () {
init_lba_pack:
// There is no need to mess with the stack, this function accepts no arguments.
//	push	%bp
//	mov	%sp,		%bp

// The bootable partition index will be in %ax.
	call	find_bootable

// If an error occurred ret real quick.
	cmpw	$ENOERR,	errno
	jne	.Linit_lba_pack_fin

// Call put the start LBA in the lbapack.
	push	$blkstartlow
	push	$blkstarthigh
	push	%ax
	call	get_lba_start
	pop	%ax
	add	$0x4,		%sp

// If an error occurred ret real quick.
	cmpw	$ENOERR,	errno
	jne	.Linit_lba_pack_fin

// Get the safe bootable partition length.
	push	%ax
	call	get_lba_safe_len
// We don't need the partition index any more,
// so there is no need to restore it.
	add	$0x2,		%sp

// Put the safe LBA length into the lbapack.
	mov	%ax,		blkcount

// If an error occurred ret real quick.
	cmpw	$ENOERR,	errno
	jne	.Linit_lba_pack_fin

.Linit_lba_pack_fin:
//	mov	%bp,		%sp
//	pop	%bp
	ret
// }
	.size	init_lba_pack,	.-init_lba_pack

.section	.data

// LBA load data.
	.align	4
	.type	lbapack,	@object
	.size	lbapack,	0x10
lbapack:

	.type	lbapackheader,	@object
	.size	lbapackheader,	0x2
// Header for the LBA load data.
lbapackheader:
// Size of packet, always 16 bytes.
	.byte	0x10
// Reserved.
	.byte	0x00
// END lbapackheader

	.type	blkcount,	@object
	.size	blkcount,	0x2
// Number of sectors to read.  Some bios only support 127,
// so we will max out there.
blkcount:
	.word	0x0000

	.type	kernelstart,	@object
	.size	kernelstart,	0x4
// Bootloader start (16-bit segment:16-bit offset).
// This we will treat as readonly.
kernelstart:
// Transfer buffer offset.
	.word	0x0000
// Transfer buffer segement.
	.word	0x0800
// END kernelstart

	.type	blkstart,	@object
	.size	blkstart,	0x8
// Start LBA (0 indexed!).  This is the start that the bootloader partion must be at.
// This is also the first valid LBA for a GPT paritions.
blkstart:

	.type	blkstartlow,	@object
	.size	blkstartlow,	0x2
// Lower 16-bits
blkstartlow:
	.word	0x0000

	.type	blkstarthigh,	@object
	.size	blkstarthigh,	0x2
// Upper 16-bits
blkstarthigh:
	.word	0x0000

	.type	blkextension,	@object
	.size	blkextension,	0x4
// Upper 32-bits for 48/64 bit LBA extension, which we won't be using.
blkextension:
	.long	0x00000000

// vim: set ts=8 sw=8 noet syn=asm:
