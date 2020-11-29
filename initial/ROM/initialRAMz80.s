


#define LOWORD(l) ((WORD)(l))
#define HIWORD(l) ((WORD)(((DWORD)(l) >> 16) & 0xFFFF))
#define LOBYTE(w) ((BYTE)(w))
#define HIBYTE(w) ((BYTE)(((WORD)(w) >> 8) & 0xFF))

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
		#== ******* Command processor Loop ******** ==#
	commandprocessloop:	
		ld hl,commandprocessor
		ld de,commandMemory
		call loadFILE
		cp 0
		jp nz,errorloading
		ld hl,0
		call println
		call commandMemory # run the file just loaded.
		jp commandprocessloop

	errorloading:
		call printhex
		ld hl,errorloadingmsg
		call println
		jp commandprocessloop
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
;		not preserved
;	A register 
;			2 = failed to open the file
;			0 = if file loaded into memory
;	DE register pair
;			count of bytes loaded
loadFILE:
	push af
	push de ; save de for later
	call sizereset
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
		jp nz,available
		pop af ;# a flag not needed now
		call sizeloaded
		ld a,2 ;we have an error trying to open the file.
		ret
		
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
	;# which register pair put that data on the stack
	;# push hl,program - zero terminated
	;# push de,commandline - zero terminated
	;# call createProcess
	;# that should do for now
	createProcess: ;# this is messy need to have another go at this
		ld a,0
		call printhex

		pop hl ;# get the return address
		exx ;# exchange with other registers

		ld de,userMemory-50 ;# whooa
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
		ld de,userMemory
		ld a,4
		call printhex

		call loadFILE
		cp 0
		jp nz, _createProcesserr$1
		exx ;# restore the other original registers
		push hl ; # restore the return address
		call userMemory
		ret
_createProcesserr$1:
		push af
		exx ;# restore the other original registers
		pop af
		push hl ; # restore the return address
		ret

theprocessmsg: .string "process:"
thecommandlinemsg: .string "params:"

	# === getcomandline == #
	;# ld hl,buffer - address of where to copy the data
	;# call getcommandline
	;# returns zero termined string at buffer 
getcommandparams:
	push de
	push hl
	push hl ;# save hl to move into de
	pop de ;# load hl into de
	ld hl,userMemory-50
	call strcpy
	pop hl
	pop de
	ret

;================================
; # === loadaddress == #
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
	#----- not defined ---
	ld hl,addressfailedmsg
	call print 
	call printhex

	ld hl,0
	ret
	# ======================== end subroutines ========== #
		
	serialport: ;#/* interrupt 2, echo what was sent*/
	#	di
		#ld a,'*'
		#out (SERIALPORT),a

		in a,(SERIALPORT)
		out (SERIALPORT),a
		ei
		reti
	crlf: .string "\r\n"
	loadedmsg: .string "my Z80 Ram loaded.\r\n"
	readymsg: .string "\r\nReady v0.0\r\n"
	commandprocessor: .string "cmd"
	errorloadingmsg: .string "error loading program.\r\n\"
	addressfailedmsg: .string "GetAddress failed for code:"


	; I could set the org address but I'm going to let that move as needed	.org 0x????
	;#.org 0x0A00-start
	.align 8
	jumptable:
	.2byte serialport ;0
	.2byte serialport ;1
	.2byte serialport ;2
	.2byte serialport ;3

	
	