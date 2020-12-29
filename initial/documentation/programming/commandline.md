[index.md](index.md)
# Command line tools

The command line is called Joshua, inspired by the wargames movie.
The operating system is also call the MCP - master control program as it's responsible
for loading and controlling the applications, MCP is inspired by the Tron movie.



## Builtin instructions

**?** - help, you are reading help right now  
**h,0xXXXX** - hexdump from address 0xXXXX for 255 bytes  
**l,0xXXXX,filename** - load into memory at 0xXXXX the file filename  
**r,0xXXXX** - run from address 0xXXXX  
**in,0xYY** - receive from peripheral at address 0xYY  
**out,0xXX,0xYY** - send to peripheral at address 0xYY then value 0xXX  
**m*** - show malloc table  
**exit** - exit and reload the MCP  

## Programs

**dir**  - catalog the disk files

**type**  - type contents of a file to the display
    
```
    type filename
```


**setmat**  - set or reset memory allocation table  
    
```
    setmat sXX
```
  
        where s is set or reset (1 or 0)  
        XX is a memory page  
        page is defined as the hiword of a full address. ie. if the  
        address is 0xEB03 the page is EB  
        example: setmat 10F - set the memory allocation table at page 0F
            or   setmat 00F - reset the memory allocation table at page 0F

**hexdump**  - hexdump the contents of a file to the display  
    
```
    hexdump filename
```


