;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Button_Create.s V1.0.0
;
;     Button.class V1.0.0
;
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassCreate	Mov	eax,BC_SIZE
	XOr	ebx,ebx
	LIB	AllocMem,[ebp+_SysBase]
	Push	eax
	INITLIST	[eax+LN_SIZE]
	Pop	eax

	Push dword	[ebp+_ClassID]
	Pop dword	[eax+CD_ClassID]

	Mov dword	[eax+CD_MinWidth],20	;10+(6*8)	; 6*CharWidth
	Mov dword	[eax+CD_MaxWidth],60	;10+(20*8)	; 20*CharWidth
	Mov dword	[eax+CD_MinHeight],12	; 2+CharHeight
	Mov dword	[eax+CD_MaxHeight],24	; 2+CharHeight
	Ret
