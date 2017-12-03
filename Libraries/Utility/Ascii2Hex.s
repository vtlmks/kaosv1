;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Ascii2Hex.s V1.0.0
;
;     AscII to Hex conversion routine.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; AscII2Hex()
;
; Input  : eax = Ascii String (hex value), upto 8 bytes + null termination
;
; Output : eax = Converted value as longword.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UTIL_Ascii2Hex	PushFD
	PUSHX	ebx,ecx
	XOr	ebx,ebx
	XOr	ecx,ecx
.Loop	Mov byte	bl,[eax]
	Test	bl,bl
	Jz	.Exit
	Sub	bl,0x30
	Cmp	bl,10
	Jle	.L
	Sub	bl,0x27
.L	Shl	ecx,4
	Inc	eax
	Add	ecx,ebx
	Jmp	.Loop
.Exit	Mov	eax,ecx
	POPX	ebx,ecx
	PopFD
	Ret
