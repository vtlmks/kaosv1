;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     GetSystemTime.s V1.0.0
;
;     Get system date and time.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
;  Inputs:
;
;   ecx = datetime structure
;
;  Output:
;
;   ecx = submitted datetime structure is filled with the system
;         current date and time.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
TMR_GetSystemTime	PushFD
	PushAD

	Or dword	[ecx+DT_Flags],DTF_READ
	Lea	eax,[SysBase+SB_TimerServiceList]
	Mov	ebx,ecx
	ADDTAIL
	LIBCALL	Sleep,ExecBase

	Mov	eax,ecx
	REMOVE
	PopAD
	PopFD
	Ret


