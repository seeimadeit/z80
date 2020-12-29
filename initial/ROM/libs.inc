

	.ifdef __LIB__
		.ifdef __ORG__
			.org __ORG__
		.else 
			.org dllMemory
		.endif
		.2byte $ ;# load address
		.byte ((ENDADDRESS-$)/255)+1 ;# memory required to load (in pages)
		.ifdef __STACK__
			.byte __STACK__
		.else 
			.byte 1 ;# stack size (in pages)
		.endif
		jp libaddress
initialize:
	.else
		.ifdef __ORG__
			.org __ORG__
		.else
			.org userMemory
		.endif
		.2byte $ ;# load address
		.byte ((ENDADDRESS-$)/255)+1 ;# memory required to load (in pages)
		.ifdef __STACK__
			.byte __STACK__
		.else 
			.byte 1 ;# stack size (in pages)
		.endif
	.endif

	ld a,PRINT
	call GetAddress
	ld (printadr),hl
	ld a,PRINTHEX
	call GetAddress
	ld (printhexadr),hl
	ld a,LOADFILE
	call GetAddress
	ld (loadfileadr),hl
	ld a,MEMSET
	call GetAddress
	ld (memsetadr),hl
	ld a,STRLEN
	call GetAddress
	ld (strlenadr),hl
	ld a,PUTC
	call GetAddress
	ld (putcadr),hl
	ld a,TOUPPERCASE
	call GetAddress
	ld (touppercaseadr),hl
	ld a,HEXTOBYTE
	call GetAddress
	ld (hextobyteadr),hl
	ld a,PRINTLN
	call GetAddress
	ld (printlnadr),hl
	ld a,DIRECTORYOPEN
	call GetAddress
	ld (directoryopenadr),hl
	ld a,NEXTFILE
	call GetAddress
	ld (directorynextfileadr),hl
	ld a,GETFILENAME
	call GetAddress
	ld (getfilenameadr),hl
	ld a,CREATEPROCESS
	call GetAddress
	ld (createProcessadr),hl
	ld a,GETCOMMANDPARAMS
	call GetAddress
	ld (getcommandparamsadr),hl
	ld a,GETMALLOCTABLE
	call GetAddress
	ld (getmalloctableadr),hl
	ld a,DIV8
	call GetAddress
	ld (div8adr),hl
	ld a,SETRESETPAGE
	call GetAddress
	ld (setresetpageadr),hl
	ld a,PRINTHEXL
	call GetAddress
	ld (printhexLadr),hl
	ld a,STARTPROCESSINFO
	call GetAddress
	ld (startprocessinfoadr),hl
	ld a,NEXTPROCESSINFO
	call GetAddress
	ld (nextprocessinfoadr),hl
	ld a,STRCPY
	call GetAddress
	ld (strcpyadr),hl
	ld a,STRNCPY
	call GetAddress
	ld (strncpyadr),hl
	ld a,GETPROCESSBYID
	call GetAddress
	ld (getprocessbyidadr),hl
	ld a,MULTIPLY8
	call GetAddress
	ld (Mul8badr),hl
	ld a,SETPROCID
	call GetAddress
	ld (getprocidadr),hl
	call getprocid
	ld (processid),a
	ld hl,(_getprocessid)
	ld (getprocidadr),hl



	




	jp _main
	_getprocessid: 
	DEBUG '$'
	ld a,(processid)
		ret
	processid: .byte 0
	functionlookups:
	.align 2
	print: .byte 0xc3
	printadr: .2byte 0
	println: .byte 0xc3
	printlnadr: .2byte 0
	printhex: .byte 0xc3
	printhexadr: .2byte 0
	loadfile: .byte 0xc3
	loadfileadr: .2byte 0
	memset: .byte 0xc3
	memsetadr: .2byte 0
	strlen: .byte 0xc3
	strlenadr: .2byte 0
	putc: .byte 0xc3
	putcadr: .2byte 0
	touppercase: .byte 0xc3
	touppercaseadr: .2byte 0
	hextobyte: .byte 0xc3
	hextobyteadr: .2byte 0
	directoryopen: .byte 0xc3
	directoryopenadr: .2byte 0
	directorynextfile: .byte 0xc3
	directorynextfileadr: .2byte 0
	getfilename: .byte 0xc3
	getfilenameadr: .2byte 0
	createProcess: .byte 0xc3
	createProcessadr: .2byte 0
	getcommandparams: .byte 0xc3
	getcommandparamsadr: .2byte 0
	getmalloctable: .byte 0xc3
	getmalloctableadr: .2byte 0
	Div8: .byte 0xc3
	div8adr: .2byte 0
	setresetpage: .byte 0xc3
	setresetpageadr: .2byte 0
	printhexL: .byte 0xc3
	printhexLadr: .2byte 0
	startprocessinfo: .byte 0xc3
	startprocessinfoadr: .2byte 0
	nextprocessinfo: .byte 0xc3
	nextprocessinfoadr: .2byte 0
	strcpy: .byte 0xc3
	strcpyadr: .2byte 0
	strncpy: .byte 0xc3
	strncpyadr: .2byte 0
	getprocessbyid: .byte 0xc3
	getprocessbyidadr: .2byte 0
	Mul8b: .byte 0xc3
	Mul8badr: .2byte 0
	getprocid: .byte 0xc3
	getprocidadr: .2byte 0

_main:
.ifdef __DLL__
	ret
.endif