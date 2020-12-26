
.set __ORG__,commandMemory

.include "Routines.inc"
.include "libs.inc"
	

	ld hl,welcomemsg
	call println
	ld a,0
	ld (doreload),a

newcommand:
	ld a,(doreload)
	cp 1
	jp nz,1$ ;# will force command program reload
	ld hl,reloadmsg
	call println
	ret

1$:
	; #setup/reset the interrupt vector who knows what could have happen to it
	di
	im 2
	ld a, jumptable/256 ; initialize the new interrupt vector
	ld i,a
	ei


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
doreload: .byte 0

loadandrun:
	
	ld hl,0
	call println ;# display a new line
;	ld hl, cmdlinebuffer ;# load filename of program
;	ld de, userMemory ;# address where to load program
;	call loadfile
;	cp 0
;	jp nz,loaderr ;# if load returned anything except 0, its an error
;	jp runuserMemory

	ld a,1
	ld (ignorekeyboard),a

	call createprocess
	cp 0
	jp nz,loaderr
	call resetcommandline
	ld a,0
	ld (ignorekeyboard),a
	ret


ignorekeyboard: .byte 0

loaderr:
	call printhex ;# print return code
	ld hl,cmdlinebuffer
	call print ;# print the command
	ld hl,invalidcommandmsg
	call println ;# print msg
	call hexdumpcmdline
;#	call resetcommandline
	ld a,0
	ld (ignorekeyboard),a
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

;runuserMemory:
	

;	call userMemory
;	call resetcommandline
;	ret



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
		
		push af  ;# if a program is runing the ignorekeyboard flag is set
	
		ld a,(ignorekeyboard) ;# so we look for that flag and ignore any keypresses if set true
		cp a,1
		jp nz,12$
		pop af
		jp executeexit
12$:	
		pop af
		cp 0x0d
		jp z, executecmd
		cp 0x0a
		jp z,executeexit

	
		ld hl,cmdlinebufferlen # load the length into b
		ld b,0
		ld c,(hl)


		ld hl,cmdlinebuffer ;# load buffer address into hl
		add hl,bc ;# add the buffer length to get the last character pointer

		;# for delete or backspace
		cp 8
		jp nz,1$

		ld a,(cmdlinebufferlen)
		cp 0
		jp z,4$

		dec hl
		ld a,0
		ld (hl),a
		ld a,8
		ld hl,cmdlinebufferlen
		dec (hl)
		jp 2$

1$:
		cp 127
		jp nz,3$

		ld a,(cmdlinebufferlen)
		cp 0
		jp z,4$

		dec hl
		ld a,0
		ld (hl),a
		ld a,127
		ld hl,cmdlinebufferlen
		dec (hl)
		jp 2$

3$:		
		cp 0
		jp nz,5$
		ld a,'`'

5$:		ld (hl),a ;# store keyboard character
		
		ld hl,cmdlinebufferlen ;# load buffer length
		inc (hl) ;# increment buffer len
		

2$:		out (SERIALPORT),a
4$:		ld a,0
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
#== hexdump memory builtin == #
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
		call hexdumpheader
		call _hexdumprint
		jp hexdumpexit

hexdumperror:
		ld hl,hexdumpsyntaxmsg
		call println
hexdumpexit:
		ld a,TRUE
		ret


hexdumpheader:
	push af
	push bc
	push hl
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
	pop hl
	pop bc
	pop af
	ret
hexdumplinetitle:
	# hl contain the address to print output format is "0x0000"
	push af
	push hl
	ld hl,hexdumpprefix
	call print
	pop hl

	ld a,(_highlow)
	cp 0
	jp z,_1$
	ld a,h
	call printhex
_1$:ld a,l
	call printhex
	ld a,' '
	call putc
	pop af
	ret
_highlow: .byte 0 ;# allows code reuse

_hexdumprint:
	ld a,1
	ld (_highlow),a

	ld hl,(hidump)
	ld l,0 ;# alway start at page boundry
	ld b,16 ;# outer loop
_hexdp0:
	push bc
	ld b,16 ;# inner loop
		;# print the address
	call hexdumplinetitle
_hexdp$1:

	;# print the byte values
	push hl
	ld hl,hidump
	ld a,(hl)
	pop hl
	cp l
	jp nz,1$

	push hl
	ld hl,boldon ;# found the byte of interest turn on bold
	call print
	pop hl

	ld a,(hl)  ;# print the hex value
	call printhex
	
	push hl
	ld hl,boldoff ;# turn off bold
	call print
	pop hl

	jp 2$ ;# continue

1$:	ld a,(hl)
	call printhex
2$:	ld a,' '
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
helpcmd: .string "?"

help:
	ld hl,helpmsg
	call println

	ld a,TRUE
	ret

	# === in builtin == #
incmd: .string "in,"
din:
	ld hl,inmsg
	call println

	ld hl,cmdlinebuffer
	call strlen
	ld a,b
	cp 7
	jp nz, _inerror
	ld hl,cmdlinebuffer
	call touppercase
	call println
	ld ix,cmdlinebuffer
	ld h,(ix+5)
	ld l,(ix+6)
	call hextobyte
	ld (lodump),a ;# address to read in lodump
	ld c,a
	in a,(c)
	call printhex
	jp _inexit
_inerror:
	ld hl,insyntaxmsg
	call println
_inexit:

	ld a,TRUE
	ret

	# === out builtin == #
outcmd: .string "out,"
dout:
	ld hl,outmsg
	call println

	ld hl,cmdlinebuffer
	call strlen
	ld a,b
	cp 13
	jp nz, outerror
	ld hl,cmdlinebuffer
	call touppercase
	call println
	ld ix,cmdlinebuffer
	ld h,(ix+6)
	ld l,(ix+7)
	call hextobyte
	ld (lodump),a ;# byte to send in lodump

	ld h,(ix+11)
	ld l,(ix+12)
	call hextobyte
	ld (hidump),a ;# address in hidump
	ld c,a
	ld a,(lodump)
	out (C),A


	jp outexit

outerror:
	ld hl,outsyntaxmsg
	call println
outexit:
	ld a,TRUE
	ret


	# === createprocess builtin === #
createprocesscmd: .string "createprocess,"
createprocess:
	ld hl,createprocessmsg
	call println
	ld hl,cmdlinebuffer
	push hl ;# save program name
	dec hl ;# this is stupid but it works
_1$:
	inc hl
	ld a,(hl)
	
	cp 0 ;# null terminated
	jp z,_2$

	cp ' ' ;# look for 1st space
	jp nz,_1$
	ld a,0
	ld (hl),a ;# zero terminate prgram name
_2$:
	inc hl
	push hl ;# save the command parameters
	call createProcess
	ret

#=== reload builtin ==#
reloadcmd: .string "exit"
reload:
	ld a,1
	ld (doreload),a
	ld a,TRUE
	ret

;# shared variables for builtin functions
runfrom: .byte 0xc3 ;# jump instruction - must be next to hidump
hidump: .byte 0 ;# used but hexdump and load
lodump: .byte 0 ;# used by hexdump and load

#=== malloc table builtin ==#

malloctablecmd: .string "m*"
malloctable:
	ld hl, malloctablemsg
	call println

	call hexdumpheader

	ld a,0 ;# function hexdumplinetitle uses this varible to determine if both h and l should be output
	ld (_highlow),a ;# 0 = output low, 1 = output high and low

	ld a,0
	ld h,0
	ld l,0
	ld (pagecount),hl
	call getmalloctable

	ld b,16 ;# level 3

_6$:push bc
push hl
push bc
	ld hl,(pagecount)
	call hexdumplinetitle
	ld c,0x10
	ld b,0
	add hl,bc
	ld (pagecount),hl
pop bc
pop hl
	ld a,' '
	call putc
	call putc	
	call putc

	ld b,2 ;# level 2
	
_5$:push bc
	ld a,(hl) ;# memory map
	ld b,8 ;# level 1
_1$:	 
	rl a
	push af
	jp nc,_2$:
	ld a,'1'
	jp _3$:
