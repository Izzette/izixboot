// boot.s
// A simple MBR bootloader supporting up to 4 drives.

/* ******************************* */
/* *********** MACROS ************ */
/* ******************************* */

// "bool.h"
.set	true,		1
.set	false,		0

// errno flags.
.set	ENOERR,		0x00
.set	EINVALDOS,	0x01 << 0
.set	ENOBOOTABLE,	0x01 << 1
.set	EZEROPARTLEN,	0x01 << 2
.set	EREADERR,	0x01 << 3

// Start address of the MBR in memory.
.set	mbrstart,	0x7c00
// Start address of the stage two bootloader in memory.
.set	s2start,	0x200 + mbrstart
// Start address of the DOS partition table in memory.
.set	dosstart,	0x01be + mbrstart

// Maximum DOS partitions, exclusive.
.set	dosmaxpart,	4
// The length of each DOS partition entry.
.set	doslen,		0x10
// Bootable flags for DOS partition
.set	dosnobootflag,	0x00
.set 	dosbootflag,	0x80
// DOS partition bootable byte offset.
.set	dosboot,	0x00
// DOS partition LBA start offset.  NOT ALIGNED.
.set	doslbast,	0x08
// DOS partition LBA total length.  NOT ALIGNED.
.set	doslbalen,	0x0c

// Safe LBA max to read with bios
.set	lbasafemax,	0x7f

// Get DOS partition address.
// Addess will be left in %ax.
.macro getpart part_index
// Store %bx.
	push	%bx
	push	%dx

// Put part_index in %bx
	mov	\part_index,	%ax

// Compute the offset from dosstart.
	mov	$doslen,	%bx
// High order bits will be stored in %dx,
// They should however be safe to ignore.
	mul	%bx

// Add the dosstart address to the offset.
// %bx now contains the start address of that partition.
	add	$dosstart,	%ax

// Restore %bx.
	pop	%dx
	pop	%bx
.endm

// We are operating in 16-bit real mode.
.code16

/* ******************************* */
/* *********** STAGE 1 *********** */
/* ******************************* */

.section .stage1

_start:
// Disable those pesky interupts.
	cli

// Initialize the stack.
	mov	$mbrstart,	%sp
	mov	%sp,		%bp

// Drive index should be in %dl already.
//	xchg	%dl,		%dl

// Initialize errno
	movw	$ENOERR,	errno

// Load the second stage bootloader.
	push	%dx
	call	load_stage2
	add	$2,		%sp

// If something goes wrong splash read error.
	cmp	$ENOERR,	errno
	jne	readerr

// call to the main boot code with the drive index.
	push	%dx
	call	boot
// This function should never return.
//	add	$2,		%sp

// Reset the drive.
// void reset_drive(const uint16_t drive_index) {
reset_drive:
	push	%bp
	mov	%sp,		%bp

// Store registers.
	push	%dx

// Drive index to reset.
	mov	0x4(%bp),	%dx

// int 13h ah=0h, reset disk
	mov	$0,		%ah
	int	$0x13

// Restore registers.
	pop	%dx

	mov	%bp,		%sp
	pop	%bp
	ret
// }

// Load the stage2 bootloader from CHS (0,0,2)
// Sets the $EREADERR flag if something goes wrong.
// void load_stage2 (const uint16_t drive_index) {
load_stage2:
	push	%bp
	mov	%sp,		%bp

// Store registers.
// TODO: do we really need to save %es?
	push	%es
	push	%bx
	push	%cx
	push	%dx

// Drive index.
	mov	0x4(%bp),	%dx

// Reset the drive
	push	%dx
	call	reset_drive
	add	$2,		%sp

// Read into memory.
	mov	$2,		%ah
// Drive to read.  %dl should already be correct.
//	xchg	%dl,		%dl
// Cylinder number.
	mov	$0,		%ch
// Head number.
	mov	$0,		%dh
// Sector number (1 indexed!)
	mov	$2,		%cl
// Number of sectors to read.
	mov	$1,		%al
// Segement to read to.
// First segment.
	push	$0
	pop	%es
// Immediately after MBR.
	mov	$s2start,	%bx
// int 13h ah=2h, read CHS into memory.
	mov	$0x2,		%ah
	int	$0x13

// Set the $EREADERR errno flag if something goes wrong.
	jc	.Lload_stage2_readerr
	or	%ah,		%ah
// If all looks good return.
	jz	.Lload_stage2_fin
// 	jmp	.Lload_stage2_readerr

.Lload_stage2_readerr:
	orw	$EREADERR,	errno
//	jmp	.Lload_stage2_fin

.Lload_stage2_fin:
// Restore registers.
	pop	%dx
	pop	%cx
	pop	%bx
	pop	%es

	mov	%bp,		%sp
	pop	%bp
	ret
// }

// Print a string using the BIOS intrupt calls.
// void puts (const uint16_t *str) {
puts:
	push	%bp
	mov	%sp,		%bp

