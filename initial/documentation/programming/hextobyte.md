[index.md](index.md)
# hextobyte

 library: system 
 
 .equ HEXTOBYTE,	8 
 
    load HL registers with the 2 ascii characters of a hexadecimal value  
    
 note routine does not validate the inputs. 
 
 alphabeta expected in uppercase  
 
	ld h,'c'  
	ld l,'3'  
	call hextobyte  
	
	value stored in A register 
	
	