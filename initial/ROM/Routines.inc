
# address where user programs load
.include "SERIAL.inc"
.include "SDCARD.inc"
.equ commandMemory, 0x1000
.equ userMemory,0x2000

# the only fixed address (i hope), use it to get the address of utilities methods
# lda, PRINT
# call GetAddress
# address for print loaded into hl
# the value in hl can change between os versions so do not hard code the values

.equ GetAddress, 0x0804
.equ PRINT,1
.equ PRINTHEX,2
.equ LOADFILE,3
.equ MEMSET,4
.equ STRLEN,5

