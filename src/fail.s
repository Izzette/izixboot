// fail.s
// "fake functions" to jump to if things go wrong.

.file		"fail.s"

.code16

.section	.globals

	.globl	readerr
	.type	readerr,	@function
// Display error if a read failure occurs.
// void readerr () {
readerr:
	push	$readerrmsg
	jmp	panic
// }
	.size	readerr,	.-readerr

	.globl	baddos
	.type	baddos,		@function
// Display error if the DOS is invalid.
// void baddos () {
baddos:
	push	$baddosmsg
	jmp	panic
// }
	.size	baddos,		.-baddos

	.globl	noboot
	.type	noboot,		@function
// Display error if there is no bootable DOS partition.
// void noboot () {
noboot:
	push	$nobootmsg
	jmp	panic
// }
	.size	noboot,		.-noboot

	.globl	nomemmap
	.type	nomemmap,		@function
// Display error if there is no memmapable DOS partition.
// void nomemmap () {
nomemmap:
	push	$nomemmapmsg
	jmp	panic
// }
	.size	nomemmap,		.-noboot

	.type	panic,		@function
// Halt forever, no matter what.
// void panic () {
panic:
// Splash error.
	call	puts

.Lpanic_freeze:
	hlt
	jmp	.Lpanic_freeze
// }
	.size	panic,		.-panic

.section	.rodata

	.type	readerrmsg,	@object
// Disk failure message.
readerrmsg:
	.asciz	"Disk fail"
	.size	readerrmsg,	.-readerrmsg

	.type	baddosmsg,	@object
// Bad DOS table message.
baddosmsg:
	.asciz "Bad MBRDOS"
	.size	baddosmsg,	.-baddosmsg

	.type	nobootmsg,	@object
// Not bootable partition error message.
nobootmsg:
	.asciz	"No bootable"
	.size	nobootmsg,	.-nobootmsg

	.type	nomemmapmsg,	@object
// Failed to retrieve memory map
nomemmapmsg:
	.asciz	"No memmap"
	.size	nomemmapmsg,	.-nomemmapmsg

// vim: set ts=8 sw=8 noet syn=asm:
