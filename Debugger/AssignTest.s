;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AssignTest.s V1.0.0
;
;     -
;

AssignTest	Lea	ecx,[AssignProcTags]
	LIBCALL	AddProcess,ExecBase
	Ret

AssignProcTags	Dd	AP_PROCESSPOINTER,AssignProc
	Dd	AP_PRIORITY,0
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,1024
	Dd	AP_RING,2
	Dd	AP_QUANTUM,2
	Dd	AP_NAME,AssignProcN
	Dd	TAG_DONE

AssignProcN	Db	'assigntest',0



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
AssignProc	Lea	esi,[AssignList]
.L	Lodsd
	Test	eax,eax
	Jz	.Done
	;
	Mov	ebx,eax
	Lodsd
	LIBCALL	AssignPath,DosBase

	Push	eax
	Lea	eax,[ReturnCodeTxt]
	Int	0xff
	Pop	eax
	Int	0xfe

	Jmp	.L

.Done	Lea	eax,[AssignFileOpen]
	Xor	ebx,ebx
	LIBCALL	Open,DosBase
	Mov	ebx,24
	Mov	ecx,0x400000
	LIBCALL	Read,DosBase
	Jmp	$

	Ret

AssignFileOpen	Db	"fonts:dummy",0


AssignList	Dd	Assign1Src,Assign1N
	Dd	Assign2Src,Assign2N
	Dd	Assign3Src,Assign3N
	Dd	Assign4Src,Assign4N
	Dd	Assign5Src,Assign5N
	Dd	0

Assign1Src	Db	"System:Sys/Devices/",0
Assign2Src	Db	"System:Sys/Fonts/",0
Assign3Src	Db	"System:Sys/Libraries/",0
Assign4Src	Db	"System:Sys/Scripts/",0
Assign5Src	Db	"System:Sys/Settings/",0

Assign1N	Db	"Devs",0
Assign2N	Db	"Fonts",0
Assign3N	Db	"Libs",0
Assign4N	Db	"Scripts",0
Assign5N	Db	"Settings",0

ReturnCodeTxt	Db	"Assign returncode: ",0
