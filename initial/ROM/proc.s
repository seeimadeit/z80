.include "Routines.inc"
.include "libs.inc"

.equ MAXPROCESSES,4
.equ PROCINFOSIZE,6

;# NOTEs: needs to delete a process, create a process, find a process by id, 
;# find a free slot, increment pid, ensure unique pid

	;# 1byte process status - 1=running, 0=no process
	;# 1byte processID
	;# 4bytes process name (lastbyte zero)
	;# ld hl,processname

ld hl,psmsg
call println

ld a,1
ld (lastprogramid),a
call writeprocessinfo
ld a,0
ret


writeprocessinfo:
# prerequisties : lastprogramid has the programid set 
#                 procname contains the name of the program (3bytes+zero)
call getprocessslot
jp nc, failed
#call printhexL
#PRINTLN
ld a,1 ;# process is running
ld (hl),a
inc hl
ld a,(lastprogramid) ;# it is required this variable is set to the correct id before running this routine
ld (hl),a
inc hl
#call printhexL
#PRINTLN

ld de,procname
ex de,hl
#call printhexL
#call println
call strcpy
ld a, 0
ret

failed:
	ld hl,errormsg
	call println
	ld a,0
	ret 

errormsg: .string "could not find an empty slot, maximum number of processes running\r\n"







#=== getprocessslot ===#
;# return the first available slot in hl
;# a slot is occuppied if the processid is not zero. this routine will locate the first unoccuppied slot
;# A register returns status where 0=no slots , 1=slot available
;# if carry flag set, a slot was found
;# if carry flag not set, it did not find an empty slot
getprocessslot:
	call Xstartprocessinfo
2$:
#	DEBUG '*'
#	PRINTLN
	call Xnextprocessinfo ;
	jp c,1$ ;# if carry flag set, we reached the end
	ld a,(hl)
#	call printhex
#	call printhexL
	cp 0 ;# compare processids
	jp nz, 2$
	#ld hl,didfind
	#call println
#	ld a,1
	scf ;#did find return set carry flag
	ret ;# found

1$: ;# not found
	#ld hl,notfound
	#call println
#	ld a,0
	scf ;# did not find return unset carry flag
	ccf
ret
	
	
	

psmsg: .string "Process info\r\n"
procname: .string "exa"





#== startprocessinfo ==#
# reset the process info list pointer
# no inputs, no outputs
Xstartprocessinfo: 
	push af
	ld a,0
	ld (currentprocessinfo),a
	pop af
	ret

#== nextprocessinfo ===#
# return in hl the next processinfo entry
# also updates currentprocessinfo
# if carry flag set, we have reach the end of the process table
Xnextprocessinfo:
	push af
	ld a,(currentprocessinfo)
	ld h,a
	ld e,PROCINFOSIZE
	call Mul8b
	ex de,hl
	ld hl,processtable
	add hl,DE
	inc a
	cp MAXPROCESSES
	jp p, 1$ ;# if we go passed the limit reset back to 0
	ld (currentprocessinfo),a
	pop af
	scf ;# set cf
	ccf ;# invert cf  - more process info's available so return with carry flag not set
	ret
1$: ;# if reach maxprocesses, return 0 in a & hl
	ld a,0
	ld (currentprocessinfo),a
	ld h,a
	ld l,a
	pop af
	scf ;# set carry flag  - if no more process return with carry flag set
	ret

lastprogramid: .byte 0
maxprocesses: .byte MAXPROCESSES
currentprocessinfo: .byte 0; # index to a process table entry
processtable: 
	;# 1byte process status - 1=running, 0=no process
	;# 1byte processID
	;# 4bytes process name
.rept MAXPROCESSES
	.space PROCINFOSIZE
.endr
endprocesstable: ;# this does nothing and can be deleted. I'm using it to check the listing address




  # ===== Mul8b 8bit multily ===#
  # http://tutorials.eeems.ca/Z80ASM/part4.htm
  Mul8b:                           ; this routine performs the operation HL=H*E
  ld d,0                         ; clearing D and L
  ld l,d
  ld b,8                         ; we have 8 bits
Mul8bLoop:
  add hl,hl                      ; advancing a bit
  jp nc,Mul8bSkip                ; if zero, we skip the addition (jp is used for speed)
  add hl,de                      ; adding to the product if necessary
Mul8bSkip:
  djnz Mul8bLoop
  ret


  #==== getprocessbyid ==#
# ld a,id
# call getprocessid
# cp 1             - returns in A : 0 = not found, 1 = found
# jp z,we succeeded
getprocessbyid:

	call startprocessinfo
2$:

	call nextprocessinfo ;
	jp c,1$ ;# if carry flag set, we reached the end
	push hl
	pop ix
	ld b,(ix+1)
	cp b ;# compare processids
	jp nz, 2$
	ld a,1
	ret ;# found

1$: ;# not found
	ld a,0
ret

ENDADDRESS: