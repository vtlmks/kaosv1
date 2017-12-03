;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     SetSystemTime.s V1.0.0
;
;     Set system date and time.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
;  Inputs:
;
;   ecx = datetime structure to set date/time to. DT_Flags filters out whichs
;         items to be set.
;
;  Output:
;
;   None.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
TMR_SetSystemTime	PushFD
	PushAD

	Or dword	[ecx+DT_Flags],DTF_WRITE
	Lea	eax,[SysBase+SB_TimerServiceList]
	Mov	ebx,ecx
	ADDTAIL
	LIBCALL	Sleep,ExecBase

	Mov	eax,ecx
	REMOVE

	PopAD
	PopFD
	Ret
