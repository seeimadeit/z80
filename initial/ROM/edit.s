.include "Routines.inc"
.include "libs.inc"

.equ buffersize,9

	di
	im 2
	ld a, interruptvectors/256
	ld i,a
	ei

loop:
	call available
	cp 0
	jp z, loop

1$:
	call getc
	cp 0x1b
	jp z,exit
	call putc
	
	cp 0x0d
	jp nz,loop
	ld a,0x0a
	call putc
	jp loop


exit:
	ld a,0
	ret

available: ;# return number of characters in the buffer
	ld a,(Counter)
	ret

getc:
	push bc
	push ix

	ld a,(Counter) ;# cannot getc if there are no characters to get
	cp 0
	jp z,1$

	ld a,(Rindex)
	cp buffersize
	jp nz,2$
	ld a,0 ;# need to reset the Rindex value
	ld (Rindex),a

2$: ;# a contains the Rindex value
	ld ix,buffer
	ld b,0
	ld c,a
	add ix,bc ;# ix now contains the location to store the character
	ld a,(ix)
	push af ;# load the character and save onto stack
	ld a,(Rindex)
	inc a
	ld (Rindex),a ;# update Rindex and save
	pop af
	call subCounter ;# save the counter variable

	pop ix
	pop bc
	ret
1$: ;# no characters available
	pop ix
	pop bc
	ld a,0
	ret



interrupthandler:
	push af
	push ix
	in a,(SERIALPORT)
	push af

	ld a,(Counter) ;# cannot write character if no space to write into
	cp buffersize
	jp z,2$


	call getWriteAddress
	
	pop af ;# get the character
	ld (ix),a

	ld a,(Windex) ;# reload index
	inc a
	ld (Windex),a ;# save the updated index
	call addCounter ;# update the counter variable
	jp 1$

2$: pop af ;# throw away the character
	
1$:	pop ix
	pop af
	ei
	reti

getWriteAddress:
	ld a,(Windex)
	cp buffersize ;# test we have not reached the max buffer size
	jp nz, 3$
	;# need to cycle the Windex
	ld a,0
	ld (Windex),a
3$:	;# store the character in buffer, A = Windex value
	ld ix,buffer
	ld b,0
	ld c,a
	add ix,bc ;# ix now contains the location to store the character

	ret
addCounter:
	push af
	push hl

;#	ld hl,incmsg
;#	call println
	ld a,(Counter)
	inc a
	ld (Counter),a
	cp buffersize-4 ;# test this value
	jp nz,1$ ;# flow control
	ld a,19 ;# xoff control
	out (SERIALPORT),a
	ld a,'*'
	out (SERIALPORT),a
1$:	pop hl
	pop af
	ret
subCounter:
;#	di
	push af
	push hl
;#	ld hl,decmsg
;#	call println
	ld a,(Counter)
	dec a
	ld (Counter),a
	cp 0
	jp nz,1$ ;# flow control
	ld a,17 ;# xon control
	out (SERIALPORT),a
	ld a,'&'
	out (SERIALPORT),a

1$:	pop hl
	pop af
;#	ei
	ret


nullroutine: ei
			reti

Counter: .byte 0
Rindex: .byte 0 ;# read next character from this index
Windex: .byte 0 ;# write next current at this index
buffer: .space buffersize ;# at most 10 characters
incmsg: .string "increment"
decmsg: .string "decrement"

.align 8
interruptvectors:

	jumptable: ;# for keyboard interrupts
	.2byte nullroutine ;0
	.2byte interrupthandler ;0

	.2byte nullroutine ;0
	.2byte nullroutine ;0
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

	ENDADDRESS: