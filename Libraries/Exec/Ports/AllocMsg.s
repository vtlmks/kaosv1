;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AllocMsg.s V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; AllocMsg -- Allocate and initialize a message
;
; Inputs:
;
;  eax - Replyport
;  ebx - Length of message
;
; Output:
;
;  eax - Pointer to allocated message or null for failure
;
; TODO:
;
;  Mayhaps add more parameters
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_AllocMsg	PushFD
	PUSHX	ebx,edx
	Mov	edx,eax
	Push	ebx
	Lea	eax,[ebx+MN_SIZE]
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Test	eax,eax
	Jz	.NoMemory
	Pop dword	[eax+MN_LENGTH]		; Size
	Mov	[eax+MN_REPLYPORT],edx
	Lea	eax,[eax+MN_SIZE]
.NoMemory	POPX	ebx,edx
	PopFD
	Ret
