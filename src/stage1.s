// stage1.s
// Stage 1 MBR boot-loader.

.include	"errno.s"
.include	"mbr.s"

.file		"stage1.s"

.code16

.section	.stage1

	.globl	stage1
	.type	stage1,		@function
// The stage1 bootloader whose job is to load and execute stage 2.
// void stage1 (const uint8_t *drive_index) {
stage1:
// This function doesn't return, so forget about saving the base pointer.
// Thsi will of course change the offset of variables in the stack.
//	push	%bp
	mov	%sp,		%bp

// The drive index.
	mov	0x2(%bp),	%dx

// Load the second stage bootloader.
	push	%dx
	call	load_stage2
	add	$2,		%sp

// If something goes wrong splash read error.
	cmp	$ENOERR,	errno
	jne	readerr

// call to the main boot code with the drive index.
	push	%dx
	call	stage2
// This function should never return.
//	add	$2,		%sp

//	mov	%bp,		%sp
//	pop	%sp
//	ret
// }
	.size	stage1,		.-stage1

	.type	load_stage2,	@function
// Load the stage2 bootloader from CHS (0,0,2)
// Sets the $EREADERR flag if something goes wrong.
// void load_stage2 (const uint8_t drive_index) {
load_stage2:
	push	%bp
	mov	%sp,		%bp

// Store registers.
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
	movw	$EREADERR,	errno
//	jmp	.Lload_stage2_fin

.Lload_stage2_fin:
// Restore registers.
	pop	%dx
	pop	%cx
	pop	%bx

	mov	%bp,		%sp
	pop	%bp
	ret
// }
	.size	load_stage2,	.-load_stage2

// vim: set ts=8 sw=8 noet syn=asm:
