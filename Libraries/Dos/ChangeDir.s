;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     ChangeDir.s V1.0.0
;
;
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Inputs:
;
;  eax = Lock
;
; Output:
;
;  eax = Previous lock or null for failure
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc ChangeDir
.Path	ResD	1
.OldLock	ResD	1
.SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DOS_ChangeDir	PushFD
	PushAD
	LINK	ChangeDir.SIZE
	Test	eax,eax
	Jz	.Failure
	Mov	[ebp+ChangeDir.Path],eax


	XOr	eax,eax
	LIBCALL	FindProcess,ExecBase
	Mov	edi,eax
	;


	UNLINK	ChangeDir.SIZE
	PopAD
	PopFD
	Ret

.Failure	UNLINK	ChangeDir.SIZE
	PopAD
	XOr	eax,eax
	PopFD
	Ret

