[index.md](index.md)
# loadfile

this is used to load executable and non executable files.

if the de register pair is 0 (null) the the file to load MUST be an
executable file (either program or library), the load address will be
determined by the header information of the executable file.


# === loadFILE === #  
; ld hl, filename (zero terminated)  
; ld de, memory address to load file into  
; ld a, flag - if flag 1 the last byte+1 will be zero terminated
; call loadFILE  
; returns   
;	HL  baseaddress of the load file  
;	A register :   
;			2 = failed to open the file  
;			0 = if file loaded into memory  
;	DE register pair  
;			count of bytes loaded  
