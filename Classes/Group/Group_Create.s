;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Group_Create.s V1.0.0
;
;     Group.class V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassCreate	Push	ecx
	Mov	eax,GC_SIZE
	XOr	ebx,ebx
	LIB	AllocMem,[ebp+_SysBase]
	Push	eax
	INITLIST	[eax+CD_ObjectList]
	Pop	edi
	Pop	ebx

	Push dword	[ebp+_ClassID]
	Pop dword	[edi+CD_ClassID]

	Mov	eax,GCT_FLAGS
	LIB	GetTagData,[ebp+_UteBase]
	Mov	[edi+GC_Flags],eax
	Mov	eax,edi
	Ret
