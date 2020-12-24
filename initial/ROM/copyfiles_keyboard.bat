@echo off
echo max 8 characters

if exist "keyboardtest" (
	copy keyboardtestboot f:\RAM 
) else (
	echo "no keyboardtest file."
	pause
	)

pause