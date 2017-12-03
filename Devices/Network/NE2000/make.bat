@echo off
nasm -f aout -o ne2000.aout ne2000.s -l ne2000.lst
aoutconv ne2000.aout ne2k.device
del ne2000.aout

