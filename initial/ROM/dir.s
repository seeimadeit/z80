
.include "Routines.inc"
.include "libs.inc"


	ld hl,dirmsg
	call println
	call directoryopen
currentfile:
	ld hl,thisfilename
	call getfilename
	call println

	ld a,(hl)
	cp 0
	jp z,_exit$1

	call directorynextfile
	jp currentfile

_exit$1:
	ret

thisfilename: .space 15
dirmsg: .string "\r\nDIRECTORY\r\n"

ENDADDRESS: