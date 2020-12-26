[index.md](index.md)
# system library


the system library is normally loaded automatically through Routines.inc and libs.inc



```
.include "Routines.inc"
.include "libs.inc"

```



.equ PRINT,		1  

.equ PRINTLN,	9  

.equ PRINTHEX,	2  

.equ LOADFILE,	3  

.equ MEMSET,	4  

.equ STRLEN,	5  

.equ PUTC,		6  

.equ TOUPPERCASE,7  

.equ HEXTOBYTE,	8  
[hextobyte.md](hextobyte.md)

.equ STRNCPY,10  

.equ CREATEPROCESS,16  

.equ GETCOMMANDPARAMS,17  

filesystem - primitive functions, probably going to change  

.equ DIRECTORYOPEN,13 


.equ DIRECTORYNEXTFILE,14  

.equ GETFILENAME,15  
