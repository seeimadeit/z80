


#define LOWORD(l) ((WORD)(l))
#define HIWORD(l) ((WORD)(((DWORD)(l) >> 16) & 0xFFFF))
#define LOBYTE(w) ((BYTE)(w))
#define HIBYTE(w) ((BYTE)(((WORD)(w) >> 8) & 0xFF))
# process table - maximum number of entries - which also means the maximum number of processes
.set MAXPROCESSES,4
.set PROCINFOSIZE,6

.include "SDCARD.inc"
.include "Routines.inc"


	.org 0x800
	jp boot
	.align 2
	start:
	jp loadaddress
	
boot:
	ld sp,0xffff

	di
	ld hl,readymsg
	call print
		;ld b, endlabel2-label2
		;ld c,SERIALPORT
		;otir
		
		im 2 ;/* interrupt mode 2*/
		ld a, jumptable/256 ;// hibyte
		ld i,a
		ei   ;#/* enable interrupts*/

		ld hl,loadedmsg
		call print
		#== ******* Command processor Loop ******** ==# I THINK THIS NEEDS A REVIEW IT SHOULD BE USING CREATEPROCESS
	commandprocessloop:	
		ld hl,commandprocessor
#		ld de,commandMemory
		ld de,0
		call loadFILE
		cp 0
		jp nz,errorloading
		ld (_cmdlne),hl ;# save the load address
		ld hl,0
		call println
#		call commandMemory # run the file just loaded.
		call commandline
		jp commandprocessloop

	errorloading:
		call printhex
		ld hl,errorloadingmsg
		call println
		jp commandprocessloop

commandline: .byte 0xc3
	_cmdlne: .2byte 0

		#======================suboutines===============================================#
	# === memset === #
		# ld hl, address to start
		# ld a,0 byte to write into address
		# ld b,1 count of bytes to write
	memset:
		push af
		push hl
	_metset$1:
		ld (hl),a
		inc hl
		djnz _metset$1
		pop hl
		pop af
		ret
	#== strlen ==#
		# ld hl, address to start
		# call strlen
		# return len in b
	strlen:
		push hl
		push af
	
		ld b,0
	_strlen$:
		ld a,(hl)
		cp 0
		jp z, strlenexit
		inc b
		inc hl
		jp _strlen$:
	strlenexit:
	;#	ld a,b
	;#	call printhex
		pop af
		pop hl
		ret

	#=== strncpy ==#
	;# copy from source into destination size bytes. no validation is done.
	;# ld hl, source
	;# ld de, destination
	;# ld bc, size
	;# this will copy binary strings??? so this needs fixing to stop on a null byte

	strncpy:
		ldir
		ret

	# === strcpy == #
	;# copy from source into destination string is zero terminated, no validation is done
	;# ld hl,source
	;# ld de,destination
	;# call strcpy
	strcpy:
		push af
		push hl
		push de
	_1$:
		ld a,(hl)
		ld (de),a ;# copy the potential zero before we test because we will need it
		cp 0
		jp z, _strcpyexit$1

		inc de
		inc hl
		jp _1$
	
	_strcpyexit$1:
		pop de
		pop hl
		pop af
		ret
		# === touppercase ==#
	;#		ld hl,cmd  - zero terminated string
	;#		call touppercase
	;#		ret
	;# the P flag means the comparison was Positive
	;# the M flags means the comparision was Negative
	;# the Z flag means the comparison was equal
	;# the NZ flag means the comparison was not equal.
	;# where:
	;#    A = x  P Positive
	;#			 Z Zero
	;#
	;#    A < x	 M Negative
	;#			 NZ Not zero
	;#
	;#	  A > x  P Positive
	;#			 NZ Not zero
	;#
	;# so a test for JP P,meansSameOrGreater


touppercase:
	push af
	push hl
	
goagain:
	ld a,(hl)
	cp 'a'
	jp p, converttouppercaseletter ;# is same or greater then 'a'
;# the instructions commented out are implied
	;#cp 'A'
	;#jp p, nextcharacter ;# is same or greater
	;#cp '0'
	;#jp p, nextcharacter
	;# jp nextcharacter replaces the above 4 lines
	jp nextcharacter

converttouppercaseletter:
	sub 32
	ld (hl),a
