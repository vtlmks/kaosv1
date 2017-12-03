@echo off
nasm -f aout -o templatedevice.aout templatedevice.s
aoutconv templatedevice.aout template.device
del templatedevice.aout

