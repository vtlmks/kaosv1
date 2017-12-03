;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Image_Create.s V1.0.0
;
;     Image.class V1.0.0
;
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassCreate	Mov	eax,IM_SIZE
	XOr	ebx,ebx
	LIB	AllocMem,[ebp+_SysBase]
	Push	eax
	INITLIST	[eax+LN_SIZE]
	Pop	eax

	Push dword	[ebp+_ClassID]
	Pop dword	[eax+CD_ClassID]

	Mov dword	[eax+CD_MinWidth],10
	Mov dword	[eax+CD_MaxWidth],10
	Mov dword	[eax+CD_MinHeight],10
	Mov dword	[eax+CD_MaxHeight],10
	Ret
