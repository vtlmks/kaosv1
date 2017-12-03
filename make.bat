@echo off

rem set Root=z:\
set Root=Z:\ToBeUploadedToGithub\Kaos\
rem set Root=c:\kaos\

If "%1" == "-clean" Goto Clean

rem -   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
echo Assembling kernel..

cd %root%debugger\
nasm -o SwitchbackWithin.bin SwitchbackWithin.s -l switchbackwithin.lst
nasm -o switchbackJump.bin switchbackJump.s -l switchbackjump.lst

cd %root%kernel\
nasm -o V86System.bin V86System.s -l V86System.lst

cd %root%
nasm -i%Root% -o %Root%kaos.com %Root%init\Init.s -l kaos.lst
nasm -i%Root% -o %Root%kernel.bin %Root%kernel\kernel.s -l kernel.lst
nasm -o%Root%default.config %Root%guiconfig.s

cd %Root%aoutconverter_c\
call %Root%aoutconverter_c\make.bat

echo External libraries:

cd %Root%libraries\font\
call %Root%libraries\font\make.bat

cd %Root%libraries\clip\
call %Root%libraries\clip\make.bat

cd %Root%classes\
call %Root%classes\make.bat

cd %Root%

goto Done

rem -   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
:Clean
echo Cleaning kernel directory...
del kaos.com > nul:
del kernel.bin > nul:
del kaos.lst > nul:
del kernel.lst > nul:

del default.config > nul:

del *.class > nul:
del *.library > nul:
rem -   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
:Done
echo Done!

