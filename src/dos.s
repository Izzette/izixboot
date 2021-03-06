// dos.s
// Working with MS-DOS partition table.

.include	"mbr.s"
.include	"errno.s"
.include	"bool.s"

.file		"dos.s"

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
// %dx will be overwritten by mul, but restoring it can be optionally disabled
// by setting savedx to $false.
.macro	getpart	part_index savedx=$true
.if	$true == \savedx
	push	%dx
.endif

// Put part_index in %ax
	mov	\part_index,	%ax

// Compute the offset from dosstart.
	mov	$doslen,	%dx
// High order bits will be stored in %dx,
// They should however be safe to ignore.
	mul	%dx

// Add the dosstart address to the offset.
// %ax now contains the start address of that partition.
	add	$dosstart,	%ax

.if	$true == \savedx
	pop	%dx
.endif
.endm

.code16

.section	.stage2

	.global	find_bootable
	.type	find_bootable,	@function
// Find the bootable DOS partition index.
// Sets the $EINVALDOS errno flag if the DOS partition is invalid.
// Sets the $ENOBOOTABLE errno flag if the DOS partition does not
// contain a bootable partition.
// uint16_t find_bootable () {
find_bootable:
// There is no need to mess with the stack, this function accepts no arguments.
//	push	%bp
//	mov	%sp,		%bp

// Save registers.
	push	%bx

// Start at zero.
	xor	%bx,		%bx

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
	movw	$ENOBOOTABLE,	errno
	jmp	.Lfind_bootable_fin

.Lfind_bootable_ret:
// Found a bootable partition, return it.
	mov	%bx,		%ax
//	jmp	.Lfind_bootable_fin

.Lfind_bootable_fin:
// Restore registers.
	pop	%bx

//	mov	%bp,		%sp
//	pop	%bp
	ret
// }
	.size	find_bootable,	.-find_bootable

	.globl	get_lba_start
	.type	get_lba_start,	@function
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
// The second argument to getpart is "savedx", which if set to $false will not save %dx.
// We do not need to save %dx, because it is not in use by this function, but has already
// been saved.
	getpart	0x4(%bp), $false

// LBA start address of the partition is not 4-byte aligned,
// so we need to do it in two steps.  This also keeps compatibility,
// with 16-bit only CPUs, not that it matters.

// Fetch the low-order two bytes from the LBA start.
	mov	doslbast(%eax),	%bx

// Fetch the high-order two bytes of the LBA start.
// We're done with %ax now, so we'll reusse it.
	mov	doslbast+0x02(%eax), %ax

// Get the address of our high order bits.
	mov	0x6(%bp),	%dx
// Move the high order bits to our lbapack.
	mov	%ax,		(%edx)

// Get the address of our low order bits.
	mov	0x8(%bp),	%dx
// Move the low order bits to our lbapack
	mov	%bx,		(%edx)

// Restore registers.
	pop	%dx
	pop	%bx

	mov	%bp,		%sp
	pop	%bp
	ret
// }
	.size	get_lba_start,	.-get_lba_start

	.global	get_lba_safe_len,
	.type	get_lba_safe_len, @function
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

// Fetch the low-order two bytes from the LBA length.
	mov	doslbalen(%eax), %bx

// We're done with %ax now, so we'll reuse it.
	mov	doslbalen+0x02(%eax), %ax

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
	.size	get_lba_safe_len, .-get_lba_safe_len

	.type	is_bootable,	@function
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

// Move the bootable flag to %al.
	mov	dosboot(%eax),	%bl

// Is it bootable.
	cmp	$dosbootflag,	%bl
	je	.Lis_bootable_yes

// Is it not bootable.
	cmp	$dosnobootflag,	%bl
	je	.Lis_bootable_no

// Otherwise it's invalid, so fail.
	movw	$EINVALDOS,	errno
// The return value doesn't matter, becuase we've set errno.
//	jmp	.Lis_bootable_fin

.Lis_bootable_no:
	mov	$false,		%ax
	jmp	.Lis_bootable_fin

.Lis_bootable_yes:
	mov	$true,		%ax
//	jmp	.Lis_bootable_fin

.Lis_bootable_fin:
// Restore registers.
	pop	%bx

	mov	%bp,		%sp
	pop	%bp
	ret
// }
	.size	is_bootable,	.-is_bootable

// vim: set ts=8 sw=8 noet syn=asm:
