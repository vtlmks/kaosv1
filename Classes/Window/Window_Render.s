;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Window_Render.s V1.0.0
;
;     Window.class V1.0.0
;
;

	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassRender	PushAd

	Mov	esi,eax

	Push	esi
	Push dword	0x0
	Push dword	0x0
	Push dword	[esi+CD_Width]
	Push dword	[esi+CD_Height]
	Push dword	0x3
	LIB	RectFill,[ebp+wp_GfxBase]	; Render window background.
	;
	Push	esi
	Push dword	0x0
	Push dword	0x0
	Push dword	[esi+CD_Width]
	Push dword	0x10
	Push dword	0x5
	LIB	RectFill,[ebp+wp_GfxBase]	; Render Titlebar
	;----
	Lea	eax,[BevelTags]
	LIB	CloneTaglist,[ebp+wp_UteBase]
	Mov	ecx,eax
	Mov	eax,[esi+CD_Width]
	Mov	ebx,[esi+CD_Height]
	Mov	[ecx+20],eax
	Mov	[ecx+28],ebx
	Mov	[ecx+36],esi		; Poke window
	LIB	DrawBevel,[ebp+wp_GfxBase]	; Draw Bevel around window
	;--
	Inc dword	[ecx+4]
	Inc dword	[ecx+12]
	Sub dword	[ecx+20],0x2
	Mov dword	[ecx+28],0xf
	Or dword	[ecx+60],DBF_RECESSED
	LIB	DrawBevel		; Draw Recessed Bevel around Titlebar
	;--
	Mov	eax,[esi+CD_Width]
	Mov	ebx,[esi+CD_Height]
	Sub	eax,0x12
	Sub	ebx,2
	Mov	[ecx+20],eax
	Mov	[ecx+28],ebx
	Mov dword	[ecx+4],0x42
	Sub	ebx,0xc
	Mov	[ecx+12],ebx
	LIB	DrawBevel		; Draw Recessed bevel in statusfield
	;--
	Mov	eax,0x40
	Mov	[ecx+20],eax
	Mov dword	[ecx+4],0x2
	LIB	DrawBevel		; Draw Recessed bevel 2 in statusfield
	;--
	Mov	eax,ecx
	LIB	FreeTaglist,[ebp+wp_UteBase]

.EXITA	PopAD

	Lea	eax,[eax+CD_ObjectList]
	SUCC	eax
	Mov	ebx,CM_RENDER
	LIB	DoMethod,[ebp+wp_UIBase]
	Ret

BevelTags	Dd	DBT_X0,0
	Dd	DBT_Y0,0
	Dd	DBT_X1,0
	Dd	DBT_Y1,0
	Dd	DBT_WINDOW,0
	Dd	DBT_BRIGHTCOLOR,2
	Dd	DBT_DARKCOLOR,1
	Dd	DBT_FLAGS,0
	Dd	TAG_DONE

