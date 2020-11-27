


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
; returns 2 = failed to open the file
;         0 = if file loaded into memory
loadFILE:
	push de ; save de for later
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
		jr available ;

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
	#----- not defined ---
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
	crlf: .string "\r\n",0
	loadedmsg: .string "my Z80 Ram loaded.\r\n\0"
	readymsg: .string "\r\nReady v0.0\r\n\0"
	commandprocessor: .string "cmd\0"
	errorloadingmsg: .string "error loading program.\r\n\0"

	; I could set the org address but I'm going to let that move as needed	.org 0x????
	.org 0x0A00-start
	.align 2
	jumptable:
	.2byte serialport ;0
	.2byte serialport ;1
	.2byte serialport ;2
	.2byte serialport ;3

	
	