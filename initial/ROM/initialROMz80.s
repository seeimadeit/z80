.equ count ,0x4000
.equ SERIALPORT , 0x01
#define LOWORD(l) ((WORD)(l))
#define HIWORD(l) ((WORD)(((DWORD)(l) >> 16) & 0xFFFF))
#define LOBYTE(w) ((BYTE)(w))
#define HIBYTE(w) ((BYTE)(((WORD)(w) >> 8) & 0xFF))

.macro HIBYTE www 
	((\www) >> 8) & 0xFF))
.endm
	

	.org 0x0000
	start:
		ld a,'0'-1
		ld (count),a
		ld a, jumptable >> 8 ;0x01 ;// hibyte
		ld i,a
		im 2 ;/* interrupt mode 2*/
		ei   ;#/* enable interrupts*/
	;	ld a,65
	;	out (0x01),a
		ld hl,label1
		ld b, endlabel1-label1
		ld c,SERIALPORT
		otir
	again:	halt
		jp again

		
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
	label1:
		.string "Welcome to my pleasure dome."
	endlabel1:

		.org 0x0100
	jumptable:
	.align 2
	.2byte int1
	.2byte serialport
	
	
	