_2$:
	ld a,'0'
_3$:
	call putc
	ld a,' '
	call putc
	call putc
	pop af
	djnz _1$

	pop bc ;# level 2
	inc hl ;# advance memory map point
	djnz _5$

	push hl

	ld hl,0
	call println
	pop hl
#	inc hl ;# advance memory map point
	pop bc
	djnz _6$

	ld hl,malloctableusemsg
	call println
	ld a,TRUE
	ret

pagecount: .byte 0

		;#======================= builtin functions end ================
		;# --- dev note : builtin function must return TRUE in a register
messages:
;	dbug1: .string "debug1"
;	dbug2: .string "debug2"
	welcomemsg: .string "Would you like to play a game?"
	hexdumpmsg: .string "HEXDUMP"
	hexdumpprefix: .string "0x"
	boldon: .string "\033[1m"
	boldoff: .string "\033[m"
	hexdumpsyntaxmsg: .string "  hexdump syntax: h,0xXXXX - address specified in hexidecimal"
	loadmsg: .string "LOAD"
	loadsyntaxmsg: .string "  load syntax: l,0xXXXX,filename - load file @ 0xXXXX address"
	loaderrormsg: .string "  load error."
	runmsg: .string "RUN"
	runsyntaxmsg: .string "  run syntax: r,0xXXXX - run from 0xXXXX address"
	inmsg: .string "IN"
	insyntaxmsg: .string "  peripheral in syntax: in,0xYY - execute IN A,(0xYY) - register A is displayed in hex on return"
	inerrormsg: .string "  in error."
	outmsg: .string "OUT"
	outsyntaxmsg: .string "  peripheral out syntax: out,0xXX,0xYY - executes\r\nLD A,0xXX\r\nOUT (0xYY), A\r\nwhere 0xYY is the device address, XX is byte to send"
	outerrormsg: .string " out error."
	createprocessmsg: .string "hell no"
	reloadmsg: .string "reloading."
	malloctableusemsg: .string "table is showing memory pages\r\n take the left value and the heading value to create the page address\r\ni.e. 0x10 + 03 = page 0x13xx"
	malloctablemsg: .string "Memory Allocation Table"



	commandPromptmsg: .string "\r\n>";
	invalidcommandmsg: .string ": Invalid command.Shall we play a game?"
	helpmsg: .byte "Joshua MCP builtin commands:\r\n"
			 .byte "? - help, you are reading help right now\r\n"
			 .byte "h,0xXXXX - hexdump from address 0xXXXX for 255 bytes\r\n"
			 .byte "l,0xXXXX,filename - load into memory at 0xXXXX the file filename\r\n"
			 .byte "r,0xXXXX - run from address 0xXXXX\r\n"
			 .byte "in,0xYY - receive from peripheral at address 0xYY\r\n"
			 .byte "out,0xXX,0xYY - send to peripheral at address 0xYY then value 0xXX\r\n"
			 .byte "m* - show malloc table\r\n"
			 .byte "exit - exit and reload the MCP\r\n"
			 .string 0
builtin:
	;# 2bytes pointer to command - zero terminated, 2bytes pointer to handler Routines
	;# last item will have 0x000 to indicate end of list
	;#hexdump
		.2byte hexdumpcmd,hexdump
		.2byte loadcmd,load
		.2byte runcmd,run
		.2byte helpcmd,help
		.2byte outcmd,dout
		.2byte incmd,din
		.2byte createprocesscmd,createprocess
		.2byte reloadcmd,reload
		.2byte malloctablecmd,malloctable

	endoflist: .2byte 0,0

data:
	cmdlineexecute: .byte 0
	cmdlinebufferlen: .byte 0
	cmdlinebuffer: .space 50
	cmdlinebuffer$:

	nullroutine:
		ei
		reti

	


	;#.org 0x700
	.align 8
	jumptable: ;# for keyboard interrupts
	.2byte nullroutine ;0
	.2byte cmdline ;2
	.2byte nullroutine ;4
	.2byte nullroutine ;6
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