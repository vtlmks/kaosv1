;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     RectFill.s V1.0.0
;

	Struc RectFillPacket
RFP_Color	ResD	1
RFP_Height	ResD	1
RFP_Width	ResD	1
RFP_TopEdge	ResD	1
RFP_LeftEdge	ResD	1
RFP_Window	ResD	1
RFP_SIZE	EndStruc


	Struc RectFillClipped
RFC_Color	ResD	1
RFC_EndY	ResD	1
RFC_EndX	ResD	1
RFC_StartY	ResD	1
RFC_StartX	ResD	1
RFC_Window	ResD	1
	;
RFC_GDEBase	ResD	1
RFC_OrgX1	ResD	1
RFC_OrgY1	ResD	1
RFC_OrgX2	ResD	1
RFC_OrgY2	ResD	1
RFC_SIZE	EndStruc



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
GFX_RectFill	Pop	eax
	Push	ebp
	Lea	ebp,[esp+4]
	PushFD
	PushAd
	;
	Mov	ebx,[ebp+RFP_Window]

	Mov	ecx,[ebx+CD_LeftEdge]
	Mov	edx,[ebx+CD_TopEdge]

	Add	[ebp+RFP_LeftEdge],ecx
	Add	[ebp+RFP_TopEdge],edx
	Mov	ecx,[ebp+RFP_LeftEdge]
	Mov	edx,[ebp+RFP_TopEdge]
	Add	[ebp+RFP_Width],ecx
	Add	[ebp+RFP_Height],edx
	;
	Mov	ecx,ebp
	Mov	edx,[ebx+WC_Screen]
	Mov	edx,[edx+SC_Driver]
	Mov	edx,[edx+GDE_Base]

	Cmp dword	[ebx+WC_ClipRegions],0
	Je	.NoClipping
	Call	GFX_RectFillClipped
	Jmp	.Done

.NoClipping	Call	[edx+GFXP_RectFill]
	;
.Done	PopAD
	PopFD
	Pop	ebp
	Lea	esp,[esp+RFP_SIZE]
	Push	eax
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
GFX_RectFillClipped PushAD
	Mov	eax,[ebp+RFP_Color]
	Mov	ebx,[ebp+RFP_Height]
	Mov	ecx,[ebp+RFP_Width]
	Mov	edx,[ebp+RFP_TopEdge]
	Mov	esi,[ebp+RFP_LeftEdge]
	Mov	edi,[ebp+RFP_Window]
	LINK	RFC_SIZE
	Mov	[ebp+RFC_Color],eax
	Mov	[ebp+RFC_OrgY2],ebx
	Mov	[ebp+RFC_OrgX2],ecx
	Mov	[ebp+RFC_OrgY1],edx
	Mov	[ebp+RFC_OrgX1],esi
	Mov	[ebp+RFC_Window],edi
	Mov	eax,[edi+WC_Screen]
	Mov	eax,[eax+SC_Driver]
	Mov	eax,[eax+GDE_Base]
	Mov	[ebp+RFC_GDEBase],eax
	;
	Mov	eax,[ebp+RFC_OrgX1]
	Mov	[ebp+RFC_StartX],eax
.Loop	Call	FindNextX
	Mov	[ebp+RFC_EndX],ebx
	Call	FillY
	Mov	eax,[ebp+RFC_EndX]	; if we are at the end, then exit...
	Inc	eax
	Cmp	eax,[ebp+RFC_OrgX2]
	Ja	.Done
	Mov	[ebp+RFC_StartX],eax
	Jmp	.Loop
	;
.Done	UNLINK	RFC_SIZE
	PopAD
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Find the first vertical(X) line which is inside the rect that we are drawing.
;
FindNextX	Mov	edi,[ebp+RFC_Window]
	Mov	edi,[edi+WC_ClipRegions]
	Mov	eax,[ebp+RFC_StartX]
	Mov	ebx,[ebp+RFC_OrgX2]
.L	Mov	ecx,[edi]
	Dec	ecx
	CMP2	eax,ebx,ecx,.NotX1
	Jmp	.Hit
.NotX1	Mov	ecx,[edi+8]
	CMP2	eax,ebx,ecx,.Outside
.Hit	Mov	ebx,ecx
.Outside	Lea	edi,[edi+16]
	Cmp dword	[edi],0
	Jne	.L
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Find and fill the gaps in vertical direction (Y)
;
FillY	Mov	eax,[ebp+RFC_OrgY1]
.Loop	Call	FindNextVisible
	Jc	.Done
	Mov	[ebp+RFC_StartY],eax
	Call	FindNextHidden
	Mov	eax,ecx
	Cmp	eax,[ebp+RFC_OrgY2]
	Je	.LastY
	Dec	ecx
.LastY	Mov	[ebp+RFC_EndY],ecx
	;
	PushAD
	Mov	ecx,ebp
	Mov	edx,[ebp+RFC_GDEBase]
	Call	[edx+GFXP_RectFill]
	PopAD
	;
	Cmp	eax,[ebp+RFC_OrgY2]
	Jne	.Loop
.Done	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
FindNextVisible	Clc
	Mov	ebx,[ebp+RFC_StartX]
.Redo	Mov	edi,[ebp+RFC_Window]
	Mov	edi,[edi+WC_ClipRegions]
.Loop	CMP2	[edi+4],[edi+12],eax,.NotInside
	CMP2	[edi],[edi+8],ebx,.NotInside
	Mov	eax,[edi+12]
	Inc	eax
	Cmp	eax,[ebp+RFC_OrgY2]
	Jbe	.Redo
	Stc
	Ret

.NotInside	Lea	edi,[edi+16]
	Cmp dword	[edi],0
	Jne	.Loop
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
FindNextHidden	Mov	ebx,[ebp+RFC_StartX]
	Mov	ecx,[ebp+RFC_OrgY2]
	Mov	edi,[ebp+RFC_Window]
	Mov	edi,[edi+WC_ClipRegions]
.Loop	CMP2	[edi],[edi+8],ebx,.NotInside
	CMP2	eax,ecx,[edi+4],.NotInside
	Mov	ecx,[edi+4]
.NotInside	Lea	edi,[edi+16]
	Cmp Dword	[edi],0
	Jne	.Loop
	Ret


