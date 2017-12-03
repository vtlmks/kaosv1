@echo off
nasm -f aout -o floppy.aout floppy.s
aoutconv floppy.aout floppy.device
del floppy.aout