nextcharacter:
	inc hl
	ld a,(hl)
	cp 0
	jp nz,goagain	

	pop hl
	pop af

	ret
	# === PRINTLN == #
	println: ;// same as print but appends CRLF
	call print
	push hl
	push af
	ld hl,crlf
	call print
	pop af
	pop hl
	ret

	# === PRINT === #
	print: ;// expecting a zero terminated string
		push hl
		push af
		;# hl can be null so check for that first
		ld a,h
		cp 0
		jp nz,_$1 ;# hibyte not null, no just print it
		ld a,l
		cp 0
		jp z,_$2 ;# lobyte is null and hibyte is null so just exit
		_$1:
			ld a,(hl)
			cp 0
			jr z,_$2
			out (SERIALPORT),a
			inc hl
			jp _$1
_$2:			
		pop af
		pop hl
		ret
;#=== printhexL ===#
;# ld hl,passwords
;# call printhexL

printhexL:
	push af
	push hl
	ld a,h
	call printhex
	ld a,l
	call printhex
	pop hl
	pop af
	ret
# === PRINTHEX === #
		;Display 8-bit number in hex.
		; 	ld a,0xaa
	;       call printhex
printhex:

; Input: a

  push af
  ;// remove low nibble
   rra
   rra
   rra
   rra
   call  _$
   ;// restore low nibble
   pop af
   
_$:
	push af
	;// remove high nibble
   and  0x0F
   add  a,0x90
   ;; bcd adjust
   daa
   adc  a,0x40
   daa
   out (SERIALPORT),a 
   pop af
   ret

# === putc ===== #
;# ld a,'*'
;# call putc
;# no return value
putc:
		out (SERIALPORT),a
		ret

		;// end subroutines
# === loadFILE === #
; ld hl, filename (zero terminated)
; ld de, memory address to load file into
; call loadFILE
; returns 
;	HL
;		baseaddress of the dll
;	A register 
;			2 = failed to open the file
;			0 = if file loaded into memory
;	DE register pair
;			count of bytes loaded
loadFILE:
	push af
	push de ; save de for later
	call sizereset
	ld a,0 ;# erase the executable header information
	ld (startaddress),a
	ld (startaddress+1),a
	ld (startaddress+2),a
	ld (startaddress+3),a
		; try to open the SD card and read some data
		ld a,FILENAMECLEAR ; // filenameclear
		out (SDCARD),a


;
_$getnextchar:
		ld a,(hl)
		cp 0
		jp z, _$openfile #; if filename character is null we have finished
		ld a,FILENAMEAPPEND
		out (SDCARD),a ; // filenameappend
		ld a,(hl)
		out (SDCARD),a
		;#out (SERIALPORT),a
		inc hl
		jp _$getnextchar

_$openfile:
#openfile will return 1 if the file was opened, 0 if it failed to open
		ld a,OPEN	;// Open
		out (SDCARD),a
		in a,(SDCARD)
		pop hl ; get load address - must pop the stack before returning
		cp 0
		jp nz,testloadaddress
		pop af ;# a flag not needed now
		call sizeloaded
		ld a,2 ;we have an error trying to open the file.
		ret
testloadaddress:
	# if loadaddress (hl) = 0, then the file will have load address information in the 1st 2 bytes
	ld a,0
	cp h
	jp nz,available ;# h is not zero so it must have an address to load into already
	cp l
	jp nz,available ;# l is not zero so it must have an address to load intop already

	ld hl,startaddress ;# this is the place to store the 2 bytes we need to get at the load address
	call loadheader
	cp 1
	jp nz,_4$

	ld hl,(startaddress)
	inc hl ;#start address
	inc hl
	inc hl ;# program size in pages
	inc hl ;# stack size in pages
	ld (startaddress),hl ;# this is now the dll entry point address, will need this later to initialize the library

	ld a,(memorypages)
	ld b,a
	ld a,h

45$:	DEBUGHEX a
	DEBUG '\n'

	call reservemalloc
	inc a
	djnz 45$

	jp available
_4$:
	ld a,3 ;#new error code
	ret
	#if we reach here then the first 2 bytes have the address information so let read them now
	;# header information
	;# 2bytes program load address
	;# 1byte memory required in pages
	;# 1byte stack required in pages
loadheader:
	ld b,4
	ld c,0
_2$:
	ld a, AVAILABLE
	out (SDCARD),a
	in a,(SDCARD) ;# is data available?
	cp 0
	jp nz,_1$
	pop af ;#restore af
	ld hl,0
		call println
		call sizeloaded
		ld a,0 ;# use 0 in A to indicate a fail
		ret ;#- exit loadheader because the file read had a problem
_1$:
		;// if we get here then there is data to read
		ld a,READNEXTBYTE
		out (SDCARD),a ;// read nextbyte
		in a,(SDCARD)
		ld (hl),a ; // store byte in RAM (OSLOAD)
		inc hl 
		djnz _2$
		ld a,1 ;# use 1 in A to indicate a success
		ret ;# exit loadheader because we have loaded 4 bytes
available:
	#available will return 1 if there is data to read, 0 if no data to read
		ld a, AVAILABLE ; // available
		out (SDCARD),a
		in a,(SDCARD) ;// read the value from the device
	;	ld b,a ; // going to malipulate the a register so save it as not to destroy the A result
	;	add a,'0' ;// make it printable
	;	out (SERIALPORT),a ;// print response
	;	ld a,b
		cp 0 ;// compare the A reg returned by the device
		jp nz,_$nextbyte
		pop af ;# restore the af registers because it will tell me if I need to zero terminate the loaded file
		cp 1
		jp nz,_1$
		;# the hl register pair contains the last address we need to write a zero here because the user wants it
		ld a,0
		ld (hl),a ;# zero terminated

_1$:
		ld hl,0
		call println
		call sizeloaded
		ld hl,(startaddress) ;# return the startaddress
		ld a,0
		ret
_$nextbyte:
		;// if we get here then there is data to read
		ld a,READNEXTBYTE
		out (SDCARD),a ;// read nextbyte
		in a,(SDCARD)
		ld (hl),a ; // store byte in RAM (OSLOAD)
		inc hl 
		ld a,'#'
		out (SERIALPORT),a ;// just echo it back for now
		call sizeincrement
		jr available ;

sizeloaded:
	push ix
	ld ix,losize
	ld e,(ix)
	ld d,(ix+1)
	pop ix
	ret
sizereset:
	push ix
	push af
	ld a,0
	ld ix,losize
	ld (ix),a
	ld (ix+1),a
	pop af
	pop ix
	ret
sizeincrement:
	push ix
	push hl

	ld ix,losize
	ld l,(ix)
	ld h,(ix+1)
	inc HL
	ld (ix),l
	ld (ix+1),h

	pop hl
	pop ix
	ret

losize: .byte 0
hisize: .byte 0

;# executable header information
startaddress: .2byte 0
memorypages: .byte 0
stackpages: .byte 0
;# ====== hextobyte ==========
;#    load HL registers with the 2 ascii characters of a hexadecimal value
;# note routine does not validate the inputs.
;# alphabeta expected in uppercase
;#	ld h,'c'
;#	ld l,'3'
;#	call hextobyte
;#	value stored in A register


hextobyte:
	push hl
	push bc
	ld a,l ;# prepare the low nibble
	call workhextobyte
	ld b,a ;# save it later
	ld a,h ;# prepare the high nibble
	call workhextobyte
	rla ;# a contains the result from the high nibble
	rla ;# so move the nibble to make room for the low nibble
	rla
	rla
	or b ;# add the low nibble

	pop bc
	pop hl
	ret
workhextobyte:
	cp 'A' ;# alphabeta sub 55
	jp m,hextobytenumber
	sub 55
	ret
hextobytenumber:
	sub 48 ;# if number sub 48
	ret

	;# === directory open === #

directoryopen:
	push af
	ld a,OPENDIRECTORY
	out (SDCARD),a
	pop af
	ret
	;# === nextfile === #
nextfile:
	push af
	ld a,NEXTFILE
	out (SDCARD),a
	pop af
	ret
	;# === getfilename or currently open file ===#
	;# ld hl,storagelocation - for the filename
	;# call getfilename

getfilename:
	push af
	push hl
	ld a,GETNAME
	out (SDCARD),a

_getfilename$1:
	ld a,NAMEAVAILABLE
	out (SDCARD),a
	in a,(SDCARD)
	cp 0
	jp z, _exitgetfilename

	ld (hl),a
	inc hl
	
	jp _getfilename$1

