.set __LIB__,1
.set __ORG__,0x5000

.include "Routines.inc"
.include "libs.inc"
.include "screen.inc"




  test:
	ld hl,msg
	call print
	
	ret

	msg: .string "hello I'm in screen.dll"

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



;================================
; # === libaddress == #
; ld a,x - where x = instruction id
;				id = 1, print
;					 2, printhex
;					3,loadFILE
libaddress:
	cp 0
	jp nz,_loadaddress3$:
	jp initialize



_loadaddress3$:
	cp TEST
	jp nz, _loadaddress4$
	ld hl,test
	ret

_loadaddress4$:
	cp ANSICODE
	jp nz, _loadaddress5$:
	ld hl,ansicode
	ret
_loadaddress5$:
	#----- not defined ---


	ld hl,0
	ret

ENDADDRESS: