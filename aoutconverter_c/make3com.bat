@echo off
nasm -f aout -o 3com.aout 3com.s
aoutconv 3com.aout 3com.mex
del 3com.aout
copy 3com.mex c:\3com


