;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     FindProcess.s V1.0.0
;
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; FindProcess - Find a given process or yourself.
;
; Input:
;   eax - Pointer to processname or null to find yourself.
;
; Output:
;   eax - Pointer to process or null if not found.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_FindProcess	PushFD
	PUSHX	ebx,edx
	Test	eax,eax
	Jnz	.FindNamed
	Mov	eax,[SysBase+SB_CurrentProcess]
	POPX	ebx,edx
	PopFD
	Ret
	;
.FindNamed	Mov	edx,eax
	Lea	eax,[.FindNamedProc]
	Int	0x40
	POPX	ebx,edx
	PopFD
	Ret

.FindNamedProc	Mov	eax,edx
	Lea	ebx,[SysBase+SB_ProcWaitList]
	LIBCALL	FindName,UteBase
	Test	eax,eax
	Jz	.Done
	Mov	eax,edx
	Mov	ebx,[SysBase+SB_ProcTempList]
	LIBCALL	FindName,UteBase
	Test	eax,eax
	Jz	.Done
	Mov	eax,edx
	Mov	ebx,[SysBase+SB_ProcReadyList]
	LIBCALL	FindName,UteBase
.Done	Ret

