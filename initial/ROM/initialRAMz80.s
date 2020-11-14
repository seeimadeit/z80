.equ SERIALPORT , 0x01
#define LOWORD(l) ((WORD)(l))
#define HIWORD(l) ((WORD)(((DWORD)(l) >> 16) & 0xFFFF))
#define LOBYTE(w) ((BYTE)(w))
#define HIBYTE(w) ((BYTE)(((WORD)(w) >> 8) & 0xFF))

.macro HIBYTE www 
	((\www) >> 8) & 0xFF))
.endm
	

	.org 0x8000
	start:

		ld a, (jumptable >> 8) ;// hibyte
		ld i,a
		im 2 ;/* interrupt mode 2*/
		ei   ;#/* enable interrupts*/

		ld hl,label1
		ld b, endlabel1-label1
		ld c,SERIALPORT
		otir
	again:	halt
		jp again

	int0: halt
		jp int0
		
	serialport: ;#/* interrupt 2, echo what was sent*/
		di
		in a,(SERIALPORT)
		out (SERIALPORT),a
		ei
		reti
	label1:
		.string "Z80 Ram loaded."
	endlabel1:

	; I could set the org address but I'm going to let that move as needed	.org 0x????
	jumptable:
	.align 2
	.2byte int0 ;0
	.2byte serialport ;2
	
	
	