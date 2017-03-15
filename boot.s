// boot.s
// MBR boot sector

// We are operating in 16-bit real mode
.code16

// Disable those pesky interupts
	cli

// Initialize the stack, hopefully this will be enough, but not too much
	mov	(stackhi),	%sp
	mov	%sp,		%bp

// Jump to the main boot code
	ljmp	$0,		$boot

// Print a string using the BIOS
// void puts (char *) {
puts:
	push	%bp
	mov	%sp,		%bp

// We're going to need this registers
	push	%si

// Move the string to the source index
	mov	4(%bp),	%si

// We are going to use the display character BIOS interupt call
	mov	$0x0e,		%ah

.Lputs_putc:
// Load the next byte into %al from the source index, then increment %si
	lodsb

// Check to see if we have reached the NULL terminating byte
	or	%al,		%al
// Finish up and return
	jz	.Lputs_fin

// Make the display character BIOS interupt call
	int	$0x10

// Do it all again
	jmp	.Lputs_putc

// Finish up the function
.Lputs_fin:

// Restore these registers
	pop	%si

	mov	%bp,		%sp
	pop	%bp
	ret
// }

// Do the thing
boot:

// Count the number of drives
count:

	// Start with the first drive
	mov	$0x80,		%dl

// Reset disk, use %dl as disk number
reset:
// Set the BIOS disk operation to reset
	mov	$0x00,		%ah
// Reset the disk
	int	$0x13

// Check for the disk
ckdisk:
// Set the BIOS disk operation to status
	mov	$0x01,		%ah
// Get the status
	int	$0x13
// If fail, we've found the number of drives
	or	%ah,		%ah
	jz	ask
// Else check the next drive
	inc	%dl
	jmp	reset

// Say the thing
ask:
	push	$prompt
	call	puts
	add	$0x4,		%sp

// Wait for any keyboard input, then got back to say
wait:

// We are going to use the read keyboard scancode BIOS interupt function
	mov	$0x00,		%ah

// Renable interupts
	sti

// Use the scancode BIOS interupt function
	int $0x16

// Wait for keyboard input
	hlt

// Disable interupts again
	cli

// Say the thing again
	jmp	ask

prompt:
	.asciz "Boot from ["
stackhi:
	.long	0x1000

// vim: set ts=8 sw=8 noet syn=asm:
