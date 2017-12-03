;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Disable.s V1.0.0
;
;     Prevent the kernel to switch process.
;     This call must be followed by an Enable()
;     call to enable switching again.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_Disable	PUSHX	ebx
	PushFD

	Mov	ebx,[SysBase+SB_CurrentProcess]
	Or dword	[ebx+PC_Flags],PCF_NOSWITCH

	Inc dword	[SysBase+SB_DisableTemp]

	PopFD
	POPX	ebx
	Ret
