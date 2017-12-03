;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Checkbox_Create.s V1.0.0
;
;     Checkbox.class V1.0.0
;
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassCreate	Push	ecx
	Mov	eax,CB_SIZE
	XOr	ebx,ebx
	LIB	AllocMem,[ebp+_SysBase]
	Push	eax
	INITLIST	[eax+LN_SIZE]
	Pop	edi
	Pop	ebx

	Push dword	[ebp+_ClassID]
	Pop dword	[edi+CD_ClassID]

	Mov	eax,CBT_STATE
	LIB	GetTagData,[ebp+_UteBase]
	Mov	[edi+CB_State],eax

	Mov dword	[edi+CD_MinWidth],10
	Mov dword	[edi+CD_MaxWidth],10
	Mov dword	[edi+CD_MinHeight],10
	Mov dword	[edi+CD_MaxHeight],10
	Mov	eax,edi
	Ret
