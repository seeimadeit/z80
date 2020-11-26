


#define LOWORD(l) ((WORD)(l))
#define HIWORD(l) ((WORD)(((DWORD)(l) >> 16) & 0xFFFF))
#define LOBYTE(w) ((BYTE)(w))
#define HIBYTE(w) ((BYTE)(((WORD)(w) >> 8) & 0xFF))

.include "SDCARD.inc"
.include "Routines.inc"


	.org 0x800
	jp boot
	.align 2
	start:
	jp loadaddress
	
boot:
	ld sp,0xffff

	di
	ld hl,readymsg
	call print
		;ld b, endlabel2-label2
		;ld c,SERIALPORT
		;otir
		
		im 2 ;/* interrupt mode 2*/
		ld a, jumptable/256 ;// hibyte
		ld i,a
		ei   ;#/* enable interrupts*/

		ld hl,loadedmsg
		call print
		#== ******* Command processor Loop ******** ==#
	commandprocessloop:	
		ld hl,commandprocessor
		ld de,commandMemory
		call loadFILE
		cp 0
		jp nz,errorloading
		call commandMemory # run the file just loaded.
		jp commandprocessloop

	errorloading:
		call printhex
		ld hl,errorloadingmsg
		call print
		jp commandprocessloop
		#======================suboutines===============================================#
		# === memset === #
		# ld hl, address to start
		# ld a,0 byte to write into address
		# ld b,1 count of bytes to write
	memset:
		ld (hl),a
		inc hl
		djnz memset
		ret
		#== strlen ==#
		# ld hl, address to start
		# call strlen
		# return len in b
	strlen:
		ex af,af'
		ld b,0
	_strlen$:
		ld a,(hl)
		cp 0
		jp z, strlenexit
		inc b
		inc hl
		jp _strlen$:
	strlenexit:
		ld a,b
		call printhex
		ex af,af'
		ret


		# === PRINT === #
	print: ;// expecting a zero terminated string
		push hl
		push af
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

# === PRINTHEX === #
		;Display 8-bit number in hex.
		; 	ld a,0xaa
	;       call printhex
printhex:

; Input: a
  push af
  ;// remove low nibble
   rra
   rra
   rra
   rra
   call  _$
   ;// restore low nibble
   pop af
   
_$:
	;// remove high nibble
   and  0x0F
   add  a,0x90
   ;; bcd adjust
   daa
   adc  a,0x40
   daa
   out (SERIALPORT),a 
   ret


		;// end subroutines
# === loadFILE === #
; ld hl, filename (zero terminated)
; ld de, memory address to load file into
; call loadFILE
;
loadFILE:
	push de ; save de for later
		; try to open the SD card and read some data
		ld a,FILENAMECLEAR ; // filenameclear
		out (SDCARD),a


;
_$getnextchar:
		ld a,(hl)
		cp 0
		jp z, _$openfile #; if filename character is null we have finished
		ld a,FILENAMEAPPEND
		out (SDCARD),a ; // filenameappend
		ld a,(hl)
		out (SDCARD),a
		out (SERIALPORT),a
		inc hl
		jp _$getnextchar

_$openfile:
		ld a,OPEN	;// Open
		out (SDCARD),a
		in a,(SDCARD)
		pop hl ; get load address - must pop the stack before returning
		cp 0
		jp nz,available
		ld a,2 ;we have an error trying to open the file.
		ret
		
	available:
		ld a, AVAILABLE ; // available
		out (SDCARD),a
		in a,(SDCARD) ;// read the value from the device
	;	ld b,a ; // going to malipulate the a register so save it as not to destroy the A result
	;	add a,'0' ;// make it printable
	;	out (SERIALPORT),a ;// print response
	;	ld a,b
		cp 0 ;// compare the A reg returned by the device
		jp nz,_$nextbyte
		ld a,0
		ret
_$nextbyte:
		;// if we get here then there is data to read
		ld a,READNEXTBYTE
		out (SDCARD),a ;// read nextbyte
		in a,(SDCARD)
		ld (hl),a ; // store byte in RAM (OSLOAD)
		inc hl 
		ld a,'#'
		out (SERIALPORT),a ;// just echo it back for now
		jr available ;
;================================
; # === loadaddress == #
; ld a,x - where x = instruction id
;				id = 1, print
;					 2, printhex
;					3,loadFILE
loadaddress:
	cp PRINT
	jp nz,_loadaddress$2
	ld hl,print
	ret
_loadaddress$2:
	cp PRINTHEX
	jp nz,_loadaddress$3
	ld hl,printhex
	ret
_loadaddress$3:
	cp LOADFILE
	jp nz,_loadaddress$4
	ld hl,loadFILE
	ret
_loadaddress$4:
	cp MEMSET
	jp nz,_loadaddress$5
	ld hl,memset
	ret
_loadaddress$5:
	cp STRLEN
	jp nz,_loadaddress$6
	ld hl,strlen
	ret
_loadaddress$6:
	#----- not defined ---
	ld hl,0
	ret
	# ======================== end subroutines ========== #
		
	serialport: ;#/* interrupt 2, echo what was sent*/
	#	di
		#ld a,'*'
		#out (SERIALPORT),a

		in a,(SERIALPORT)
		out (SERIALPORT),a
		ei
		reti
	loadedmsg: .string "my Z80 Ram loaded.\r\n\0"
	readymsg: .string "\r\nReady v0.0\r\n\0"
	commandprocessor: .string "cmd\0"
	errorloadingmsg: .string "error loading program.\r\n\0"

	; I could set the org address but I'm going to let that move as needed	.org 0x????
	.org 0x0A00-start
	.align 2
	jumptable:
	.2byte serialport ;0
	.2byte serialport ;1
	.2byte serialport ;2
	.2byte serialport ;3

	
	