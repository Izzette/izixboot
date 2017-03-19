// mbr.s
// MBR related macros.

.file		"mbr.s"

// Start address of the MBR in memory.
	.set	mbrstart,	0x7c00

// Start address of the stage two bootloader in memory.
	.set	s2start,	0x200 + mbrstart

// vim: set ts=8 sw=8 noet syn=asm:
