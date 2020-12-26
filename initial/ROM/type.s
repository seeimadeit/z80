
.include "Routines.inc"
.include "libs.inc"

	ld hl,msg
	call println
	ld hl,params
	call getcommandparams
	call println
	ld de,dumparea
	ld hl,params
	ld a,1 ;# ask for zero terminated
	call loadfile
	cp 0
	jp nz,error
	ld hl,dumparea
	call println
	jp _exit

_error: 
	ld hl,error
	call println
_exit:
	ld a,0
	ret


msg: .string "the params are:"
error: .string "failed to load the file."
params: .space 50

;# this program does not work correctly with the memory management - this will need to be fixed in the near future
ENDADDRESS:
dumparea: .space 1 ;# this is not correct the loadfile will expand passed this