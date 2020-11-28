.equ SDCARD,0x05
; ******* SDCARD *********
; z80 out -filenameclear: no return value, will close the previous open file is one already open
.equ FILENAMECLEAR ,1

; z80 out + in -open: will return a status 1 if file open successfull, 0 if open failed
.equ OPEN ,2

; z80 out - close: no return value
.equ CLOSE ,3

; z80 out + out - filenameappend: no return value
.equ FILENAMEAPPEND ,4

; z80 out + in - readnextbyte: will return 0xFF is nothing to read, which might be a problem if you don't check the available status
.equ READNEXTBYTE ,5

; z80 out + in - available: return 1 is data is available, 0 if no data available
.equ AVAILABLE ,6

; z80 out + in - openwrite: open file for write ,will return a status 1 if file open successfull, 0 if open failed
.equ OPENWRITE,7

; z80 - out + out -writebyte: will write data to an open file,is no file is open or the file is not writable nothing will happen
.equ WRITEBYTE,8

;#===============================
; z80 - out -getname: prepares to get the openfilename, use NAMEAVAILABLE to read the bytes, no return value
.equ GETNAME,0x20
; z80 out + in - nameavailable: return next character of the filename, or 0 it no more characters
.equ NAMEAVAILABLE,0x21
;z80 - out - opendirectory : will open the root directory for directory listing, no return value
.equ OPENDIRECTORY,0x31
;z80 -out - nextfile: move to the next directory entry, no return value
.equ NEXTFILE,0x32