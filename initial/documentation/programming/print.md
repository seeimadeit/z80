# Title

	# === PRINTLN == #
	ld hl, string to print
	println: ;// same as print but appends CRLF

	# === PRINT === #
	ld hl, string to print
	print: ;// expecting a zero terminated string
	
	

```
	ld hl,msg
	call println
	ret
	
	msg: .string "hello"
```
