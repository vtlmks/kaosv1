@echo off
nasm -f aout -o newdevice.com newdevice.s
aoutconv newdevice.com xxx.device
copy xxx.device c:\
del newdevice.com

