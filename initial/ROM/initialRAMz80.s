.equ SERIALPORT , 0x01
#define LOWORD(l) ((WORD)(l))
#define HIWORD(l) ((WORD)(((DWORD)(l) >> 16) & 0xFFFF))
#define LOBYTE(w) ((BYTE)(w))
#define HIBYTE(w) ((BYTE)(((WORD)(w) >> 8) & 0xFF))

.macro HIBYTE www 
	((\www) >> 8) & 0xFF))
.endm
	
	macro doprint,msg
	ld hl,\msg
	call print
	endm


	.org 0x800
	start:
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

	again:	halt
		jp again
		
		;// subroutines
	print: ;// expecting a zero terminated string
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
	;// remove high nibble
   and  0x0F
   add  a,0x90
   ;; bcd adjust
   daa
   adc  a,0x40
   daa
   out (SERIALPORT),a 
   ret


		;// end subroutines

	
		
	serialport: ;#/* interrupt 2, echo what was sent*/
	#	di
		#ld a,'*'
		#out (SERIALPORT),a

		in a,(SERIALPORT)
		out (SERIALPORT),a
		ei
		reti
	loadedmsg: .string "my Z80 Ram loaded.\r\n\0"
	readymsg: .string "_ready\r\n\0"

	; I could set the org address but I'm going to let that move as needed	.org 0x????
	.org 0x900-start
	.align 2
	jumptable:
	.2byte serialport ;0
	.2byte serialport ;1
	.2byte serialport ;2
	.2byte serialport ;3

	
	