// TODO: do we really need to save this register?
	push	%si

// Move the string to the source index.
	mov	4(%bp),		%si

// We are going to use the display character BIOS interupt call.
	mov	$0x0e,		%ah

// Print a character to the console.
.Lputs_putc:

// Load the next byte into %al from the source index, then increment %si.
	lodsb

// Check to see if we have reached the NULL terminating byte yet.
	or	%al,		%al
// If so, finish up and return.
	jz	.Lputs_fin

// Display the character is %al.
	int	$0x10

// Print the next character.
	jmp	.Lputs_putc

// Finish up the puts function.
.Lputs_fin:

// Restore the source index.
	pop	%si

	mov	%bp,		%sp
	pop	%bp
	ret
// }

// Halt forever, no matter what.
freeze:
	hlt
	jmp	freeze

// Display error if something goest wrong.
readerr:
	push	$readerrmsg
	call	puts
// There is no need to clear the stack, we've given up.
//	add	$2,		%sp
// Require manual reboot.
	jmp	freeze

baddos:
	push	$baddosmsg
	call	puts
// There is no need to clear the stack, we've given up.
//	add	$2,		%sp
// Require manual reboot.
	jmp	freeze

noboot:
	push	$nobootmsg
	call	puts
// There is no need to clear the stack, we've given up.
//	add	$2,		%sp
// Require manual reboot.
	jmp	freeze

/* ****************************** */
/* ************ DATA ************ */
/* ****************************** */

// NOTE: The data segment goes into the MBR along with .stage1.

// Valid input booting message.
validmsg:
	.asciz	"Booting ...\r\n"

// Disk failure message.
readerrmsg:
	.asciz	"Disk failure!"

// Bad DOS table message.
baddosmsg:
	.asciz "Bad DOS table!"

// Not bootable partition error message.
nobootmsg:
	.asciz	"No bootable part!"

// Unknown failure
//unknownmsg:
//	.asciz	"Fail?"

// Errno, like C.
errno:
	.word	0x00

// LBA load data.
	.align	4
lbapack:
// Size of packet.
	.byte	0x10
// Reserved.
	.byte	0x00
// Number of sectors to read.  Some bios only support 127,
// so we will max out there.
blkcount:
	.word	0x0000
// Bootloader start (16-bit segment:16-bit offset).
// This we will treat as readonly.
kernelstart:
// Transfer buffer offset.
	.word	0x0000
// Transfer buffer segement.
	.word	0x07f0
// Start LBA (0 indexed!).  This is the start that the bootloader partion must be at.
// This is also the first valid LBA for a GPT paritions.
blkstart:
// Lower 32-bits
blkstartlow:
	.word	0x0000
blkstarthigh:
	.word	0x0000
// Upper 32-bits, which we won't be using.
	.long	0x00000000


/* ******************************* */
/* *********** STAGE 2 *********** */
/* ******************************* */

.section .stage2

// NOTE: The stage2 segment goes after MBR containing .stage1 and .data.

// Is the DOS partition index bootable (index: 0-3)?
// Sets the $EINVALDOS errno flag if the bootable flag is anything but
// $dosbootflag or $dosnobootflag.
// bool is_bootable (const uint16_t part_index) {
is_bootable:
	push	%bp
	mov	%sp,		%bp

// Store bx
	push	%bx

// Get the partition address from the part_index.
// It will be left in %ax.
	getpart	0x4(%bp)

// Start address of bootable flag.
// Should be zero, so omit.
//	add	$dosboot,	%ax

// Move the bootable flag to %al.
	mov	(%eax),		%bl

// Is it bootable.
	cmp	$dosbootflag,	%bl
	je	.Lis_bootable_yes

// Is it not bootable.
	cmp	$dosnobootflag,	%bl
	je	.Lis_bootable_no

// Otherwise it's invalid, so fail.
	orw	$EINVALDOS,	errno
	jmp	.Lis_bootable_fin

.Lis_bootable_yes:
	mov	$true,		%ax
	jmp	.Lis_bootable_fin

.Lis_bootable_no:
	mov	$false,		%ax
//	jmp	.Lis_bootable_fin

.Lis_bootable_fin:
// Restore registers.
	pop	%bx

	mov	%bp,		%sp
	pop	%bp
	ret
// }

// Find the bootable DOS partition index.
// Sets the $EINVALDOS errno flag if the DOS partition is invalid.
// Sets the $ENOBOOTABLE errno flag if the DOS partition does not
// contain a bootable partition.
// uint16_t find_bootable () {
find_bootable:
	push	%bp
	mov	%sp,		%bp

// Save registers.
	push	%bx

// Start at zero.
	mov	$0x0,		%bx

.Lfind_bootable_trypart:
// Check if the current part_index is bootable
	push	%bx
	call	is_bootable
	add	$0x2,		%sp

// Error occurred, finish up real quick.
	cmpw	$ENOERR,	errno
	jne	.Lfind_bootable_fin

