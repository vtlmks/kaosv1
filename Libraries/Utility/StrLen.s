;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     StrLen.s V1.0.0
;
;     Get the length of a string.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; StrLen()
;
; Input  : eax = nullterminated string
;
; Output : eax = length of string
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UTIL_StrLen	PushFD
	PUSHX	esi,ecx
	Mov	eax,esi
	Mov	ecx,-1
	Cld
.Loop	Inc	ecx
	Lodsb
	Test	al,al
	Jnz	.Loop
	Mov	eax,ecx
	POPX	esi,ecx
	PopFD
	Ret
