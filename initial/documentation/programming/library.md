# Creating a LIBrary
-- please use a markdown document viewer to read this file --
A library is a binary executable file, it can load at any location in memory as specified by the library. In the future library's will be code relocatabled.
The LIB will not contain a main() function, and will not execute code when loaded. Instead the code execution will happen only at the request of a calling
application. Its purpose is to store reusable and sharable code. It can be called by multiple applications. As the code is sharable care should be taken to
ensure the code doesn't stamp over other applications variables.


## screen.s source file


```
001 .set __LIB__,1
002 .set __ORG__,0x3000
003
004 .include "Routines.inc"
005 .include "libs.inc"
006 .include "screen.inc"
007 test:
008     ld hl,msg
009     call print
010     ret
011     msg: .string "hello I'm in screen.dll"
012
013 ;# === libaddress == #
014 ;#ld a,x - where x = instruction id
015 ;#	id = 2, test
016 libaddress:
017     cp 0
018     jp nz,_2$:
019     jp initialize
020 _2$:
021     cp TEST
022     jp nz, _end$
023     ld hl,test
024     ret
025 _end$:
026 #----- not defined ---
027     ld hl,0
028     ret
```


001 : Defining the ```__LIB__``` symbol will output a library binary

002 : optionally set the library load address, if not specified the default is 0xF000
004 - 006 : include any required files etc
007 - 011 : your program instructions

The purpose of the libaddress routine is to return the address of a library function. If the function number is not specified (i.e. ld a,0) call the library initalize routine.

016 :  libaddress: is required, its the extry point for function runtime linking
017 - 018 test for the library initialize routine.
019 : run the initialize routine (see below)
020 - 023 : check for the "test" function and return the address of the library function
025 - 028 : default case, where no match is found return a null address

***FAQ***
where does the value TEST come from?  It's defined in the library include file. In the exam it's defined in screen.inc on line 006
from screen.inc
...
.equ TEST,2
..

***initialize:***
This routine is auto generated from libs.inc file. It will allow your library access to the main OS functions. For example the print, println and printhex routines are linked to your program code from the initalize routine.
