;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Checkbox_Render.s V1.0.0
;
;     Checkbox.class V1.0.0
;
;

	Struc ClassRenderTagBuffer
CRB_TAGLIST	ResD	20	;Taglistspace
CRB_X	ResD	1
CRB_Y	ResD	1
CRB_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassRender	Mov	esi,eax

	Mov	eax,PEN_OBJECT_BACKGROUND
	Mov	ebx,[esi+CD_Root]
	LIB	ObtainPen,[ebp+_GfxBase]
	Push dword	[esi+CD_Root]
	Push dword	[esi+CD_LeftEdge]
	Push dword	[esi+CD_TopEdge]
	Push dword	[esi+CD_Width]
	Push dword	[esi+CD_Height]
	Push	eax
	LIB	RectFill,[ebp+_GfxBase]

	Lea	ecx,[BevelTags]
	Mov	ebx,[esi+CD_Root]
	Mov	[ecx+36],ebx
	Mov	eax,[esi+CD_LeftEdge]
	Mov	ebx,[esi+CD_TopEdge]
	Mov	[ecx+4],eax
	Mov	[ecx+12],ebx
	Add	eax,[esi+CD_Width]
	Add	ebx,[esi+CD_Height]
	Dec	eax
	Dec	ebx
	Mov	[ecx+20],eax
	Mov	[ecx+28],ebx
	LIB	DrawBevel,[ebp+_GfxBase]

	Cmp dword	[esi+CB_State],CBSTATE_CHECKED
	Je	.RenderChecked

	Ret


.RenderChecked	Lea	edi,[CheckBoxImage]

	Mov	eax,[esi+CD_TopEdge]
	Add	eax,2
	Mov dword	[ebp+CRB_Y],eax


.GetNext	Mov	eax,[esi+CD_LeftEdge]
	Inc	eax
	Mov dword	[ebp+CRB_X],eax
	Mov	ecx,7
.L	Movzx	eax,byte [edi]
	Push dword	[esi+CD_Root]
	Push dword	[ebp+CRB_X]
	Push dword	[ebp+CRB_Y]
	Push	eax
	LIB	PutPixel,[ebp+_GfxBase]
	Inc dword	[ebp+CRB_X]
	Inc	edi
	Dec	ecx
	Jnz	.L
	Inc dword	[ebp+CRB_Y]
	Cmp byte	[edi],-1
	Jne	.GetNext
	Ret


CheckBoxImage	Db	4,4,4,4,4,1,2
	Db	4,4,4,4,1,2,2
	Db	1,2,4,1,2,2,4
	Db	1,2,2,2,2,4,4
	Db	4,1,2,2,0,4,4
	Db	-1

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
BevelTags	Dd	DBT_X0,0
	Dd	DBT_Y0,0
	Dd	DBT_X1,0
	Dd	DBT_Y1,0
	Dd	DBT_WINDOW,0
	Dd	DBT_BRIGHTCOLOR,2
	Dd	DBT_DARKCOLOR,1
	Dd	DBT_FLAGS,0
	Dd	TAG_DONE
BevelTagsSize	Equ	(($-BevelTags)/4)+1