_exitgetfilename:
	ld a,0
	ld (hl),a
	pop hl
	pop af
	ret

	# === createProcess == #
	;# stack - note the example below is using the registers as an example, it really don't matter
	;# which register pair put that data on the stack, the sequence in which the parameters are put on the stack
	;# does matter.
	;# push hl,program - zero terminated
	;# push de,commandline - zero terminated
	;# call createProcess
	;# that should do for now
	createProcess: ;# this is messy need to have another go at this
		ld a,0
		call printhex

		pop hl ;# get the return address
		exx ;# exchange with other registers


		ld de,theparams
		;# copy the command params
		pop hl ;# get the command params
		ld a,1
		call printhex

		call strcpy
		ld a,2
		call printhex
		push hl
		ld hl,thecommandlinemsg
		call println
		pop hl
		call println ;# print command params

		ld a,3
		call printhex

		pop hl ;# get the program
		push HL
		ld hl,theprocessmsg
		call println
		pop hl
		call println ;# print program name
#		ld de,userMemory
		ld a,0
		ld d,a ;# use dynamic load address if possible
		ld e,a
		ld a,4
		call printhex
#pih 12/29/2020
		call copyprogramname
		call loadFILE
		cp 0
		jp nz, _createProcesserr$1
		ld (_progloadaddr),hl ;# save the address the program was loaded into. if null is means use the default userMemory
		
		exx ;# restore the other original registers
		push hl ; # restore the return address
		# test if we need to use the default address or the program/library supplied address
		# we can do that by checking if the hl pair is null, null = use fault, not null = custom address
		ld hl,(_progloadaddr)
		ld a,h
		cp 0
		jp nz, _4$
		ld a,l
		cp 0
		jp nz,_4$
		# hl was null so call the default address
		call printhexL
				### CREATENEWPROCESSINFO
		call createnewprocessinfo
		call userMemory
		
		ret
_4$:
	call printhexL
		### CREATENEWPROCESSINFO
		call createnewprocessinfo
	call progloadaddress
	ret
progloadaddress: .byte 0xc3
	_progloadaddr: .2byte 0



_createProcesserr$1:
		push af
		exx ;# restore the other original registers
		pop af
		push hl ; # restore the return address
		ret

# helper function to copy the program name into procname , which is used to update the processinfo
copyprogramname:
	push de
	push hl
	ld de,procname
	call strcpy
	pop hl
	pop de
ret

theprocessmsg: .string "process:"
thecommandlinemsg: .string "params:"
theparams: .space 50

;# === specialfunction this is called by the just lauched program, it allows the program to get it's processid
setprocid:
	ld a,(lastprogramid)
	ret

#== createnewprocessinfo ===#
# variable procname is expected to be populated
# return 

createnewprocessinfo:
	push af
	push hl
	push bc
	push de  'just do everything for now - need to look and fix this
	call getnewprocessid
	call writeprocessinfo
	pop de
	pop bc
	pop hl
	pop af
ret


#== startprocessinfo ==#
# reset the process info list pointer
# no inputs, no outputs
startprocessinfo: 
	push af
	ld a,0
	ld (currentprocessinfo),a
	pop af
	ret

#== nextprocessinfo ===#
# return in hl the next processinfo entry
# also updates currentprocessinfo
# if carry flag set, we have reach the end of the process table
nextprocessinfo:
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

#=== getprocessslot ===#
;# return the first available slot in hl
;# a slot is occuppied if the processid is not zero. this routine will locate the first unoccuppied slot
;# A register returns status where 0=no slots , 1=slot available
;# if carry flag set, a slot was found
;# if carry flag not set, it did not find an empty slot
getprocessslot:
	call startprocessinfo
2$:
#	DEBUG '*'
#	PRINTLN
	call nextprocessinfo ;
	jp c,1$ ;# if carry flag set, we reached the end
	ld a,(hl)
#	call printhex
#	call printhexL
	cp 0 ;# compare processids
	jp nz, 2$   ;# we are looking for a zero processid, which means it's an empty slot
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

;#=== getnewprocessid ===#
;# return set the next available processsid in lastprogramid variable
;# this processid is unique, it cannot be 0

getnewprocessid:
	push af
	push hl
	push bc

1$: ;#; increment the number thats already there (lastprogramid),  repeat if zero
	DEBUG '!'
	ld hl,lastprogramid
	inc (hl)
	ld a,(lastprogramid) ;
	ld c,0
	cp c
	jp z,1$:
	ld c,a ;# move new id into c register,# keep if in C register we will use it later
	call startprocessinfo
2$: DEBUG '@'
	call nextprocessinfo
	jp c,3$ ;# if carry flag set, we reach the end
	inc hl ;# advance to the process id
	ld a,(hl)
	cp c
	jp nz,2$ ;# repeat after incrementing the number again
	jp 1$ ;# get the next processinfo item
3$:
	DEBUG '#'
	pop bc
	pop hl
	pop af
