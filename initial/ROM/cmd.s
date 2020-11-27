
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
	ld a,TOUPPERCASE
	call GetAddress
	ld (touppercaseadr),hl
	ld a,HEXTOBYTE
	call GetAddress
	ld (hextobyteadr),hl
	ld a,PRINTLN
	call GetAddress
	ld (printlnadr),hl
	


	

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
	ld hl,0
	call println
	ld hl,cmdlinebuffer
	call findbuiltin
	cp TRUE ;# true if builtin was found
	call nz,loadandrun ;# must be something to do
	ld hl,0
	call println
	jp newcommand

loadandrun:
	
	ld hl,0
	call println ;# display a new line
	ld hl, cmdlinebuffer ;# load filename of program
	ld de, userMemory ;# address where to load program
	call loadfile
	cp 0
	jp nz,loaderr ;# if load returned anything except 0, its an error
	jp runuserMemory

loaderr:
	call printhex ;# print return code
	ld hl,cmdlinebuffer
	call print ;# print the command
	ld hl,invalidcommandmsg
	call println ;# print msg
	call hexdumpcmdline
	call resetcommandline
	ret
hexdumpcmdline: 
	;# when an invalid command happens hexdump 16 bytes 
	;# of the commmandline.
	ld hl,cmdlinebuffer
	ld b,16
_hexdp$99:

	;# print the byte values
	ld a,(hl)
	call printhex
	ld a,' '
	call putc
	;# next byte
	inc hl
	djnz _hexdp$99
	ret

runuserMemory:
	
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
	ld b,0 ;# used to keep count of the number of characters - because a 0 length is bad
findbuiltinrestart:
	ld l, (iy)	;# load hl with the pointer address
	ld h, (iy+1)

findbuiltin1:
	ld a,(ix)
	cp 0 ;# if we have a null character we have made a match
	jp z,_findbuiltinSuccess

	inc b ;# character count
	ld a,(hl)
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
	;# check the length - it can't be 0
	ld a,b
	cp 0
	jp z,_findbuildtinFail
	;# ok good from here to continue
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
		
	hexdump:
		ld hl,hexdumpmsg
		call println
		ld hl,cmdlinebuffer ;# command length must be 8 characters
		call strlen
		ld a,b
		cp 8
		jp nz,hexdumperror
		ld hl,cmdlinebuffer ;# the hextobyte is expect uppercase characters
		call touppercase
		call println
		ld ix,cmdlinebuffer ;# get the 4th and 5th characters into the lobyte
		ld h,(ix+4)
		ld l,(ix+5)
		call hextobyte
		ld (lodump),a
	
		ld h,(ix+6) ;# get the 6th and 7th characters into the hibyte
		ld l,(ix+7)
		call hextobyte
		ld (hidump),a
		ld hl,0
		call println

	;# hidump has the address to dump so let dump it out
		call hexdumpprint
		jp hexdumpexit

hexdumperror:
		ld hl,hexdumpsyntaxmsg
		call println
hexdumpexit:
		ld a,TRUE
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

	ld hl,(hidump)

	ld b,16 ;# outer loop
_hexdp0:
	push bc

	ld b,16 ;# inner loop
		;# print the address
	push hl
	ld hl,hexdumpprefix
	call print
	pop hl

	ld a,h
	call printhex
	ld a,l
	call printhex
	ld a,' '
	call putc
_hexdp$1:

	;# print the byte values
	ld a,(hl)
	call printhex
	ld a,' '
	call putc
	;# next byte
	inc hl
	djnz _hexdp$1
	;# now repeat the line and display the ascii value
	or a ;# reset carry flag
	ld de,16
	sbc hl,de ;# subtrack 16bytes

	ld a,'|' ;# output border character
	call putc
	ld b,16
_dexdpc$1:
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
	ret

	;# ====== LOAD builtin ==== #
	loadcmd: .string "l,",0
	load:
		ld hl,loadmsg
		call println
		ld hl,cmdlinebuffer ;# command length must be >= 10 characters
		call strlen
		ld a,b
		cp 10
		jp p, _loadc$1
		ld hl,loadsyntaxmsg ;# load failure message
		call println
		ld a,TRUE
		ret
