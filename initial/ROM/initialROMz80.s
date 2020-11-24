.equ SERIALPORT , 0x01
.equ SDCARD,0x05

.equ OSLOAD,0x800 ; // start address for loading the OS.

; ******* SDCARD *********
; z80 out only
.equ FILENAMECLEAR ,1
.equ OPEN ,2
.equ CLOSE ,3
.equ FILENAMEAPPEND ,4
; z80 out + in
.equ READNEXTBYTE ,5
.equ AVAILABLE ,6


#define LOWORD(l) ((WORD)(l))
#define HIWORD(l) ((WORD)(((DWORD)(l) >> 16) & 0xFFFF))
#define LOBYTE(w) ((BYTE)(w))
#define HIBYTE(w) ((BYTE)(((WORD)(w) >> 8) & 0xFF))

.macro HIBYTE www 
	((\www) >> 8) & 0xFF))
.endm
	

	.org 0x0000
	start:
		ld sp,0xffff
		ld hl,z80msg
		call print

		
		ld a, (jumptable >> 8) ;// hibyte
		ld i,a
		
		#im 2 ;/* interrupt mode 2*/
		im 1 #mode 1
		ei   ;#/* enable interrupts*/
		jp again
		.org 0x038-start
		jp serialport
;=================================================================
;		; try to open the SD card and read some data
;		ld a,FILENAMECLEAR ; // filenameclear
;		out (SDCARD),a
;		ld a,FILENAMEAPPEND
;		out (SDCARD),a ; // filenameappend
;		ld a,'R'
;		out (SDCARD),a 
;		ld a,FILENAMEAPPEND
;		out (SDCARD),a ; // filenameappend
;		ld a,'A'
;		out (SDCARD),a
;		ld a,FILENAMEAPPEND
;		out (SDCARD),a ; // filenameappend
;		ld a,'M'
;		out (SDCARD),a
;		ld a,OPEN	;// Open
;		out (SDCARD),a
;		in a,(SDCARD)
;		cp 0
;		jr z,reboot
;		ld hl,OSLOAD
;		available:
;		ld a, AVAILABLE ; // available
;		out (SDCARD),a
;		in a,(SDCARD) ;// read the value from the device
;	;	ld b,a ; // going to malipulate the a register so save it as not to destroy the A result
;	;	add a,'0' ;// make it printable
;	;	out (SERIALPORT),a ;// print response
;	;	ld a,b
;		cp 0 ;// compare the A reg returned by the device
;		jr z, again
;		;// if we get here then there is data to read
;		ld a,READNEXTBYTE
;		out (SDCARD),a ;// read nextbyte
;		in a,(SDCARD)
;		ld (hl),a ; // store byte in RAM (OSLOAD)
;		inc hl 
;		;ld a,'.'
;		;out (SERIALPORT),a ;// just echo it back for now
;		jr available ;
;================================
.org 0x100-start
	again:	
		halt
		ld a,'.'
		out (SERIALPORT),a ;
	;	jp OSLOAD
		jp again ;; this will never execute
	;// subroutines
	print: ;// expecting a zero terminated string
		;ld hl,label1
		;	call print
		push hl
		push af
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
reboot:
	ld hl,failedtoloadRAMimagemsg
	call print
	halt
	jp reboot
		
	z80msg:	.string "Z80:\r\n\0"
	failedtoloadRAMimagemsg: .string "in memory\r\n\0"
		
serialport: ;#/* interrupt 2, echo what was sent*/
		di
		ld a,'*'
		out (SERIALPORT),a
		in a,(SERIALPORT)
		out (SERIALPORT),a
		ei
		reti
	
	.org 0x200-start
	.align 2
	jumptable:
		.2byte serialport ;0
		.2byte serialport ;2

	