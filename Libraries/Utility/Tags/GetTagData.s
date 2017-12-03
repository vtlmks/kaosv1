;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     GetTagData.s V1.0.0
;
;     Return a tags data in a taglist.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Inputs: eax = Tagitem
;         ebx = Taglist ptr
;
; Output: eax = Tagdata or null if not found
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UTIL_GetTagData	PUSHX	ebx,edx
.Loop	Mov	edx,[ebx+TI_TAG]
	Test	edx,edx
	Jz	.Null
	Cmp	edx,eax
	Je	.End
	Lea	ebx,[ebx+TI_SIZE]
	Jmp	.Loop
	;
.Null	XOr	eax,eax
	POPX	ebx,edx
	Ret
	;
.End	Mov	eax,[ebx+TI_DATA]
.Done	POPX	ebx,edx
	Ret
