.include "Routines.inc"
.include "libs.inc"
;# this is unfinished. in the function getcharacter, it will display the ascii printable characters
;# but it will also print characters passed the bytes loaded from the file. the hex display will
;# stop printing at the correct place, but the ascii display does not. I was using the
;# length variable to determine when to display the characters, I don't think this approad was working.
;# so look at it again when your not so tired. Peter ps. just had a though, when you stop printing in the
;# hex area store the number of bytes to still print, then you could use that to ... i don't know - im tired'

	call lengthreset
	ld hl,msg
	call println
	ld hl,params
	call getcommandparams
	call println
	ld de,dumparea
	ld hl,params
	ld a,1 ;# ask for zero terminated
	call loadfile
	cp 0
	jp nz,error
	;# save the de register as it has the load size


	ld ix,losize
	ld (ix),e
	ld (ix+1),d

	ld hl,dumparea
	call hexdumpprint
	jp _exit

_error: 
	ld hl,error
	call println
_exit:
	ld a,0
	ret




hexdumpprint:

	;# print the heading

	ld b,7
_sp$1:
	ld a,' ' ;# 7 spaces
	call putc
	djnz _sp$1

	ld a,0 ;# for column header
	ld b,16 ;# 16 column headers
_col$1:
	call printhex
	inc a

	push af
	ld a,' '
	call putc
	pop af

	djnz _col$1

	ld hl,0 ;# newline
	call println

	ld hl,dumparea

_reload:
	ld b,16 ;# outer loop
_hexdp0:
	call issize0
	cp 0
	ret z

	push bc

	ld b,16 ;# inner loop
		;# print the address
	push hl
	ld hl,hexdumpprefix
	call print
	;#new code
	ld hl,(lolength)
	ld a,h
	call printhex
	ld a,l
	call printhex
	;# end new code
	pop hl

;	ld a,h
;	call printhex
;	ld a,l
;	call printhex
	ld a,' '
	call putc
_hexdp$1:

; moved	call lengthincrement
	call sizedecrement
	;# print the byte values
	ld a,(hl)
	call printhex
	ld a,' '
	call putc
	;# next byte

	inc hl
	call issize0
	cp 0
	jp z,4$
	djnz _hexdp$1
	jp 3$
4$:
	
	push hl ;# save hl because we need to keep track of the location
	pop de
	dec b
41$:
	ld hl,_3spaces
	call print
	inc de

	djnz 41$
	push de
	pop hl
3$:
	;# now repeat the line and display the ascii value
	or a ;# reset carry flag
	ld de,16
	sbc hl,de ;# subtrack 16bytes

	ld a,'|' ;# output border character
	call putc
	ld b,16
_dexdpc$1:
	call getcharacter
	call putc
	inc hl
	djnz _dexdpc$1

	ld a,"|" ;# output border character
	call putc

	;# next line
	push hl
	ld hl,0
	call println
	pop hl
	pop bc
	djnz _hexdp0
	call issize0
	cp 0
	jp nz,_reload

	ret

getcharacter: ;# need to move some code out of the djnz loop because it was too big


	call lengthincrement
	ld a,(hl)
	cp 32 ;# space
	jp p, _nex$2 ;# if character >= 32 jump
	ld a,'.'
	jp _prt$
_nex$2:
	cp 127 ;# delete
	jp m,_prt$ ;# if character < 127 jump print
	ld a,'.' ;# else print a dot

_prt$:

	ret

issize0:
	ld ix,losize
	ld a,(ix)
	cp 0
	jp nz,_not

	ld a,(ix+1)
	cp 0
	jp nz,_not
	ld a,0
	ret
_not:
	ld a,1
	ret
_3spaces: .string "   "
;# this will decrement to zero but will not go below zero
;# if zero A register = 0
;# if not zero A register = 1
sizedecrement:

	push ix
	push hl


	ld ix,losize
	ld l,(ix)
	ld h,(ix+1)

	ld a,l
	
	cp 0
	jp nz,_4$
	ld a,h
	cp 0
	jp nz,_4$
	ld a,0
	jp _2$

_4$:
	dec HL
	ld (ix),l
	ld (ix+1),h
	ld a,l
	cp 0
	jp nz, _1$
	ld a,h
	cp 0
	jp nz,_1$



	ld a,0	;# yes it's zero
	jp _2$
_1$:		;# not zero yet
	ld a,1
	
_2$:
	pop hl
	pop ix
	ret

lengthreset:
	push ix
	push af
	ld a,0
	ld ix,lolength
	ld (ix),a
	ld (ix+1),a
	pop af
	pop ix
	ret

lengthincrement:
	push ix
	push hl

	ld ix,lolength
	ld l,(ix)
	ld h,(ix+1)
	inc HL
	ld (ix),l
	ld (ix+1),h

	pop hl
	pop ix
	ret

islength0:
	ld ix,lolength
	ld a,(ix)
	cp 0
	jp nz,_not

	ld a,(ix+1)
	cp 0
	jp nz,_1$
	ld a,0
	ret
_1$:
	ld a,1
	ret


losize: .byte 0
hisize: .byte 0

lolength: .byte 0
hilength: .byte 0

hexdumpprefix: .string "0x"
	
msg: .string "the params are:"
error: .string "failed to load the file."
params: .space 50
dumparea: .space 1 ;# this is not correct the loadfile will expand passed this