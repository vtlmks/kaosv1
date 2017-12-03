;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Switchback.s V1.0.0
;
;     Protectedmode-Realmode-Protectedmode switcher.
;     This is supposed to be somekind of a trampoline to call certain
;     BIOS functions from the KAOS kernel..
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Switchback function.. switches between protectedmode->realmode->protectedmode
; and performs the submitted BIOS function whilst inside realmode
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SwitchBack	Lea	esi,[SwitchBack2]
	Mov	edi,0x40000		; copy part 1 of the trampoline to 0x40000 and continue
	Mov	ecx,1024/4		; execution from there...
	Rep Movsd
	Mov	eax,0x40000
	Int	0x40		; we like to stay alone..
	Ret


	;--
SwitchBack2	Incbin	"Debugger\SwitchBackJump.bin"

