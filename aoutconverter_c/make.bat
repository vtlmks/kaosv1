@echo off
echo Assembling fonto..
REM nasm -f aout -o h.aout h.s
nasm -f aout -o master.aout master.s
nasm -f aout -o slave.aout slave.s
nasm -f aout -o memtest.aout memtest.s

REM aoutconv h.aout h.mex	> nul:
aoutconv master.aout master.mex	> nul:
aoutconv slave.aout slave.mex	> nul:
aoutconv memtest.aout memtest.mex > nul
 
del *.aout



