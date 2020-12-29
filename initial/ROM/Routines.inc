
.macro DEBUG CHARACTER='!'
# example : DEBUG '!'
#      or : DEBUG h
		push af
		ld a,\CHARACTER
		call putc
		pop af
.endm

.macro DEBUGHEX CHARACTER='!'
# example : DEBUGHEX '!'
#      or : DEBUGHEX h
		push af
		ld a,\CHARACTER
		call printhex
		pop af
.endm

.macro PRINTLN
	push hl
	ld hl,0
	call println
	pop hl
.endm


# address where user programs load
.include "SERIAL.inc"
.include "SDCARD.inc"
.equ commandMemory, 0x2000
.equ userMemory,0x3000
.equ libMemory,0xF000

.equ TRUE, 1
.equ FALSE, 0

# the only fixed address (i hope), use it to get the address of utilities methods
# ld a, PRINT
# call GetAddress
# address for print loaded into hl
# the value in hl can change between os versions so do not hard code the values

.equ GetAddress, 0x0804
.equ PRINT,		1
.equ PRINTLN,	9
.equ PRINTHEX,	2
.equ PRINTHEXL,21
.equ LOADFILE,	3
.equ MEMSET,	4
.equ STRLEN,	5
.equ STRCPY,24
.equ STRNCPY,10
.equ PUTC,		6
.equ TOUPPERCASE,7
.equ HEXTOBYTE,	8
.equ CREATEPROCESS,16
.equ GETCOMMANDPARAMS,17
# filesystem - primitive functions, probably going to change 
.equ DIRECTORYOPEN,13
.equ DIRECTORYNEXTFILE,14
.equ GETFILENAME,15
.equ GETMALLOCTABLE,18
.equ DIV8,19
.equ SETRESETPAGE,20
.equ STARTPROCESSINFO,22
.equ NEXTPROCESSINFO,23




.equ NEXTNUMBER,26