_loadc$1:
		ld hl,cmdlinebuffer+4
		ld de,_ladr
		ld bc,4
		ldir
		ld a,0
		ld (de),a ;# zero terminated
		ld hl,_ladr ;# hex address stored in _adr
		call touppercase
		call println

		ld ix,_ladr ;# covert text to binary address and store in hidump,lodump
		ld h,(ix)
		ld l,(ix+1)
		call hextobyte
		ld (lodump),a
		ld h,(ix+2)
		ld l,(ix+3)
		call hextobyte
		ld (hidump),a

		
		ld hl,cmdlinebuffer+9
		ld de,(hidump)
		call loadfile
		cp 0
		jp z, _doneload$1
		call printhex ;# print return code
		ld hl,loaderrormsg
		call println



		
_doneload$1:
		ld a,TRUE
		ret
_ladr: .space 5 ;# store character address

;# === run builtin ==========

runcmd: .string "r,",0
run:
	ld hl,runmsg
	call println

	ld hl,cmdlinebuffer ;# command length must be 8 characters
	call strlen
	ld a,b
	cp 8
	jp nz, runerror
	ld hl,cmdlinebuffer
	call touppercase
	call println
	ld ix, cmdlinebuffer
	ld h,(ix+4)
	ld l,(ix+5)
	call hextobyte
	ld (lodump),a

	ld h,(ix+6)
	ld l,(ix+7)
	call hextobyte
	ld (hidump),a
	ld hl,0
	call println

	call runfrom
	jp runexit
runerror:
	ld hl,runsyntaxmsg
	call println
runexit:
	ld a,TRUE
	ret

# === help builtin === #
helpcmd: .string "?",0

help:
	ld hl,helpmsg
	call println

	ld a,TRUE
	ret

;# shared variables for builtin functions
runfrom: .byte 0xc3 ;# jump instruction - must be next to hidump
hidump: .byte 0 ;# used but hexdump and load
lodump: .byte 0 ;# used by hexdump and load

		;#======================= builtin functions end ================
		;# --- dev note : builtin function must return TRUE in a register
messages:
;	dbug1: .string "debug1"
;	dbug2: .string "debug2"
	hexdumpmsg: .string "HEXDUMP"
	hexdumpprefix: .string "0x"
	hexdumpsyntaxmsg: .string "  hexdump syntax: h,0xXXXX - address specified in hexidecimal"
	loadmsg: .string "LOAD"
	loadsyntaxmsg: .string "  load syntax: l,0xXXXX,filename - load file @ 0xXXXX address"
	loaderrormsg: .string "  load error."
	runmsg: .string "RUN"
	runsyntaxmsg: .string "  run syntax: r,0xXXXX - run from 0xXXXX address"

	commandPromptmsg: .string "\r\n>";
	invalidcommandmsg: .string ": Invalid command."
	helpmsg: .byte "Z80 command line builtin commands:\r\n"
			 .byte "? - help, you are reading help right now\r\n"
			 .byte "h,0xXXXX - hexdump from address 0xXXXX for 255 bytes\r\n"
			 .byte "l,0xXXXX,filename - load into memory at 0xXXXX the file filename\r\n"
			 .byte "r,0xXXXX - run from address 0xXXXX\r\n"
			 .string 0
builtin:
	;# 2bytes pointer to command - zero terminated, 2bytes pointer to handler Routines
	;# last item will have 0x000 to indicate end of list
	;#hexdump
		.2byte hexdumpcmd,hexdump
		.2byte loadcmd,load
		.2byte runcmd,run
		.2byte helpcmd,help

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
	println: .byte 0xc3
	printlnadr: .2byte 0
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
	touppercase: .byte 0xc3
	touppercaseadr: .2byte 0
	hextobyte: .byte 0xc3
	hextobyteadr: .2byte 0
	


	.org 0x600
	jumptable: ;# for keyboard interrupts
	.2byte cmdline ;0
	.2byte cmdline ;0