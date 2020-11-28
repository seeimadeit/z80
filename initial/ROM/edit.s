.include "Routines.inc"
.include "libs.inc"



	di
	im 2
	ld a, interruptvectors/256
	ld i,a
	ei

loop:
	call available
	jp z,loop

	jp loop


exit:
	ret

	;# check if a key is available in the buffer
	;# if bufferwrite is # bufferread then there's a byte available
	;# check Z flag on return
	;# call available
	;# jp z, no data
	;# jp nz, has data
available:
	push bc
	ld a,(bufferread)
	ld b,a
	ld a,(bufferwrite)
	cp b
	pop bc
	ret

	#return next character from keybuffer
	#tryagain:
	#call available
	#jp nz, tryagain
	#call getc
	# register A has the byte
getc:
	ld ix,keybuffer
	ld bc,(bufferread)
	add ix,bc
	ld a,(ix) ;# contains byte from keybuffer
	ld a,(bufferread)
	push af
	inc a
	cp 10
	jp m,_$ ;#  if A < 10 continue
	ld a,0 ;# reset to 0
_$:
	ld (bufferread),a ;# save readbuffer
	pop af
	ret


interrupthandler:
	push af
	in a,(SERIALPORT)
	
	pop af
	reti


keybuffer: .space 10
bufferwrite: .byte 0
bufferread: .byte 0

interruptvectors:
.org 0x100
	jumptable: ;# for keyboard interrupts
	.2byte interrupthandler ;0
	.2byte interrupthandler ;0