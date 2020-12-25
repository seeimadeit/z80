
# Creating a Library
-- please use a markdown document viewer to read this file --  

A library is a binary executable file, it can load at any location in memory as specified by the library. In the future library's will be code relocatabled.
The LIB will not contain a main() function, and will not execute code when loaded. Instead the code execution will happen only at the request of a calling
application. Its purpose is to store reusable and sharable code. It can be called by multiple applications. As the code is sharable care should be taken to
ensure the code doesn't stamp over other applications variables.


## screen.s


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
011     msg: .string "hello I'm in screen.lib"
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


The purpose of the libaddress routine is to return the address of a library function. If the function number is 0 (i.e. ld a,0) call the library initalize routine.

016 :  libaddress: is required, its the extry point for function runtime linking  

017 - 018 test for the library initialize routine.  

019 : run the initialize routine (see below)  

020 - 023 : check for the "test" function and return the address of the library function  

025 - 028 : default case, where no match is found return a null address  



## FAQ
 
where does the value TEST come from?  It's defined in the library include file. In the example it's defined in **screen.inc**  
```
...
.equ TEST,2
..
```



## initialize:
This routine is auto generated from **libs.inc** file. It will allow your library access to the main OS functions. For example the print, println and printhex routines are linked to your program code from the initalize routine.


# Load and Use a Library

To use the library we first need to load it into memory. After the binary has been loaded, the base address of the
library is returned in the HL register pair. You will need to save that address so you can call the base address to query
the library for the address of the functions it contains (phew). Librarys need to be initialized before using the library.
You can do that by calling the base address and pass 0 into the A register. To get the address of a library function
call the baseaddress with a function number of the routine in the A register. The library will have an include file that will define the
id's of the functions. Save the returned address in the HL register pair. It's important you save the address information into the
correct byte structure as defined in the example in lines 017 - 020. The predefined byte value is an assembler
instruction for jump. When you call the function it will jump to the address provided by the library.

```
000 .include "screen.inc"
...
001 loadlibrary:
002     ld hl,loadfilename
003     ld de,0
004     call loadFILE2
005     cp a,0 ;# if A = 0 then the file loaded successfully
006     jp nz,_1$:
007     ld (_screenbase),hl
008     ld a,0 ;# initialize the dll
009     call fnScreenGetAddress
010     ld a,TEST
011     call fnScreenGetAddress
012     ld (_testadr),hl
013     call fnTest
014 _1$: ret
015
016 loadfilename: .string "screen.lib"	
017 fnScreenGetAddress: .byte 0xc3
018        _screenbase: .2byte 0
019 fnTest:       .byte 0xc3
020     _testadr: .2byte 0
```

000 : load the library include file, this will contain the function id values and probably other information to use the library  

001 define a subroutine called loadlibrary  

002 - 004 : call the loadFILE2 function passing in the filename (see loadFILE2 for details)  

005 : validate the load call worked  

006 : if it failed we will just exit  

007 : the load returns the base address into the hl register pair, save that address for later use  

008 - 009 : call the library initialize routine  

010 - 012 : ask for the address of TEST function and store the address for later use  

013 : call the library test function  

014 : exit the subroutine  

016 : define the library filename  

017 - 018 : 0xc3 is the byte code for the z80 jump (JP) instruction, the address is stored in the 2 bytes after this bytecode. This allows our code to call the library function.  

019 - 020 : define our jump instruction and reserve 2 bytes for the library address  



        
        
		
