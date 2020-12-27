[index.md](index.md)
# createprocess

	# === createProcess == #  
	;# stack - note the example below is using the registers as an example, it really don't matter  
	;# which register pair put that data on the stack, the sequence in which the parameters are put on the stack  
	;# does matter.  
	;# push hl,program - zero terminated  
	;# push de,commandline - zero terminated  
	;# call createProcess  
	;# that should do for now  

