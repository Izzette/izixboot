// stdio.s
// Input and output.

.file		"stdio.s"

.code16

.section	.text

	.globl	puts
	.type	puts,		@function
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
	.size	puts,		.-puts

// vim: set ts=8 sw=8 noet syn=asm:
