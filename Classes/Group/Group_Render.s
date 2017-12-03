;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Group_Render.s V1.0.0
;
;     Group.class V1.0.0
;

	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Render the group class.. this should render itself, and then pass on the 'render'
; call down to the next level in the hierarchy.
;
ClassRender	Mov	edi,eax

	Mov	eax,PEN_OBJECT_BACKGROUND
	Mov	ebx,[edi+CD_Root]
	LIB	ObtainPen,[ebp+_GfxBase]

	Push dword	[edi+CD_Root]
	Push dword	[edi+CD_LeftEdge]
	Push dword	[edi+CD_TopEdge]
	Push dword	[edi+CD_Width]
	Push dword	[edi+CD_Height]
	Push	eax
	LIB	RectFill,[ebp+_GfxBase]

	Lea	esi,[edi+CD_ObjectList]
.Loop	NEXTNODE	esi,.Done
	Mov	eax,esi
	XOr	ecx,ecx
	Mov	ebx,CM_RENDER
	LIB	DoMethod,[ebp+_UIBase]
	Jmp	.Loop
	;
.Done	Ret
