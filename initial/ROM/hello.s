.include "Routines.inc"

.org userMemory

	ld a,PRINT
	call GetAddress
	ld (printadr),hl

	ld hl,hello
	call print
	ret ;# return to calling program


hello: .string "hello World!\r\nare you having a nice day\r\nwhat you like to play a game\0"



functionlookups:
	.align 2
	print: .byte 0xc3
	printadr: .2byte 0