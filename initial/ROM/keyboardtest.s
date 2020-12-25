.ifndef BOOT
	.include "Routines.inc"
	.include "libs.inc"
.endif
	.include "ansicodes.inc"
	.include "SDCARD.inc"
	.include "screen.inc"

.ifdef BOOT
	.equ SERIALPORT , 0x01
	.equ SERIALPORT2, 0x02

	.org 0x800
	ld sp,0xffff
.endif

	.equ  BUFFERSIZE, 128




	di
	ld hl,readymsg
	call print

		im 2 ;/* interrupt mode 2*/
		ld a, jumptable/256 ;// hibyte
		ld i,a
		ei   ;#/* enable interrupts*/

		ld hl,loadedmsg
		call print
.ifndef BOOT
		ld hl,notboot
	call print
.endif

call displaytitle
call move1_0

ld hl,loadfilename
ld de,0
call loadFILE2
call printhex
cp a,0 ;# if A = 0 then the file loaded successfully
jp nz,_4$:
ld (_screengetaddress),hl
ld a,0 ;# initialize the dll
call fnScreenGetAddress
ld a,ANSICODE
call fnScreenGetAddress
ld (_test),hl
ld a,CLEARSCREEN
call fnTest
ld hl,donemsg
call print

_4$:
ld a,0
ret
donemsg: .string "done"
loadfilename: .string "screen.lib"	
	.align 2

	fnScreenGetAddress: .byte 0xc3
		_screengetaddress: .2byte 0
	fnDiv8: .byte 0xc3
		_Div8: .2byte 0
	fnTest: .byte 0xc3
		_test: .2byte 0

loop:
	ld a,(exit)
	cp 0
	jp nz,_exit$

	call haskeys
	cp 0
	jp z,loop
#	ld a,'*'
#	ld a,(getkeypos)
#	call printhex
	call getchar
	#out (SERIALPORT),a
	#ld a,'!'
	call putc

	jp loop
	
_exit$:	;#exit
	ld a,0
	call printhex
	ret


getchar: 
	di
	;# read a byte from the keyboard buffer
	ld ix,buffer ;# the keyboard buffer
	ld a,(getkeypos) ;# read from index position
	ld b,0
	ld c,a
	add ix,bc ;# ix now contains the memory location to read
	ld a,(ix)
	push af ;# byte now stored in the stack
	ld a,c ;# restore index position
	inc a
	cp BUFFERSIZE+1
	jp nz,_1$ 
	# input position has overflowed
	ld a,0 ;# reset indexpos

_1$:
	ld (getkeypos),a ;# save the new indexposition
	pop af
	call decbuffer
	ei
	ret


_resetscreenmsg: .string 0x1b,"[0m",0x1b,"[1;1H]",0x1b,"[2J",0x1b,"[1;30HEDITOR"
displaytitle:
	ld hl,_resetscreenmsg
	call print
	ret

move1_0: ld hl,_move1_0
	call print
	ret
_move1_0: .string 0x1b,"[2;1H"

asciibuffer: .space 10 ;# working buffer to build characters positions. really bad idea but I can't get my head around itoa()

#=========== useful routines =====

;# append byte - ascii characters
;# a - character to append
;# hl = base address
;# looks for null byte, then stores the a register character and appends a null

appendchar:
	push hl
	push af
2$:	ld a,(hl)
	cp 0
	jp nz,1$ ;# if not null inc hl and repeat
	pop af ;# save the character now
	ld (hl),a
	inc hl
	ld a,0 ;# append the null byte
	ld (hl),a
	pop hl
	ret
1$: inc hl ;# incremen address and repeat
	jp 2$
	



	.ifdef BOOT
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

printhex: ret ;# not in boot code
putc: ret

.endif

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
loadFILE2:
	push af
	push de ; save de for later
	call sizereset
	ld a,0
	ld (startaddress),a
	ld (startaddress+1),a
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
	inc hl
	inc hl
	ld (startaddress),hl ;# this is now the dll entry point address, will need this later to initialize the library
	jp available
_4$:
	ld a,3 ;#new error code
	ret
	#if we reach here then the first 2 bytes have the address information so let read them now
loadheader:
	ld b,2
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
		ret ;# exit loadheader because we have loaded 2 bytes
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

startaddress: .2byte 0

# ======================== end subroutines ========== #
	
	nullroutine: 
		ld a,0
		out (SERIALPORT),a
		jp serialport
		reti

	serialport: ;#/* interrupt 2, echo what was sent*/
	#	di
		#ld a,'*'
		#out (SERIALPORT),a
		push af


		in a,(SERIALPORT)
		cp 0
		jp nz,_1$
		ld a,'`'
		jp _2$
_1$:
		cp 0x1b
		jp nz,_2$
		ld a,1
		ld (exit),a
		pop af
		ei
		reti
_2$:

		call storeinbuffer
		;# not needed to output anymore - out (SERIALPORT),a
		pop af
		ei
		reti

storeinbuffer:
		push bc
		push ix
		push af
		push af ;# save the data to be written
		ld ix,buffer ;# get the base buffer
		ld a,(bufferpos) ;# get the index position
		ld b,0
		ld c,a
		add ix,bc ;# adjust IX
		pop af ;# restore data to be written
		ld (ix),a ;# store byte
		
		ld a,c ;# copy back the index position
		inc a ;# increment the index position
		cp BUFFERSIZE+1
		jp nz, _1$
		ld a,0 ;# the buffer overflowed so reset to 0

_1$:
		ld (bufferpos),a ;# store the new position
		pop af
		pop ix
		pop bc
		call incbuffer
		ret

incbuffer:
	push af
	ld a,(buffersize)
	inc a
	ld (buffersize),a
	pop af
	ret


decbuffer:
	push af
	ld a,(buffersize)
	dec a
	ld (buffersize),a
	pop af
	ret

haskeys:
	ld a,(buffersize)
	ret

		exit: .byte 0 ;#if true time to exit program, escape key sets to true
	crlf: .string "\r\n"
	loadedmsg: .string "keyboard test\r\n"
	readymsg: .string "\r\nReady v0.0\r\n"
	editormsg: .string "EDITOR"
.ifndef BOOT
		notboot: .string "program space\r\n"
.endif


buffer: .space BUFFERSIZE ;# data received will be stored in buffer
bufferpos: .byte 0 ;# this is the location where the next received byte will be stored

# keep a count of the number of characters in the buffer and the number read from the buffer
# its the delta change or difference between saved characters and read characters
buffersize: .byte 0 

getkeypos: .byte 0;# index into the next byte to read




	.align 8
	jumptable:
	.2byte nullroutine ;0
	.2byte serialport ;2
	.2byte serialport ;4
	.2byte serialport ;6
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

