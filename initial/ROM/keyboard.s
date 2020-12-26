.set __LIB__, 1
.set __ORG__, 0x2500

.include "Routines.inc"
.include "libs.inc"




libaddress:
    cp 0
    jp nz,_end$:
    jp initialize
#_2$:
#    cp TEST
#    jp nz, _end$
#    ld hl,test
#    ret
_end$:
#----- not defined ---
    ld hl,0
    ret

ENDADDRESS: