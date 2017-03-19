// errno_data.s
// "errno" static value.

.file		"errno_data.s"

.code16

.section	.data

	.align	2
	.globl	errno
	.type	errno,		@object
	.size	errno,		2
errno:
	.word	errno,		0x0000

// vim: set ts=8 sw=8 noet syn=asm:
