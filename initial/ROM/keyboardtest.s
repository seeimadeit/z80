.equ SERIALPORT , 0x01
.equ SERIALPORT2, 0x02

	.org 0x800


	ld sp,0xffff

	di
	ld hl,readymsg
	call print

		im 2 ;/* interrupt mode 2*/
		ld a, jumptable/256 ;// hibyte
		ld i,a
		ei   ;#/* enable interrupts*/

		ld hl,loadedmsg
		call print
loop:
	halt
	jp loop

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

		in a,(SERIALPORT)
		cp 0
		jp nz,_1$
		ld a,'`'
_1$:
		out (SERIALPORT),a
		ei
		reti

	crlf: .string "\r\n"
	loadedmsg: .string "keyboard test\r\n"
		readymsg: .string "\r\nReady v0.0\r\n"


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

