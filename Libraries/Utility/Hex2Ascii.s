;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Hex2AscII.s V1.0.0
;
;     Hex to AscII conversion routine.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Hex2AscII()
;
; Input  : eax = Longword to be converted
;          ebx = Pointer to 8 byte buffer for result
;
; Output : Buffer contains converted string
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UTIL_Hex2Ascii	PushFD
	PUSHX	ebx,ecx
	Cld
	Mov	edi,ebx
	Mov	ecx,8
.L	Rol	eax,4
	Push	eax
	And	al,0x0f
	Cmp	al,0x0a
	Sbb	al,0x69
	Das
	Mov	ah,7
	Stosb
	Pop	eax
	Dec	ecx
	Jnz	.L
	POPX	ebx,ecx
	PopFD
	Ret
