@echo off
echo Assembling font.library
nasm -f aout -o font.bin font.s
aoutconv font.bin font.library	> nul:
del font.bin
move font.library ..\..\ > nul:
