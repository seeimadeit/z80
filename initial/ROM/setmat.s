.include "Routines.inc"
.include "libs.inc"

	ld hl,params
	call getcommandparams
	call touppercase
		call strlen
		ld a,b
	
		cp 3
		jp nz, error

		ld ix,params ;# get the 1st and 2nd characters into the lobyte
		ld a,(ix)
		sub '0'
	
		ld b,a ;# flag 0 = reset, 1 = set
		ld h,(ix+1)
		ld l,(ix+2)
		call hextobyte

		call setresetpage
		ld a,0
		ret
error:
	ld hl,errormsg
	call println
	ld a,0
	ret



  errormsg: .string "syntax: setmat aXX where a = set or reset (1 or 0), XX page (see m*)"
  
	params: .space 50
ENDADDRESS: