;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     FilePart.s V1.0.1
;
;     Get the filepart from a path.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Returns the filepart of a filepath, i.e. "Root:Bin/Kernel" will
; return "Kernel".
;
; 1.01 - Function now handles files without a path and/or volume.
;
;
; Inputs:
;  eax = pointer to nullterminated string
;
; Output:
;  eax = pointer to filepart or null.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DOS_FilePart	PushFD
	PUSHX	ecx,edx,esi
	Mov	esi,eax
	Mov	edx,eax
	XOr	ecx,ecx
	Cld
.L	Lodsb
	Test	al,al
	Jz	.Done
	Cmp	al,"/"
	Jne	.NoSlash
	Mov	ecx,esi
.NoSlash	Cmp	al,":"
	Jne	.NoDevice
	Mov	ecx,esi
.NoDevice	Jmp	.L
	;
.Done	Mov	eax,ecx
	Test	ecx,ecx
	Jnz	.HasPath
	Mov	eax,edx
.HasPath	POPX	ecx,edx,esi
	PopFD
	Ret
