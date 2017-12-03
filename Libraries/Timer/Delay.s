;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Delay.s V1.0.0
;
;
;     Delays the given number of ticks. Note that this function will make the process
;     Sleep() until the delay time is done.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Inputs:
;
;  eax = Number of ticks to wait, 1024 ticks is (atleast) one second.
;
; Output:
;
;  eax = None.
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
TMR_Delay	PushFD
	PushAD
	Test	eax,eax
	Jz	.Done

	LINK	TE_SIZE

	Mov dword	[ebp+TE_Userdata],0
	Mov dword	[ebp+TE_Port],0
	Mov dword	[ebp+TE_Ticks],eax
	Or dword	[ebp+TE_Flags],TEF_DELAY
	XOr	eax,eax
	LIBCALL	FindProcess,ExecBase
	Mov	[ebp+TE_Process],eax

	PUSHX	edx,ebp
	Mov	ecx,ebp
	Call	TMR_AddTimerEvent
	POPX	edx,ebp

	LIBCALL	Sleep,ExecBase

	UNLINK	TE_SIZE
.Done	PopAD
	PopFD
	Ret


