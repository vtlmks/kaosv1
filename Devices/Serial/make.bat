@echo off
nasm -f aout -o serial.aout serial.s
aoutconv serial.aout serial.device
del serial.aout

