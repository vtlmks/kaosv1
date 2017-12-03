;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     RemTimerEvent.s V1.0.0
;
;     Removes an added timer event from the TimerEvent list. Please note that
;     this function will not free the entry, only remove it from the list.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Inputs:
;
;  ecx = timerevent structure returned by AddTimerEvent
;
; Output:
;
;  None
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
TMR_RemTimerEvent	PushFD
	Test	ecx,ecx
	Jz	.Done
	PUSHX	eax,ebx,esi
	;
	Lea	esi,[SysBase+SB_TimerEventList]
	SPINLOCK	esi
	;
	Mov	eax,ecx
	REMOVE
	;
	SPINUNLOCK	esi
	;
	POPX	eax,ebx,esi
.Done	PopFD
	Ret