// If it is, return it.
	cmp	$true,		%ax
	je	.Lfind_bootable_ret

	inc	%bx
	cmp	$dosmaxpart,	%bx
	jl	.Lfind_bootable_trypart

// We could not find a bootable partition, error.
	orw	$ENOBOOTABLE,	errno
	jmp	.Lfind_bootable_fin

.Lfind_bootable_ret:
// Found a bootable partition, return it.
	mov	%bx,		%ax
//	jmp	.Lfind_bootable_fin

.Lfind_bootable_fin:
// Restore registers.
	pop	%bx

	mov	%bp,		%sp
	pop	%bp
	ret
// }

// Find the start address of a DOS partition.
// void get_lba_start(const uint16_t part_index, uint16_6 *high_dest, uint16_t *low_dest) {
get_lba_start:
	push	%bp
	mov	%sp,		%bp

// Store registers.
	push	%bx
	push	%dx

// Get the partition address from the part_index.
// It will be left in %ax.
	getpart	0x4(%bp)

// Add the offset for the LBA start to the partition address.
	add	$doslbast,	%ax

// LBA start address of the partition is not 4-byte aligned,
// so we need to do it in two steps.  This also keeps compatibility,
// with 16-bit only CPUs, not that it matters.

// Fetch the low-order two bytes from the LBA start.
	mov	(%eax),		%bx

// Fetch the high-order two bytes of the LBA start.
	add	$0x02,		%ax
// We're done with %ax now, so we'll reusse it.
	mov	(%eax),		%ax

// Get the address off our high order bits.
	mov	%bp,		%dx
	add	$0x6,		%dx
	mov	(%edx),		%dx
// Move the high order bits to our lbapack.
	mov	%ax,		(%edx)

// Get the address off our low order bits.
	mov	%bp,		%dx
	add	$0x8,		%dx
	mov	(%edx),		%dx
// Move the low order bits to our lbapack
	mov	%bx,		(%edx)

// Restore registers.
	pop	%dx
	pop	%bx

	mov	%bp,		%sp
	pop	%bp
	ret
// }

// Get the length (maxed to 0x7f) of the DOS partition.
// uint16_t get_lba_safe_len(const uint16_t part_index) {
get_lba_safe_len:
	push	%bp
	mov	%sp,		%bp

// Store registers.
	push	%bx

// Get the partition address from the part_index.
// It will be left in %ax.
	getpart	0x4(%bp)

// Add the offset for the LBA start to the partition address.
	add	$doslbalen,	%ax

// Fetch the low-order two bytes from the LBA length.
	mov	(%eax),		%bx

// Fetch the high-order two bytes of the LBA start.
	add	$0x02,		%ax
// We're done with %ax now, so we'll reusse it.
	mov	(%eax),		%ax

// Now we'll max out the value at 0x7f.

// If there is anything but zero %ax, it's larger.
	or	%ax,		%ax
	jnz	.Lget_lba_safe_len_greater

// If %bx is larger than $lbasafeamx, it's larger.
	cmp	$lbasafemax,	%bx
	jg	.Lget_lba_safe_len_greater

// Otherwise it's in the safe range, and we will use it.
	mov	%bx,		%ax
	jmp	.Lget_lba_safe_len_fin

.Lget_lba_safe_len_greater:
	mov	$lbasafemax,	%ax
//	jmp	.Lget_lba_safe_len_fin

.Lget_lba_safe_len_fin:
// Restore registers.
	pop	%bx

	mov	%bp,		%sp
	pop	%bp
	ret
// }

// Intialize the lbapack.
// Sets the $EINVALDOS errno flag if the DOS partition is invalid.
// Sets the $ENOBOOTABLE errno flag if the DOS partition does not
// void init_lba_pack () {
init_lba_pack:
	push	%bp
	mov	%sp,		%bp

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

// Put the safe LBA length into the lbapack.
	mov	%ax,		blkcount

// If an error occurred ret real quick.
	cmpw	$ENOERR,	errno
	jne	.Linit_lba_pack_fin

.Linit_lba_pack_fin:
	mov	%bp,		%sp
	pop	%bp
	ret
// }

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

// Do the thing, Julie.
// void boot(uint16_t *driveindex) {
boot:
// This function should never return,
// so forget about saving the base pointer.
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
	push	%dx
	call	load_kernel
	add	$2,		%sp

// If an error occured, it's because the BIOS failed to read the drive.
	cmpw	$ENOERR,	errno
	jne	readerr

// TODO: do something.
	jmp	freeze

// Hopefully, we will never reach here,
//	jmp	.Lboot_fin

//.Lboot_fin:
//	push	$unknownmsg
//	call	puts
// There is no need to clear the stack, we've given up.
//	add	$2,		%sp

// This function should never return,
// so forget about restoring the stack and base pointers.
//	mov	%bp,		%sp
//	pop	%bp
//	ret

// If all else fails, freeze forever.
//	jmp	freeze
// }

// vim: set ts=8 sw=8 noet syn=asm:
