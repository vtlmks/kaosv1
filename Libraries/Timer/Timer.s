;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Timer.s V1.0.0
;
;     Timer Library.
;


	%Include	"Includes\TypeDef.I"
	%Include	"Includes\Lists.I"
	%Include	"Includes\Macros.I"
	%Include	"Includes\Nodes.I"
	%Include	"Includes\Ports.I"
	%Include	"Includes\TagList.I"
	%Include	"Includes\Libraries.I"
	%Include	"Includes\Dos\Dos.I"
	%Include	"Includes\Exec\LowLevel.I"
	%Include	"Includes\Exec\Memory.I"
	%Include	"Includes\Libraries\Font.I"
	%Include	"Includes\LVO\Dos.I"
	%Include	"Includes\LVO\Exec.I"
	%Include	"Includes\LVO\Utility.I"
	%Include	"Includes\SysBase.I"

TimerStart	Lea	eax,[TimerLibTag]
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

TimerVersion	Equ	1
TimerRevision	Equ	0

TimerLibTag	Dd	LT_FLAGS,0
	Dd	LT_VERSION,TimerVersion
	Dd	LT_REVISION,TimerRevision
	Dd	LT_TYPE,NT_LIBRARY
	Dd	LT_PRIORITY,0
	Dd	LT_NAME,TimerName
	Dd	LT_IDSTRING,TimerIDString
	Dd	LT_INIT,TimerInitTable
	Dd	TAG_DONE

TimerInitTable	Dd	0
	Dd	TimerBase
	Dd	TimerInit
	Dd	-1

TimerName	Db	"timer.library",0
TimerIDString	Db	"timer.library 1.0 (2001-03-26)",0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
TimerOpenCount	Dd	0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
OpenTimerLib	Inc dword	[TimerOpenCount]
	Ret


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
CloseTimerLib	Cmp dword	[TimerOpenCount],0
	Je	.Done
	Dec dword	[TimerOpenCount]
.Done	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
ExpungeTimerLib	Mov	eax,-1
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
NullTimerLib	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
TimerInit	Lea	ecx,[TimerProcTags]
	LIBCALL	AddProcess,ExecBase
	Ret


TimerProcTags	Dd	AP_PROCESSPOINTER,TimerProcess
	Dd	AP_PRIORITY,0
	Dd	AP_STACKSIZE,1024
	Dd	AP_NAME,TimerName
	Dd	TAG_DONE



	Struc TimerProcStruc
TP_SysBase	ResD	1
TP_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
TimerProcess	LINK	TP_SIZE
	Mov	[ebp+TP_SysBase],eax

.Main	LIBCALL	Sleep,ExecBase

	Mov	esi,[SysBase+SB_TimerDeadList]
.L	SUCC	esi
	Cmp dword	[esi+TE_Ticks],0
	Jne	.NoTimeout
	;
	Mov	eax,esi		; Remove from list
	REMOVE
	;
	Mov	eax,[esi+TE_Port]
	Mov dword	[esi+MN_REPLYPORT],0
	Mov	ebx,esi
	LIBCALL	PutMsg,ExecBase
	;
.NoTimeout	Test	esi,esi
	Jnz	.L
	Jmp	.Main

	UNLINK	TP_SIZE
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Dd	TMR_UDelay		; -48
	Dd	TMR_Delay		; -44
	Dd	TMR_SetSystemTime		; -40
	Dd	TMR_GetSystemTime		; -36
	Dd	TMR_RemTimerEvent		; -32
	Dd	TMR_AddTimerEvent		; -28
	Dd	NullTimerLib		; -24
	Dd	NullTimerLib		; -20
	Dd	NullTimerLib		; -16
	Dd	ExpungeTimerLib		; -12
	Dd	CloseTimerLib		; -8
	Dd	OpenTimerLib		; -4
TimerBase:


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	%Include	"Libraries\Timer\AddTimerEvent.s"
	%Include	"Libraries\Timer\RemTimerEvent.s"
	%Include	"Libraries\Timer\GetSystemTime.s"
	%Include	"Libraries\Timer\SetSystemTime.s"
	%Include	"Libraries\Timer\Delay.s"
	%Include	"Libraries\Timer\UDelay.s"


