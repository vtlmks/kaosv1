;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     FindPort.s V1.0.0
;
;     Find a message port in the public message list.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; FindPort - Find a message port in the public message list.
;
;
; Inputs:
;  eax - Pointer to message port name
;
; Output:
;  eax - Port or null for failure.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_FindPort	PushFD
	PUSHX	ebx
	;
	Test	eax,eax
	Jz	.Done
	Lea	ebx,[SysBase+SB_PortList]
	SPINLOCK	ebx
	LIBCALL	FindName,UteBase
	SPINUNLOCK	ebx
	Test	eax,eax
	Jz	.Done
	Mov	eax,[eax+NP_PORTPOINTER]
	;
.Done	POPX	ebx
	PopFD
	Ret
