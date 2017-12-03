@echo off
echo Assembling clip.library
nasm -f aout -o clip.bin clip.s
aoutconv clip.bin clip.library	> nul:
del clip.bin
move clip.library ..\..\ > nul:
