;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     FindTag.s V1.0.0
;
;     Return TI_TAG of a tagitem in a taglist.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Inputs:
;  eax = Tagitem
;  ebx = Taglist ptr
;
; Output:
;  eax = Pointer to TI_TAG, or null if not found
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UTIL_FindTag	PUSHX	ebx,edx
.Loop	Mov	edx,[ebx+TI_TAG]
	Test	edx,edx
	Jz	.Null
	Cmp	edx,eax
	Je	.End
	Lea	ebx,[ebx+TI_SIZE]
	Jmp	.Loop
	;
.Null	XOr	eax,eax
	Jmp	.Done
	;
.End	Lea	eax,[ebx+TI_TAG]
.Done	POPX	ebx,edx
	Ret
