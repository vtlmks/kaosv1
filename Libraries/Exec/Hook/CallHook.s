;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     CallHook.s V1.0.0
;
;     Call an initiated hook.
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Inputs:
;
;  eax - Hook
;  ebx - Object
;  ecx - Packet
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_CallHook	PushFD
	Cmp dword	[eax+H_ENTRY],0
	Je	.NoHook
	Call	[eax+H_ENTRY]
.NoHook	PopFD
	Ret
