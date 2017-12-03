;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Window_Layout.s V1.0.0
;
;     Window.class V1.0.0
;
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassLayout	Mov	edi,eax
	Lea	esi,[eax+LN_SIZE]		; Get root group..
	SUCC	esi

	Mov	ebx,[edi+CD_Width]	; Check windowsize against min/max of
	Mov	ecx,[edi+CD_Height]	; the root group.

	Sub	ebx,0x6
	Sub	ecx,0x20

	Cmp	ebx,[esi+CD_MinWidth]
	Jae	.CheckMaxWidth
	Mov	ebx,[esi+CD_MinWidth]
.CheckMaxWidth	Cmp	ebx,[esi+CD_MaxWidth]
	Jbe	.CheckHeight
	Mov	ebx,[esi+CD_MaxWidth]
.CheckHeight	Cmp	ecx,[esi+CD_MinHeight]
	Jae	.CheckMaxHeight
	Mov	ecx,[esi+CD_MinHeight]
.CheckMaxHeight	Cmp	ecx,[esi+CD_MaxHeight]
	Jbe	.SetSize
	Mov	ecx,[esi+CD_MaxHeight]

.SetSize	Mov dword	[esi+CD_Width],ebx
	Mov dword	[esi+CD_Height],ecx
	Mov dword	[esi+CD_LeftEdge],0x3
	Mov dword	[esi+CD_TopEdge],0x10

	Mov	eax,esi
	Mov	ebx,CM_LAYOUT
	LIB	DoMethod,[ebp+wp_UIBase]

	Ret

