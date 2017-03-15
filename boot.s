.code16
	cli
	ljmp	$0,	$boot
boot:
say:
	mov	$msg,	%si
	mov	$0x0e,	%ah
putc:
	lodsb
	or	%al,	%al
	jz	halt
	int	$0x10
	jmp	putc
halt:
	mov $0x00, %ah
	int $0x16
	sti
	hlt
	cli
	jmp	say
msg:
	.asciz "Hello World\r\n"
// vim: set ts=8 sw=8 noet syn=asm:
