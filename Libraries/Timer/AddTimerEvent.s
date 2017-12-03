;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AddTimerEvent.s V1.0.0
;
;     AddTimerEvent.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; AddTimerEvent
;
; Inputs:
;
;  ecx = timerevent structure
;
; Output:
;
;  none
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
TMR_AddTimerEvent	PushFD
	PushAD
	Cmp dword	[ecx+TE_Ticks],0
	Je	.Done
	;
	XOr	edi,edi
	Mov	edx,[ecx+TE_Ticks]
	Lea	esi,[SysBase+SB_TimerEventList]
	SPINLOCK	esi
.L	NEXTNODE	esi,.InsertTail
	Add	edi,[esi+TE_Ticks]
	Cmp	edi,edx
	Jb	.L
	Sub	edi,[esi+TE_Ticks]
	Sub	edx,edi
	Mov	[ecx+TE_Ticks],edx
	;
	Push	esi
	NEXTNODE	esi,.NoNext
	Sub	[esi+TE_Ticks],edx
.NoNext	Pop	esi
	Push	ecx
	Lea	eax,[SysBase+SB_TimerEventList]
	Mov	ebx,ecx
	Mov	ecx,esi
	LIBCALL	InsertNode,UteBase
	Pop	ecx
.Done	Lea	esi,[SysBase+SB_TimerEventList]
	SPINUNLOCK	esi
	PopAD
	PopFD
	Ret
	;--
.InsertTail	Lea	eax,[SysBase+SB_TimerEventList]
	Sub	edx,edi
	Mov	[ecx+TE_Ticks],edx
	Mov	ebx,ecx
	ADDTAIL
	Jmp	.Done
