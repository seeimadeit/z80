.org 0x5000
ld a,(result)
inc a
ld (result),a
ret

result: .byte 0