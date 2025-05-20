@echo off

IF EXIST uncleduck.bin move /Y uncleduck.bin uncleduck.prev.bin >NUL
asm68k /k /p /o ae-,c+ uncleduck.asm, uncleduck.bin >errors.txt, , uncleduck.lst
fixheadr.exe uncleduck.bin
