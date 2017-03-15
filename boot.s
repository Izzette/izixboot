.code16
	cli
	ljmp	$0,	$boot
boot:
	mov	$msg,	%si
	mov	$0x0e,	%ah
say:
	lodsb
	or	%al,	%al
	jz	halt
	int	$0x10
	jmp	say
halt:
	hlt
msg:
	.asciz "Hello World"
// vim: set ts=8 sw=8 noet syn=asm:
