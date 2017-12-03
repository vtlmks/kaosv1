;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AllocIORequest.s V1.0.0
;
;     Allocates an IO request for use with devices.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Input:
;  eax = Size of IORequest to be allocated.
;  ebx = msgport(aptr)
;
; Output:
;  eax = Pointer to allocated IO request, or zero for failure.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_AllocIORequest	PUSHX	ebx,ecx,edx
	PushFD
	Push	eax
	Push	ebx

	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Test	eax,eax
	Jz	.Failure
	Pop	ebx
	Mov	[eax+MN_REPLYPORT],ebx
	Pop	ebx
	Mov	[eax+MN_LENGTH],ebx
.Failure	PopFD
	POPX	ebx,ecx,edx
	Ret

