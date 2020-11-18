.equ count ,0x4000
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
		ld a,0
		ld (count),a
		ld a, (jumptable >> 8) ;0x01 ;// hibyte
		ld i,a
		im 2 ;/* interrupt mode 2*/
		ei   ;#/* enable interrupts*/
	;	ld a,65
	;	out (0x01),a
	;	ld hl,label1
;		ld b, endlabel1-label1
;		ld c,SERIALPORT
;		otir
		ld hl,z80msg
		call print
;=================================================================
		; try to open the SD card and read some data
		ld a,FILENAMECLEAR ; // filenameclear
		out (SDCARD),a
		ld a,FILENAMEAPPEND
		out (SDCARD),a ; // filenameappend
		ld a,'R'
		out (SDCARD),a 
		ld a,FILENAMEAPPEND
		out (SDCARD),a ; // filenameappend
		ld a,'A'
		out (SDCARD),a
		ld a,FILENAMEAPPEND
		out (SDCARD),a ; // filenameappend
		ld a,'M'
		out (SDCARD),a
		ld a,OPEN	;// Open
		out (SDCARD),a
		in a,(SDCARD)
		cp 0
		jr z,reboot
		ld hl,OSLOAD
		available:
		ld a, AVAILABLE ; // available
		out (SDCARD),a
		in a,(SDCARD) ;// read the value from the device
	;	ld b,a ; // going to malipulate the a register so save it as not to destroy the A result
	;	add a,'0' ;// make it printable
	;	out (SERIALPORT),a ;// print response
	;	ld a,b
		cp 0 ;// compare the A reg returned by the device
		jr z, again
		;// if we get here then there is data to read
		ld a,READNEXTBYTE
		out (SDCARD),a ;// read nextbyte
		in a,(SDCARD)
		ld (hl),a ; // store byte in RAM (OSLOAD)
		inc hl 
		ld a,'.'
		out (SERIALPORT),a ;// just echo it back for now
		jr available ;
;================================
	again:	
;	ld hl,label2
;		ld b, endlabel2-label2
;		ld c,SERIALPORT
;		otir
		;halt
		jp OSLOAD
		jp again
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
		
		int1:
		di
		ld a,(count)
		inc a
		ld (count),a
		out (SERIALPORT),a
		ei
		reti
	serialport: ;#/* interrupt 2, echo what was sent*/
		di
		in a,(SERIALPORT)
		out (SERIALPORT),a
		ei
		reti
	z80msg:	.string "Z80:\0"
	failedtoloadRAMimagemsg: .string "in memory\0"

	.org 0x0100-start
	jumptable:
	.align 2
	.2byte int1
	.2byte serialport
	
	
	