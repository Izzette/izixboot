// fail.s
// "fake functions" to jump to if things go wrong.

.file		"fail.s"

.code16

.section	.text

	.globl	readerr
	.type	readerr,	@function
// Display error if a read failure occurs.
// void readerr () {
readerr:
	push	$readerrmsg
	call	puts
// There is no need to clear the stack, we've given up.
//	add	$2,		%sp
// Require manual reboot.
	jmp	freeze
// }
	.size	readerr,	.-readerr

	.globl	baddos
	.type	baddos,		@function
// Display error if the DOS is invalid.
// void baddos () {
baddos:
	push	$baddosmsg
	call	puts
// There is no need to clear the stack, we've given up.
//	add	$2,		%sp
// Require manual reboot.
	jmp	freeze
// }
	.size	baddos,		.-baddos

	.globl	noboot
	.type	noboot,		@function
// Display error if there is no bootable DOS partition.
// void noboot () {
noboot:
	push	$nobootmsg
	call	puts
// There is no need to clear the stack, we've given up.
//	add	$2,		%sp
// Require manual reboot.
	jmp	freeze
// }
	.size	noboot,		.-noboot

	.type	freeze,		@function
// Halt forever, no matter what.
// void freeze () {
freeze:
// Interupts should already be disabled
	cli
	hlt
	jmp	freeze
// }
	.size	freeze,		.-freeze

.section	.rodata

	.type	readerrmsg,	@object
// Disk failure message.
readerrmsg:
	.asciz	"Disk failure!"
	.size	readerrmsg,	.-readerrmsg

	.type	baddosmsg,	@object
// Bad DOS table message.
baddosmsg:
	.asciz "Bad DOS table!"
	.size	baddosmsg,	.-baddosmsg

	.type	nobootmsg,	@object
// Not bootable partition error message.
nobootmsg:
	.asciz	"No bootable part!"
	.size	nobootmsg,	.-nobootmsg

// vim: set ts=8 sw=8 noet syn=asm:
