// boot.s
// MBR boot sector

// We are operating in 16-bit real mode
.code16

// Disable those pesky interupts
	cli

// Jump to the main boot code
	ljmp	$0,	$boot

// Do the thing
boot:

// Say the thing
say:

// Move the message to the source index
	mov	$msg,	%si

// We are going to use the display character BIOS interupt call
	mov	$0x0e,	%ah

// Print one character to the console
putc:

// Load the next byte into %al from the source index, then increment %si
	lodsb

// Check to see if we have reached the NULL terminating byte
	or	%al,	%al
// Jump to wait if we have
	jz	wait

// Make the display character BIOS interupt call
	int	$0x10

// Do it all again
	jmp	putc

// Wait for any keyboard input, then got back to say
wait:

// We are going to use the read keyboard scancode BIOS interupt function
	mov $0x00, %ah

// Renable interupts
	sti

// Use the scancode BIOS interupt function
	int $0x16

// Wait for keyboard input
	hlt

// Disable interupts again
	cli

// Say the thing again
	jmp	say

msg:
	.asciz "Hello World\r\n"

// vim: set ts=8 sw=8 noet syn=asm:
