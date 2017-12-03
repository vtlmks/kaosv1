;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Button_Render.s V1.0.0
;
;     Button.class V1.0.0
;
;

	Struc ClassRenderTagBuffer
CRB_TAGLIST	ResD	20	;Taglistspace
CRB_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassRender	Cmp	ecx,RENDER_NORMAL
	Je	.RenderReleased
	Cmp	ecx,RENDER_PRESSED
	Je near	.RenderPressed
	Cmp	ecx,RENDER_RELEASED
	Je	.RenderReleased
	Cmp	ecx,RENDER_OVER
	Je near	.RenderOver
	Ret

.RenderReleased	Mov	esi,eax

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


;	Push	esi
;	Mov	eax,esi
;	Lea	esi,[BevelTags]
;	Lea	edi,[epb+CRB_TAGLIST]
;	Mov	ecx,BevelTagsSize
;	Rep Movsd
;	Pop	esi
;	Lea	ecx,[ebp+CRB_TAGLIST]

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

;;	Ret
	; RENDER TEXT!




	;-- test
	Mov	eax,PEN_OBJECT_TEXT
	Mov	ebx,[esi+CD_Root]
	LIB	ObtainPen,[ebp+_GfxBase]
	Mov	ecx,eax
	Mov	eax,[esi+CD_TopEdge]
	Mov	ebx,[esi+CD_LeftEdge]
	Add	eax,2
	Add	ebx,3
	Push dword	TAG_DONE
	Push dword	String
	Push dword	RTF_TEXT
	Push	ecx
	Push dword	RTF_COLOR
	Push dword	8
	Push dword	RTF_SIZE
	Push	ebx
	Push dword	RTF_X
	Push	eax
	Push dword	RTF_Y
	Push dword	[esi+CD_Root]
	Push dword	RTF_WINDOW
	Push dword	[ebp+_Font]
	Push dword	RTF_FONT
	Mov	ecx,esp
	LIB	RenderFont,[ebp+_FontBase]
	Add	esp,60
	;-- test
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.RenderPressed	Mov	esi,eax

	Mov	eax,PEN_OBJECT_SELECT
	Mov	ebx,[esi+CD_Root]
	LIB	ObtainPen,[ebp+_GfxBase]
	Push dword	[esi+CD_Root]
	Push dword	[esi+CD_LeftEdge]
	Push dword	[esi+CD_TopEdge]
	Push dword	[esi+CD_Width]
	Push dword	[esi+CD_Height]
	Push	eax
	LIB	RectFill,[ebp+_GfxBase]

;	Lea	eax,[BevelTags]
;	LIB	CloneTaglist,[ebp+_UteBase]
;	Mov	ecx,eax
;	Mov	ebx,[esi+CD_Root]
;	Mov	[ecx+36],ebx
;	Mov	eax,[esi+CD_LeftEdge]
;	Mov	ebx,[esi+CD_TopEdge]
;	Mov	[ecx+4],eax
;	Mov	[ecx+12],ebx
;	Add	eax,[esi+CD_Width]
;	Add	ebx,[esi+CD_Height]
;	Dec	eax
;	Dec	ebx
;	Mov	[ecx+20],eax
;	Mov	[ecx+28],ebx
;	Bts dword	[ecx+60],DBB_RECESSED
;	LIB	DrawBevel,[ebp+_GfxBase]
;	;--
;	Mov	eax,ecx
;	LIB	FreeTaglist,[ebp+_UteBase]
	Ret

.RenderOver	Ret

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

FontTags	Dd	RTF_FONT,0		; 4
	Dd	RTF_WINDOW,0		; 12
	Dd	RTF_X,0		; 20
	Dd	RTF_Y,0		; 28
	Dd	RTF_TEXT,String
	Dd	RTF_SIZE,8
	Dd	RTF_COLOR,0xe0
	Dd	TAG_DONE

String	Db	'Button x',0
