;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     BltBitmap.s V1.0.0
;

;	BltBitmap
;
;	Push	Window
;	Push	sourcex
;	Push	sourcey
;	Push	destx
;	Push	desty
;	Push	Width
;	Push	Height
;	LIB	BltBitmap,GfxBase







	Struc BITBLITPACKET
BBP_Height	ResD	1
BBP_Width	ResD	1
BBP_DestY	ResD	1
BBP_DestX	ResD	1
BBP_SourceY	ResD	1
BBP_SourceX	ResD	1
BBP_Window	ResD	1
BBP_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
GFX_BltBitmap	Pop	eax
	Push	ebp
	Lea	ebp,[esp+4]
	PushFD
	PushAd
	;
	Mov	ebx,[ebp+BBP_Window]
	Mov	ecx,[ebx+CD_LeftEdge]
	Mov	edx,[ebx+CD_TopEdge]
	Add	[ebp+BBP_SourceX],ecx
	Add	[ebp+BBP_DestX],ecx
	Add	[ebp+BBP_SourceY],edx
	Add	[ebp+BBP_SourceY],edx
	;
	Mov	ecx,ebp
	Mov	ebx,[ebx+WC_Screen]
	Mov	ebx,[ebx+SC_Driver]
	Mov	edx,[ebx+GDE_Base]
	Call	[edx+GFXP_BltBitmap]
	;
	PopAD
	PopFD
	Pop	ebp
	Lea	esp,[esp+BBP_SIZE]
	Push	eax
	Ret
