target remote localhost:1234
set disassemble-next-line on
set architecture i8086
break *0x7c00
continue
