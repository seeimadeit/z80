.include "Routines.inc"
.include "libs.inc"

	ld hl,hello
	call print
	ld a,0
	ret ;# return to calling program


hello: .string "Hello World!\r\nAre you having a nice day?\r\nWould you like to play a game"

ENDADDRESS: