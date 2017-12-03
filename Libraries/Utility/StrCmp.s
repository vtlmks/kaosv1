;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     StrCmp.s V1.0.0
;
;     Case sensitive string compare.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; StrCmp() - String compare
;
; Input  : eax - Source string, nullterminated pointer
;          ebx - Destination string, nullterminated pointer
;
; Output : eax - null if Source == Destination
;                1    if Source >  Destination
;                -1   if Source <  Destination
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UTIL_StrCmp	PushFD
	PUSHX	esi,edi
	Mov	esi,eax
	Mov	edi,ebx
	Cld
.Loop	Lodsb
	Mov	ah,[edi]
	Inc	edi
	Cmp	al,ah
	Jne	.NotEqual
	Test	al,al
	Jnz	.Loop
	XOr	eax,eax
	Jmp	.Done
.NotEqual	Sub	al,ah
	Movzx	eax,al
	Bt	eax,7
	Jc	.Neg
	Mov	eax,1
	Jmp	.Done
	;
.Neg	Mov	eax,-1
.Done	POPX	esi,edi
	PopFD
	Ret

