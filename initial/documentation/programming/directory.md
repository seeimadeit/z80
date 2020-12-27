[index.md](index.md)
# directory utils

**directoryopen** - no inputs , outputs  
    opens the directory  
    
**directorynextfile** - no inpts , no outputs  
    advances to the next file  
    
**getfilename**  
    return the current filename in the HL register pair  
	;# === getfilename of currently open file ===#  
	;# ld hl,storagelocation - for the filename  
	;# call getfilename  


```
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
```
