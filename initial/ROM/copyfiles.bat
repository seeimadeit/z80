@echo off
echo max 8 characters

if exist "ram" (
	copy RAM f:\ 
) else (
	echo "no RAM file."
	pause
	)

if exist "cmd" (
	copy cmd f:\ 
) else (
	echo "no cmd file."
	pause
	)


if exist "hello" (
	copy hello f:\ 
) else (
	echo "no hello file."
	pause
	)

if exist "run@5000" (
	copy run@5000 f:\ 
) else (
	echo "no run@5000 file."
	pause
	)


if exist "edit" (
	copy edit f:\ 
) else (
	echo "no edit file."
	pause
	)


if exist "dir" (
	copy dir f:\ 
) else (
	echo "no dir file."
	pause
	)



if exist "type" (
	copy type f:\ 
) else (
	echo "no type file."
	pause
	)



if exist "hexdump" (
	copy hexdump f:\ 
) else (
	echo "no hexdump file."
	pause
	)



if exist "asm" (
	copy asm f:\ 
) else (
	echo "no asm file."
	pause
	)


if exist "small.s" (
	copy small.s f:\ 
) else (
	echo "no small.s file."
	pause
	)

if exist "keyboardtest" (
	copy keyboardtest f:\ 
) else (
	echo "no keyboardtest file."
	pause
	)

if exist "screen.lib" (
	copy screen.lib f:\ 
) else (
	echo "no screen.dll file."
	pause
	)

if exist "keyboard.lib" (
	copy keyboard.lib f:\
) else (
	echo no keyboard.lib
	pause
	)


if exist "setmat" (
	copy setmat f:\
) else (
	echo no setmat
	pause
	)

if exist "proc" (
	copy proc f:\
) else (
	echo no proc
	pause
	)

rem if exist "x" (	copy x f:\ ) else (	echo "no x file."	pause	)



pause