ret

writeprocessinfo:
# prerequisties : lastprogramid has the programid set 
#               variable   procname: contains the name of the program 
	call getprocessslot
	jp nc, failed
#call printhexL
#PRINTLN
	ld a,'R' ;# process is running
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
	ld c,4
	ld b,0
	call strncpy ;# problem needs addressing: if the program name is < 4 bytes the copy will more than needed.
					;# we need a strncpy that stops on a null byte
	ld a, 0
	ret

failed:
	ld hl,errormsg
	call println
	ld a,0
	ret 

errormsg: .string "could not find an empty slot, maximum number of processes running\r\n"

#==== getprocessbyid ==#
# ld a,id
# call getprocessbyid
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

;# A = processid to delete
deleteprocessbyid:
push af
	call getprocessbyid
	cp 1 ;# 1 = we found the process
	jp nz,1$
	ld b,PROCINFOSIZE
	ld a,0
0$: ld (hl),a
	inc hl
	djnz 0$

1$:
pop af
ret 

procname: .space 10 ;# space for the processname, but we really only need 4 or 4+1
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

	# === getcommandparams == #
	;# ld hl,buffer - address of where to copy the data
	;# call getcommandparams
	;# returns zero termined string at buffer 
getcommandparams:
	push de
	push hl
	push hl ;# save hl to move into de
	pop de ;# load hl into de
#	ld hl,userMemory-50   ;# ********* I dont remember why I did this, it needs investigating
	ld hl,theparams
	call strcpy
	pop hl
	pop de
	ret

;# ================ getmalloctable ======#
	getmalloctable:
		ld hl,malloctable
		ret

;# ====== reserve memory alloc table entry ===#

	reservemalloc:
		push bc
		push af
		ld b,1
		call setresetpage
		pop af
		pop bc
	ret
;# ======= setresetpage - memory alloc table management ===#
setresetpage:
;# ld a, page
;# ld b, setorreset , 0 = reset, 1 = set
		push hl
		push bc
		push af
	
		
		DEBUG '@'

		call getmallocrelativebase

		DEBUG '%'
		pop af
		and 0x0f
		cp 8
		jp m,1$
		inc hl
		sub 8
1$:
	
		ld b,a
		inc b
		scf
		ld a,0

2$:		rra 	
		djnz 2$
		pop bc

		push af
		ld a,b
		cp 0
		jp z,6$
;# set
		pop af
		or (hl)
		jp 4$

;# reset
6$:		pop af
		cpl
		and (hl)

4$:
		ld (hl),a
		pop hl
		ret

getmallocrelativebase:
;# ld a,page
;# call getmallocrelativebase
;# return in hl = malloctable address adjusted for page
	push de
		and 0xf0

		ld l,a
		ld h,0
		ld d,8
		call Div8

		ex de,hl
		#.byte 0xeb

		DEBUG '!'

		call getmalloctable
		DEBUG '^'
		add hl,de
		pop de
		ret



;# ========== Div8 8bit division =======#
;# http://tutorials.eeems.ca/Z80ASM/part4.htm#div8
;# result stored in HL
;# ld hl,4
;# ld d,2
;# call Div8
Div8:                            ; this routine performs the operation HL=HL/D
  xor a                          ; clearing the upper 8 bits of AHL
  ld b,16                        ; the length of the dividend (16 bits)
Div8Loop:
  add hl,hl                      ; advancing a bit
  rla
  cp d                           ; checking if the divisor divides the digits chosen (in A)
  jp c,Div8NextBit               ; if not, advancing without subtraction
  sub d                          ; subtracting the divisor
  inc l                          ; and setting the next digit of the quotient
Div8NextBit:
  djnz Div8Loop
  ret

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

;================================
; # === loadaddress == #   THIS NEEDS CHANGING INTO A LOOKUP TABLE - not code
; ld a,x - where x = instruction id
;				id = 1, print
;					 2, printhex
;					3,loadFILE
loadaddress:
	cp PRINT
	jp nz,_loadaddress$2
	ld hl,print
	ret
_loadaddress$2:
	cp PRINTHEX
	jp nz,_loadaddress$3
	ld hl,printhex
	ret
_loadaddress$3:
	cp LOADFILE
	jp nz,_loadaddress$4
	ld hl,loadFILE
	ret
_loadaddress$4:
	cp MEMSET
	jp nz,_loadaddress$5
	ld hl,memset
	ret
