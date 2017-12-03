;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Sleep.s V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_Sleep	PushFD
	Mov	eax,[SysBase+SB_CurrentProcess]
	Or dword	[eax+PC_Flags],PCF_SLEEP
	LIBCALL	Switch,ExecBase
	PopFD
	Ret
