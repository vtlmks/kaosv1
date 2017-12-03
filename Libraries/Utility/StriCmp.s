;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     StriCmp.s V1.0.0
;
;     Case insensitive string compare.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; StrCmp() - String insensitive compare
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
UTIL_StriCmp	PushFD
	PUSHX	ebx,ecx,esi,edi
	Mov	esi,eax
	Mov	edi,ebx
	Cld
.Loop	Lodsb
	Mov	cl,[edi]
	Inc	edi
	Call	.Case
	Cmp	al,cl
	Jne	.NotEqual
	Test	al,al
	Jnz	.Loop
	XOr	eax,eax
	Jmp	.Done
.NotEqual	Sub	al,cl
	Movzx	eax,al
	Bt	eax,7
	Jc	.Neg
	Mov	eax,1
	Jmp	.Done
	;
.Neg	Mov	eax,-1
.Done	POPX	ebx,ecx,esi,edi
	PopFD
	Ret

	;--
.Case	XOr	ebx,ebx
	Cmp	al,65
	Jb	.NoAL
	Cmp	al,167
	Ja	.NoAL
	Movzx	ebx,al
	Mov	al,[CaseTable+ebx-65]
	;
.NoAL	Cmp	cl,65
	Jb	.NoCL
	Cmp	cl,167
	Ja	.NoCL
	Movzx	ebx,cl
	Mov	cl,[CaseTable+ebx-65]
.NoCL	Ret


	; chars between 65-167
CaseTable	Db	"abcdefghijklmnopqrstuvwxyz[\]^_`"
	Db	"abcdefghijklmnopqrstuvwxyz{|}~"
	Db	127
	Db	"çüéâäàåçêëèïîìäåéææôöòûùÿöü¢£¥pƒáíóúññªº"
