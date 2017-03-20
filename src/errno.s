// errno.s
// "errno" flag macros.

.file		"errno.s"

// errno flags.
	.set	ENOERR,		0x0000
	.set	EINVALDOS,	0x0001 << 0
	.set	ENOBOOTABLE,	0x0001 << 1
	.set	EREADERR,	0x0001 << 2

// vim: set ts=8 sw=8 noet syn=asm:
