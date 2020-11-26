
.include "Routines.inc"
.org commandMemory

	ld a,PRINT
	call GetAddress
	ld (printadr),hl
	ld a,PRINTHEX
	call GetAddress
	ld (printhexadr),hl
	ld a,LOADFILE
	call GetAddress
	ld (loadfileadr),hl
	ld a,MEMSET
	call GetAddress
	ld (memsetadr),hl
	ld a,STRLEN
	call GetAddress
	ld (strlenadr),hl

	

	; setup the interrupt vector
	ld a, jumptable/256 ; initialize the new interrupt vector
	ld i,a

newcommand:
	ld hl,commandPromptmsg
	call print
loop:
	halt
	ld hl,cmdlineexecute
	ld a,(hl)
	cp 1
	jp nz,loop

	ld hl,cmdlinebuffer
	call strlen
	ld a,b
	cp 0
	jp z, newcommand
	call loadandrun

	jp newcommand

loadandrun:
	
	ld hl,crlf
	call print
	ld hl, cmdlinebuffer
	ld de, userMemory
	call loadfile
	cp 0
	jp nz,loaderr
	jp run

loaderr:
	call printhex ;# print return code
	ld hl,cmdlinebuffer
	call print ;# print the command
	ld hl,invalidcommandmsg
	call print ;# print msg
	call resetcommandline
	ret

run:
	call resetcommandline
	call userMemory
	ret

resetcommandline:
# reset the command line variables
	ld hl,cmdlinebufferlen
	ld a,0
	ld (hl),a
	ld hl, cmdlinebuffer
	ld b, cmdlinebuffer$-cmdlinebuffer
	call memset
	ret

	;##############################################################
	cmdline: ;#/* interrupt 2, echo what was sent*/
		in a,(SERIALPORT)
		cp 0x0d
		jp z, executecmd
		cp 0x0a
		jp z,executeexit
		

	
		ld hl,cmdlinebufferlen # load the length into b
		ld b,0
		ld c,(hl)


		ld hl,cmdlinebuffer ;# load buffer address into hl
		add hl,bc ;# add the buffer length to get the last character pointer
		ld (hl),a ;# store keyboard character
		
		ld hl,cmdlinebufferlen ;# load buffer length
		inc (hl) ;# increment buffer len
		

		out (SERIALPORT),a
		ld a,0
		ld hl,cmdlineexecute
		ld (hl),a
		jp executeexit
	executecmd:
		ld a,1
		ld hl,cmdlineexecute
		ld (hl),a
	executeexit:
		ei
		reti
messages:
	crlf: .string "\r\n\0"
	commandPromptmsg: .string ">\0";
	invalidcommandmsg: .string ": Invalid command.\r\n\0"

data:
	cmdlineexecute: .byte 0
	cmdlinebufferlen: .byte 0
	cmdlinebuffer: .space 50
	cmdlinebuffer$:


functionlookups:
	.align 2
	print: .byte 0xc3
	printadr: .2byte 0
	printhex: .byte 0xc3
	printhexadr: .2byte 0
	loadfile: .byte 0xc3
	loadfileadr: .2byte 0
	memset: .byte 0xc3
	memsetadr: .2byte 0
	strlen: .byte 0xc3
	strlenadr: .2byte 0
	.org 0x200
	jumptable: ;# for keyboard interrupts
	.2byte cmdline ;0
	.2byte cmdline ;0