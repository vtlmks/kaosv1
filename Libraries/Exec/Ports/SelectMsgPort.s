;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;    SelectMsgPort.s V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; SelectMsgPort
;
; Input:
;  eax - Data ; either a pointer to one messageport or to an array of messageports
;  ebx - Selecttype ; one, list or all
;
; EnablePort	- eax should contain a pointer to the messageport to be selected
;
; EnableList	- eax should contain a pointer to a nullterminated array of messageports to be enabled
;
; EnableAll	- eax can be anything.
;
; Disable	- eax should contain a pointer to the messageport to disable
;
; DisableList	- eax should contain a pointer to a nullterminated array of messageports to be disabled
;
; DisableAll	- eax can be anything
;
; SystemSet	- For system use only.
;
; SystemReset	- For system use only.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_SelectMsgPort	PushFD
	PUSHX	ebx,esi
	Cld
	Cmp	ebx,.SelectNum
	Ja	.OutOfBounds
	Call	[.SelectTab+ebx*4]
.OutOfBounds	POPX	ebx,esi
	PopFD
	Ret



	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.SelectTab	Dd	ESMPEnable
	Dd	ESMPEnableList
	Dd	ESMPEnableAll
	Dd	ESMPDisable
	Dd	ESMPDisableList
	Dd	ESMPDisableAll
	Dd	ESMPSystemSet
	Dd	ESMPSystemReset

.SelectNum	Equ	($-.SelectTab)/4

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ESMPEnable	SPINLOCK	eax
	Or dword	[eax+MP_FLAGS],MPF_SELECTED
	SPINUNLOCK	eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ESMPEnableList	Mov	esi,eax
.Loop	Lodsd
	Test	eax,eax
	Jz	.Exit
	SPINLOCK	eax
	Or dword	[eax+MP_FLAGS],MPF_SELECTED
	SPINUNLOCK	eax
	Jmp	.Loop
.Exit	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ESMPEnableAll	Mov	eax,[SysBase+SB_CurrentProcess]
	Lea	eax,[eax+PC_PortList]
	SPINLOCK	eax
	Push	eax
.Loop	NEXTNODE	eax,.Exit
	SPINLOCK	eax
	Or dword	[eax+MP_FLAGS],MPF_SELECTED
	SPINUNLOCK	eax
	Jmp	.Loop
.Exit	Pop	eax
	SPINUNLOCK	eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ESMPDisable	SPINLOCK	eax
	And dword	[eax+MP_FLAGS],~MPF_SELECTED
	SPINUNLOCK	eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ESMPDisableList	Mov	esi,eax
.Loop	Lodsd
	Test	eax,eax
	Jz	.Exit
	SPINLOCK	eax
	And dword	[eax+MP_FLAGS],~MPF_SELECTED
	SPINUNLOCK	eax
	Jmp	.Loop
.Exit	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ESMPDisableAll	Mov	eax,[SysBase+SB_CurrentProcess]
	Lea	eax,[eax+PC_PortList]
	SPINLOCK	eax
	Push	eax

.Loop	NEXTNODE	eax,.Exit
	SPINLOCK	eax
	And dword	[eax+MP_FLAGS],~MPF_SELECTED
	SPINUNLOCK	eax
	Jmp	.Loop

.Exit	Pop	eax
	SPINUNLOCK	eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ESMPSystemSet	Push	eax

	Mov	eax,[SysBase+SB_CurrentProcess]
	Lea	eax,[eax+PC_PortList]
	SPINLOCK	eax
	Push	eax

.Loop	NEXTNODE	eax,.Exit
	SPINLOCK	eax
	Or dword	[eax+MP_FLAGS],MPF_SYSDISABLED
	SPINUNLOCK	eax
	Jmp	.Loop

.Exit	Pop	eax
	SPINUNLOCK	eax

	Pop	eax
	SPINLOCK	eax
	Or dword	[eax+MP_FLAGS],MPF_SYSSELECTED
	And dword	[eax+MP_FLAGS],~MPF_SYSDISABLED
	SPINUNLOCK	eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ESMPSystemReset	Mov	eax,[SysBase+SB_CurrentProcess]
	Lea	eax,[eax+PC_PortList]
	SPINLOCK	eax
	Push	eax

.Loop	NEXTNODE	eax,.Exit
	SPINLOCK	eax
	And dword	[eax+MP_FLAGS],~(MPF_SYSSELECTED|MPF_SYSDISABLED)
	SPINUNLOCK	eax
	Jmp	.Loop

.Exit	Pop	eax
	SPINUNLOCK	eax
	Ret
