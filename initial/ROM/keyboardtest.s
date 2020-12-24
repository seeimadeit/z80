.ifndef BOOT
	.include "Routines.inc"
	.include "libs.inc"
.endif
	.include "ansicodes.inc"

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

#==== print ansi escape codes =======

ansicode:
	# A - code to call
	push af

	ld hl,escapeintro
	call print

	cp CLEARSCREEN
	jp nz,1$
	ld hl,clearscreen
	jp 99$
1$:	cp CLEARENDOFSCREEN
	jp nz,2$
	ld hl,clearendofscreen
	jp 99$
2$:	cp CLEARBEGINOFSCREEN
	jp nz,3$
	ld hl,clearbeginofscreen
	jp 99$
3$:	cp CLEARWHOLESCREEN
	jp nz,4$
	ld hl,clearwholescreen
	jp 99$
4$:	cp CLEARCURRENTLINE
	jp nz,5$
	ld hl,clearcurrentline
	jp 99$
5$:	cp CLEARTOENDOFLINE
	jp nz,6$
	ld hl,cleartoendofline
	jp 99$
6$:	cp CLEARFROMSTARTOFLINE
	jp nz,7$
	ld hl,clearfromstartofline
	jp 99$
7$:	cp CLEARLINE
	jp nz,8$
	ld hl,clearline
	jp 99$
8$:	cp COLORRESET
	jp nz,9$
	ld hl,colorreset
	jp 99$
9$:	cp COLORBOLD
	jp nz,10$
	ld hl,colorbold
	jp 99$
10$:	cp COLORDIM
	jp nz,11$
	ld hl,colordim
	jp 99$
11$:	cp COLORFGBLACK
	jp nz,12$
	ld hl,colorfgblack
	jp 99$
12$:	cp COLORFGRED
	jp nz,13$
	ld hl,colorfgred
	jp 99$
13$:	cp COLORFGGREEN
	jp nz,14$
	ld hl,colorfggreen
	jp 99$
14$:	cp COLORFGYELLOW
	jp nz,15$
	ld hl,colorfgyellow
	jp 99$
15$:	cp COLORFGBLUE
	jp nz,16$
	ld hl,colorfgblue
	jp 99$
16$:	cp COLORFGMAGENTA
	jp nz,17$
	ld hl,colorfgmagenta
	jp 99$
17$:	cp COLORFGCYAN
	jp nz,18$
	ld hl,colorfgmagenta
	jp 99$
18$:	cp COLORFGWHITE
	jp nz,19$
	ld hl,colorfgwhite
	jp 99$
19$:	cp COLORBGBLACK
	jp nz,20$
	ld hl,colorbgblack
	jp 99$
20$:	cp COLORBGRED
	jp nz,21$
	ld hl,colorbgred
	jp 99$
21$:	cp COLORBGGREEN
	jp nz,22$
	ld hl,colorbggreen
	jp 99$
22$:	cp COLORBGYELLOW
	jp nz,23$
	ld hl,colorbgyellow
	jp 99$
23$:	cp COLORBGBLUE
	jp nz,24$
	ld hl,colorbgblue
	jp 99$
24$:	cp COLORBGMAGENTA
	jp nz,25$
	ld hl,colorbgmagenta
	jp 99$
25$:	cp COLORBGCYAN
	jp nz,26$
	ld hl,colorbgcyan
	jp 99$
26$:	cp COLORBGWHITE
	jp nz,98$
	ld hl,colorbgwhite
	jp 99$
98$: ;#default
	ld hl,colorreset
99$:call print
	pop af
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

escapeintro: .string 0x1b,"["
clearscreen: .string "0;0H",0x1b,"[2J"
clearendofscreen: .string "0J"
clearbeginofscreen: .string "1J"
clearwholescreen: .string "2J"
clearcurrentline: .string "K"
cleartoendofline: .string "0K"
clearfromstartofline: .string "1K"
clearline: .string "2K"
colorreset: .string "0m"
colorbold: .string "1m"
colordim: .string "2m"
colorfgblack: .string "30m"
colorfgred: .string "31m"
colorfggreen: .string "32m"
colorfgyellow: .string "33m"
colorfgblue: .string "34m"
colorfgmagenta: .string "35m"
colorfgcyan: .string "36m"
colorfgwhite: .string "37m"
colorbgblack: .string "40m"
colorbgred: .string "41m"
colorbggreen: .string "42m"
colorbgyellow: .string "43m"
colorbgblue: .string "44m"
colorbgmagenta: .string "45m"
colorbgcyan: .string "46m"
colorbgwhite: .string "47m"
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
	


;# http://tutorials.eeems.ca/Z80ASM/part4.htm#div8
;# result stored in HL
;# ld hl,4
;# ld d,2
;# call Div8
Div8:                            ; this routine performs the operation HL=HL/D
  xor a                          ; clearing the upper 8 bits of AHL
  ld b,16                        ; the length of the dividend (16 bits)
Div8Loop:
  add hl,hl                      ; advancing a bit
  rla
  cp d                           ; checking if the divisor divides the digits chosen (in A)
  jp c,Div8NextBit               ; if not, advancing without subtraction
  sub d                          ; subtracting the divisor
  inc l                          ; and setting the next digit of the quotient
Div8NextBit:
  djnz Div8Loop
  ret


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

