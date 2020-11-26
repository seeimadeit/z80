
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
	ld a,PUTC
	call GetAddress
	ld (putcadr),hl

	

	; setup the interrupt vector
	ld a, jumptable/256 ; initialize the new interrupt vector
	ld i,a

newcommand:
	call resetcommandline
	ld hl,commandPromptmsg ;# display command prompt
	call print
loop:
	halt		;# wait for interrupt
	ld hl,cmdlineexecute ;# if user pressed enter then cmdlineexecute will contain 1
	ld a,(hl)
	cp 1
	jp nz,loop ;# nothing to process so repeat

	ld hl,cmdlinebuffer ;# test if user entered a value
	call strlen
	ld a,b
	cp 0
	jp z, newcommand ;# if no commands display prompt and repeat

	ld hl,cmdlinebuffer
	call findbuiltin
	cp TRUE ;# true if builtin was found
	call nz,loadandrun ;# must be something to do
	jp newcommand

loadandrun:
	
	ld hl,crlf
	call print ;# display a new line
	ld hl, cmdlinebuffer ;# load filename of program
	ld de, userMemory ;# address where to load program
	call loadfile
	cp 0
	jp nz,loaderr ;# if load returned anything except 0, its an error
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
	
	call userMemory
	call resetcommandline
	ret

resetcommandline:
	push af
	push hl
# reset the command line variables
	ld hl,cmdlinebufferlen
	ld a,0
	ld (hl),a
	ld hl, cmdlinebuffer
	ld b, cmdlinebuffer$-cmdlinebuffer
	call memset
	pop hl
	pop af
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

		
	;# ======================== find builtin function =======
		;# ld hl, buffer (zero terminated string)
		;# call findbuiltin
		;# returns TRUE if builtin command located
		;#         FALSE if no builtin command located

findbuiltin:
	
	push hl ;# save hl
	push hl


	pop ix;# copy hl into ix, ix contains the user supplied cmd

	ld iy,builtin ;# load start of list
findbuiltinrestart:
	ld l, (iy)	;# load hl with the pointer address
	ld h, (iy+1)

findbuiltin1:
	ld a,(hl)
	ld b,(ix)
	sub (ix)

	inc ix ;# no flag changes for inc
	inc hl
	jp z,findbuiltin1 ;# if the same characters repeat

	;# if we get here, its because the characters no longer match.
	;# so we need to test the builtin cmd to see if it's a zero,
	;# if it is then we have matched the builtin command
	dec hl ;# need to backup 1 byte because we moved it before the test
	ld a,(hl)
	cp 0
	jp z,_findbuiltinSuccess
	;# if we reach here then we did not find a match, so
	;# we can load the next builtin cmd and try again.
	pop hl
	push hl ;# save hl
	push hl ;# restore the user supplied cmd
	pop ix ;# now ix contains the user supplied cmd
	;# iy still contains the builtin address pointer.
	;# so if we add 4 bytes to it we will point to the next
	;# table entry for the builtin command.
	ld bc,4
	add iy,bc
	;# before we try with the current entry we need to check
	;# its not the end of the list
	ld a,(iy)
	cp 0
	jp nz, findbuiltinrestart
	ld a,(iy+1)
	cp 0
	jp nz,findbuiltinrestart
	

_findbuildtinFail:
	pop hl ;# remove the save hl
	ld a,FALSE
	ret
_findbuiltinSuccess:
	pop hl ;# remove the saved hl
	ld bc,2 ;# we have a success so now we load the address of the subroutine
	add iy,bc
	
	ld l, (iy)	;# load hl with the pointer address
	ld h, (iy+1) ;# to jump into the address I need to use the iy registers
	push hl
	pop iy
	jp (iy)
	halt ;# we will never get here



		;#======================= builtin functions ====================
		hexdumpcmd: .string "h,",0
		smallh: .string "d,",0
	hexdump:
		ld hl,hexdumpmsg
		call print
		ld a,TRUE
		ret



		;#======================= builtin functions end ================

messages:
	dbug1: .string "debug1",0
	dbug2: .string "debug2",0
	hexdumpmsg: .string "HEXDUMP\0"
	crlf: .string "\r\n",0
	commandPromptmsg: .string ">\0";
	invalidcommandmsg: .string ": Invalid command.\r\n\0"
builtin:
	;# 2bytes pointer to command - zero terminated, 2bytes pointer to handler Routines
	;# last item will have 0x000 to indicate end of list
	;#hexdump
		.2byte hexdumpcmd,hexdump
		.2byte smallh,hexdump

	endoflist: .2byte 0,0

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
	putc: .byte 0xc3
	putcadr: .2byte 0

	.org 0x200
	jumptable: ;# for keyboard interrupts
	.2byte cmdline ;0
	.2byte cmdline ;0