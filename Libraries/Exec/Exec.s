;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Exec.s V1.0.0
;
;     Exec.library V1.0.0
;
;     This is the exec.library core, not like other libraries...
;
;

	%Include	"Libraries\Exec\CloseClass.s"
	%Include	"Libraries\Exec\CloseLibrary.s"
	%Include	"Libraries\Exec\OpenLibrary.s"
	%Include	"Libraries\Exec\OpenClass.s"

	%Include	"Libraries\Exec\Hook\Hook.s"
	%Include	"Libraries\Exec\Memory\Memory.s"
	%Include	"Libraries\Exec\LowLevel\LowLevel.s"
	%Include	"Libraries\Exec\Ports\Ports.s"
	%Include	"Libraries\Exec\IO\IO.s"

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
LIB_OpenCount	Dd	1

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
OpenExec	Mov	eax,ExecBase
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
CloseExec:
ExpungeExec	Mov	eax,-1
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
NullExec	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Dd	EXEC_FreeMsg		; -196
	Dd	EXEC_AllocMsg		; -192
	Dd	EXEC_InitDMA		; -188
	Dd	EXEC_FreeDMA		; -184
	Dd	EXEC_AllocDMA		; -180
	;-
	Dd	EXEC_MapMemory		; -176
	Dd	EXEC_SelectMsgPort	; -172
	;-
	Dd	EXEC_CloseClass		; -168
	Dd	EXEC_OpenClass		; -164
	;-
	Dd	EXEC_Sleep		; -160
	Dd	EXEC_Awake		; -156
	;-
	Dd	EXEC_RemoveIRQ		; -152
	Dd	EXEC_AddIRQ		; -148
	;-
	Dd	EXEC_Print		; -144	; REMOVE later
	;-
	Dd	EXEC_CallHook		; -140
	;-
	Dd	EXEC_FindPort		; -136
	Dd	EXEC_RemovePort		; -132
	Dd	EXEC_AddPort		; -128
	Dd	EXEC_FindProcess		; -124
	Dd	EXEC_Disable		; -120
	Dd	EXEC_Enable		; -116
	Dd	EXEC_Wait		; -112
	Dd	EXEC_WaitIO		; -108
	Dd	EXEC_SendIO		; -104
	Dd	EXEC_FreeIORequest	; -100
	Dd	EXEC_CheckIO		; -96
	Dd	EXEC_AllocIORequest	; -92
	Dd	EXEC_AbortIO		; -88
	;-
	Dd	EXEC_CloseDevice		; -84
	Dd	EXEC_OpenDevice		; -80
	Dd	EXEC_CloseLibrary		; -76
	Dd	EXEC_OpenLibrary		; -72
	;-
	Dd	EXECP_UserSwitch		; -68
	Dd	EXEC_AddProcess		; -64
	Dd	EXEC_ReplyMsg		; -60
;	Dd	EXEC_GetMsgFromPort	; -56
	Dd	EXEC_GetMsg		; -52
	Dd	EXEC_PutMsg		; -48
	Dd	EXEC_DeleteMsgPort	; -44
	Dd	EXEC_CreateMsgPort	; -40
	Dd	EXEC_AvailMem		; -36
	Dd	EXEC_FreeMem		; -32
	Dd	EXEC_AllocMem		; -28
	;-
	Dd	NullExec		; -24
	Dd	NullExec		; -20
	Dd	NullExec		; -16
	Dd	ExpungeExec		; -12
	Dd	CloseExec		; -8
	Dd	OpenExec		; -4
ExecBase:

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXECP_UserSwitch	Int	0x60
	Ret

EXEC_Print	PushAD
	PushFD
	Mov	esi,eax
	Call	DebWriteLines
	PopFD
	PopAD
	Ret

