;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     InsertNode.s V1.0.0
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Insert node
;
; Inputs:
;
;  eax = list ptr
;  ebx = node to insert
;  ecx = node after which to insert
;
; Output:
;
;  None
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UTIL_InsertNode	PushFD
	PUSHX	ebx,ecx,edx
	Test	ecx,ecx
	Jz	.AddHead
	Mov	edx,[ecx+LN_SUCC]
	Test	edx,edx
	Jz	.AddTail
	Mov	eax,edx
	Mov	[ebx+LN_SUCC],edx
	Mov	[ebx+LN_PRED],ecx
	Mov	[eax+LN_PRED],ebx
	Mov	[ecx+LN_SUCC],ebx
	POPX	ebx,ecx,edx
	PopFD
	Ret
	;
.AddTail	Mov	[ebx+LN_SUCC],ecx
	Mov	eax,[ecx+LN_PRED]
	Mov	[ebx+LN_PRED],eax
	Mov	[ecx+LN_PRED],ebx
	Mov	[eax+LN_SUCC],ebx
	POPX	ebx,ecx,edx
	PopFD
	Ret
	;
.AddHead	ADDHEAD
	POPX	ebx,ecx,edx
	PopFD
	Ret

