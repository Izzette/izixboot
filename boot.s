// boot.s
// A simple MBR bootloader supporting up to 4 drives.

// We are operating in 16-bit real mode.
.code16

// Disable those pesky interupts.
	cli

// Initialize the stack.
	mov	$0x7bfe,	%sp
	mov	%sp,		%bp

// Jump to the main boot code, where ever it is.
	ljmp	$0,		$boot

// Print a string using the BIOS intrupt calls.
// void puts (const char *) {
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

// Compare string.
// short puts (const char *s1, const char *s2) {
cmpstr:
	push	%bp
	mov	%sp,		%bp

	pushl	%ebx
	pushl	%ecx
	pushl	%edx

// Move the first string to the source index.
	mov	4(%bp),		%ax
	andl	$0xffff,	%eax
// Move the second string to %eax.
	mov	6(%bp),		%bx
	andl	$0xffff,	%ebx

.Lcmpstr_cmpc:
	mov	(%eax),		%cl
	inc	%ax
	mov	(%ebx),		%dl
	inc	%bx

// if (%al < %ah) return -1;
	cmp	%cl,		%dl
	jl	.Lcmpstr_lt
// else if (%al > %ah) return 1;
	cmp	%cl,		%dl
	jg	.Lcmpstr_gt

// Check to see if we have reached the end of *both* strings.
	or	%cl,		%cl
// If so, the strings are equal, so finish up and return.
	jz	.Lcmpstr_eq

// Move onto the next character.
	jmp	.Lcmpstr_cmpc

// return -1;
.Lcmpstr_lt:
	mov	$-1,		%ax
	jmp	.Lcmpstr_fin

// return 1;
.Lcmpstr_gt:
	mov	$1,		%ax
	jmp	.Lcmpstr_fin

// return 0;
.Lcmpstr_eq:
	mov	$0,		%ax

.Lcmpstr_fin:
// Restore registers.
	popl	%edx
	popl	%ecx
	popl	%ebx

	mov	%bp,		%sp
	pop	%bp
	ret
// }

// Do the thing, Julie.
boot:

// Count the number of useble drives.
count:

// Initialize the disk index to the first disk (this disk).
	mov	$0x80,		%dl

// Reset disk, use %dl as disk index.
reset:

// Use the BIOS to reset the disk.
	mov	$0x00,		%ah
	int	$0x13

// Check if the current disk index in %dl is useable.
ckdisk:

// Get the status from the last reset operation from the BIOS.
	mov	$0x01,		%ah
	int	$0x13

// If the last reset ended in anything other than success,
// we've found the first drive index that is not useable.
	cmp	$0,		%ah
	jne	numdisks

// Increment the drive index.
	inc	%dl

// Check if we've surpased the maximum supprted drive index.
	cmp	(maxdrives),	%dl
// If we haven't check for the next drive.
	jl	reset

// Get the number of disks from the first bad disk index in %dl.
numdisks:

// Decrement the disk number so it represents the last good disk.
	dec	%dl

// Compute the number of disks, and put it in %edx
// (it has to be a valid base address).
	andl	$0xff,		%edx
	sub	$0x80,		%dx

// Ask the user to select a disk to boot from.
ask:

// Display "Boot from [".
	push	$prompt
	call	puts
	add	$2,		%sp

// If there is only one good disk to choose from,
// don't show the use a range of disks to select,
// just jump to the end of the prompt.
	cmp	$0,		%edx
	je	eask

// Show the start of the range "0-"
	push	$srange
	call	puts
	add	$2,		%sp

// Finish displaying the boot selection prompt.
eask:

// Print the last valid drive index to the console.
// Convert the drive index to a string.
	mov	numbs(,%edx,2),	%cx
// Print the drive index string.
	push	%cx
	call	puts
	add	$2,		%sp

// Print the end of the prompt "]: ".
	push	$eprompt
	call	puts
	add	$2,		%sp

// Get the drive selection from the user.
getsel:

// We are going to use the read keyboard scancode BIOS interupt function.
	mov	$0x00,		%ah

// Renable interupts, so we can listen to the keyboard input.
	sti

// Use the scancode BIOS interupt function.
	int	$0x16

// Wait for the users keyboard input.
	hlt

// Disable interupts again.
	cli

// Print the character in %al, the one just entered by the user.
// Put a null byte into %ah,
// this will terminate the string begining with %al.
	mov	$0x00,		%ah
// Push the string onto the stack.
	push	%ax
// Call puts, the stack pointer points at the
// string obtained from the keyboard scancode input.
	push	%sp
	call	puts
	add	$2,		%sp
// Pop the input string into %cx instead of ax
	pop	%cx

// Print a CRLF newline sequence.
	push	$newline
	call	puts
	add	$2,		%sp

// size_t i = numbs;
	movl	$0,		%ebx

// Get the index from the input.
cksel:

// if (NULL == numbs[i])
	mov	numbs(,%ebx,2),	%ax
	cmp	$0,		%ax
	je	inval

// Comapre cur and the keyboard input, the keyboard input is already on the stack.
	push	%cx
	push	%sp
	push	%ax
	call	cmpstr
	add	$4,		%sp
	pop	%cx


// If they are not equal try the next one.
	or	%ax,		%ax
	jz	inindex
// i++;
	inc	%bx
	jmp	cksel

inindex:
// TODO: do something.
	cmp	%bl,		%dl
	jl	inval
	push	$validmsg
	call	puts
	add	$2,		%sp
	push	$newline
	call	puts
	add	$2,		%sp
	jmp	ask

// Got invalid input from the user.
inval:

// Print "Invalid input.".
	push	$invalmsg
	call	puts
	add	$2,		%sp
// Print CRLF.
	push	$newline
	call	puts
	add	$2,		%sp

// Try again
	jmp	ask

// The begaining of the boot selection prompt string.
prompt:
	.asciz "Boot from ["

// The begining of the range of bootable drives.
srange:
	.asciz "0-"

// The end of the boot selection prompt string.
eprompt:
	.asciz "]: "

invalmsg:
	.asciz "Invalid input."

validmsg:
	.asciz "Valid input :)"

// A CRLF newline
newline:
	.asciz "\r\n"

// The exclusive maximum drive index supported.
maxdrives:
	.word	0x84

// A NULL-terminated array of digit strings up to 4.
	.align	2
numbs:
	.word	.nums_0
	.word	.nums_1
	.word	.nums_2
	.word	.nums_3
	.word	0
.nums_0:
	.string	"0"
.nums_1:
	.string	"1"
.nums_2:
	.string	"2"
.nums_3:
	.string	"3"

// vim: set ts=8 sw=8 noet syn=asm:
