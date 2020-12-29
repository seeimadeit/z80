.include "Routines.inc"
.include "libs.inc"


;# NOTEs: needs to delete a process, create a process, find a process by id, 
;# find a free slot, increment pid, ensure unique pid

	;# 1byte process status - 1=running, 0=no process
	;# 1byte processID
	;# 4bytes process name (lastbyte zero)
	;# ld hl,processname

	ld hl,psmsg
	call println

	ld hl,idmsg
	call print
	call getprocid
	call printhex
	PRINTLN

  
	call startprocessinfo
2$:
#	DEBUG '*'
#	PRINTLN
	call nextprocessinfo ;
	jp c,1$ ;# if carry flag set, we reached the end
	ld a,(hl)
	cp 0
	jp z,2$
	call putc ;# display status
	ld a,' '
	call putc
	inc hl
	ld a,(hl)
	call printhex ;# display process id
	ld a,' '
	call putc
	inc hl
	#call printhexL
	ld b,4
3$: ld a,(hl)
	call putc ;# display process name
	inc hl
	djnz 3$
	ld a,' '
	call putc
	push hl
	pop ix
	ld h,(ix+0) ;# load the baseaddress
	ld l,(ix+1)
	call printhexL
	push ix
	pop hl
	inc hl ;# adjust the pointer
	inc hl

	PRINTLN
	jp 2$
1$:
	ld a,0
	ret

	psmsg: .string "Process info\r\n"
	idmsg: .string "this processID: "
ENDADDRESS: