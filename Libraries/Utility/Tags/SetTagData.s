;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     SetTagData.s V1.0.0
;
;     Set tagdata of given of tagitem.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Inputs:
;  eax = Tagitem
;  ebx = Taglist ptr
;  ecx = Value
;
; Output:
;  eax = Null for success
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UTIL_SetTagData	PUSHX	ebx,edx
.Loop	Mov	edx,[ebx+TI_TAG]
	Test	edx,edx
	Jz	.Null
	Cmp	edx,eax
	Je	.End
	Lea	ebx,[ebx+TI_SIZE]
	Jmp	.Loop
	;
.Null	Mov	eax,-1
	Jmp	.Done
	;
.End	Mov	[ebx+TI_DATA],ecx
.Done	POPX	ebx,edx
	Ret