_loadaddress$5:
	cp STRLEN
	jp nz,_loadaddress$6
	ld hl,strlen
	ret
_loadaddress$6:
	cp PUTC
	jp nz,_loadaddress$7
	ld hl,putc
	ret
_loadaddress$7:
	cp TOUPPERCASE
	jp nz,_loadaddress$8
	ld hl,touppercase
	ret
_loadaddress$8:
	cp HEXTOBYTE
	jp nz,_loadaddress$9
	ld hl,hextobyte
	ret
_loadaddress$9:
	cp PRINTLN
	jp nz,_loadaddress$10
	ld hl,println
	ret
_loadaddress$10:
	cp STRNCPY
	jp nz,_loadaddress$11
	ld hl,strncpy
	ret
_loadaddress$11:
	cp DIRECTORYOPEN
	jp nz,_loadaddress$12
	ld hl,directoryopen
	ret
_loadaddress$12:
	cp GETFILENAME:
	jp nz,_loadaddress$13
	ld hl,getfilename
	ret
_loadaddress$13:
	cp NEXTFILE
	jp nz,_loadaddress$14
	ld hl,nextfile
	ret
_loadaddress$14:
	cp CREATEPROCESS
	jp nz,_loadaddress$15
	ld hl,createProcess
	ret
_loadaddress$15:
	cp GETCOMMANDPARAMS
	jp nz,_loadaddress$16
	ld hl,getcommandparams
	ret
_loadaddress$16:
	cp GETMALLOCTABLE
	jp nz,_loadaddress$17
	ld hl,getmalloctable
	ret
_loadaddress$17:
	cp DIV8
	jp nz,_loadaddress18$
	ld hl,Div8
	ret
_loadaddress18$:
	cp SETRESETPAGE
	jp nz,_loadaddress19$
	ld hl,setresetpage
	ret
_loadaddress19$:
	cp PRINTHEXL
	jp nz,_loadaddress20$
	ld hl,printhexL
	ret
_loadaddress20$:
	cp STARTPROCESSINFO
	jp nz,_loadaddress21$
	ld hl,startprocessinfo
	ret
_loadaddress21$:
	cp NEXTPROCESSINFO
	jp nz, _loadaddress22$
	ld hl, nextprocessinfo
	ret
_loadaddress22$:
	cp STRCPY
	jp nz, _loadaddress23$
	ld hl, strcpy
	ret
_loadaddress23$:
	cp GETPROCESSBYID
	jp nz,_loadaddress24$
	ld hl,getprocessbyid
	ret
_loadaddress24$:
	cp MULTIPLY8
	jp nz,_loadaddress25$
	ld hl,Mul8b
	ret
_loadaddress25$:
	cp SETPROCID
	jp nz, _loadaddress26$
	ld hl,setprocid
	ret
_loadaddress26$:
	#----- not defined ---
	ld hl,addressfailedmsg
	call print 
	call printhex

	ld hl,0
	ret


	# ======================== end subroutines ========== #
	
	nullroutine: 
		ei
		reti

	serialport: ;#/* interrupt 2, echo what was sent*/
	#	di
		#ld a,'*'
		#out (SERIALPORT),a

		in a,(SERIALPORT)
		cp 0
		jp nz,_1$
		ld a,'`'
_1$:
		out (SERIALPORT),a
		ei
		reti
	crlf: .string "\r\n"
	loadedmsg: .string "JOSHUA\r\n"
	readymsg: .string "\r\nReady v0.0\r\n"
	commandprocessor: .string "cmd"
	errorloadingmsg: .string "error loading program.\r\n\"
	addressfailedmsg: .string "GetAddress failed for code:"

	.align 8
malloctable: .space 255

	; I could set the org address but I'm going to let that move as needed	.org 0x????
	;#.org 0x0A00-start

	.align 8
	jumptable:
	.2byte nullroutine ;0
	.2byte serialport ;2
	.2byte nullroutine ;4
	.2byte nullroutine ;6
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
#/* 10 */
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
#/* 20 */
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
#/* 30 */
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
#/* 40 */
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
#/* 50 */
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
#/* 60 */
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
#/* 70 */
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
#/* 80 */
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
#/* 90 */
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
#/* 100 */
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
#/* 110 */
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
#/* 120 */
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0
	.2byte nullroutine ;0

	ENDOFLINE:
	.if (ENDOFLINE > 0x01fff)
		.abort "PROGRAM TOO LARGE TO FIT BELOW <0x2000"
	.endif
	