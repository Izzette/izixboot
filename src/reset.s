// reset.s
// Function for resetting a drive.

.file		"reset.s"

.code16

.section	.text

	.globl	reset_drive
	.type	reset_drive,	@function
// Reset the drive.
// void reset_drive(const uint16_t drive_index) {
reset_drive:
	push	%bp
	mov	%sp,		%bp

// Store registers.
	push	%dx

// Drive index to reset.
	mov	0x4(%bp),	%dx

// int 13h ah=0h, reset disk.
	mov	$0,		%ah
	int	$0x13

// Restore registers.
	pop	%dx

	mov	%bp,		%sp
	pop	%bp
	ret
// }
	.size	reset_drive,	.-reset_drive

// vim: set ts=8 sw=8 noet syn=asm:
