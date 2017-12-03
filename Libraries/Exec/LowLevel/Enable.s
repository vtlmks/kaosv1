;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Enable.s V1.0.0
;
;     Enables interrupts again, see Disable.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_Enable	PUSHX	ebx
	PushFD

	Dec dword	[SysBase+SB_DisableTemp]
	Jnz	.NoEnable

	Mov	ebx,[SysBase+SB_CurrentProcess]
	And dword	[ebx+PC_Flags],~PCF_NOSWITCH

.NoEnable	PopFD
	POPX	ebx
	Ret
