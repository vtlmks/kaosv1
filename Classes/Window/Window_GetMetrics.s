;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Window_GetMetrics.s V1.0.0
;
;     Window.class V1.0.0
;
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassGetMetrics	Push	eax
	Lea	eax,[eax+LN_SIZE]
	SUCC	eax
	Push	eax
	Mov	ebx,CM_GETMETRICS
	LIB	DoMethod,[ebp+wp_UIBase]
	Pop	eax
	Pop	ebx

	Mov	ecx,[eax+CD_MaxWidth]
	Mov	edx,[eax+CD_MinWidth]
	Add	ecx,0x6
	Add	edx,0x6
	Mov	[ebx+CD_MaxWidth],ecx
	Mov	[ebx+CD_MinWidth],edx

	Mov	ecx,[eax+CD_MaxHeight]
	Mov	edx,[eax+CD_MinHeight]
	Add	ecx,0x20
	Add	edx,0x20
	Mov	[ebx+CD_MaxHeight],ecx
	Mov	[ebx+CD_MinHeight],edx

	Mov	ecx,[ebx+CD_Width]	; Make sure that the window cant be bigger than what the
	Mov	edx,[ebx+CD_Height]	; first group allows it to.
	Cmp	ecx,[ebx+CD_MaxWidth]
	Jbe	.NotToWide
	Mov	ecx,[ebx+CD_MaxWidth]
.NotToWide	Cmp	ecx,[ebx+CD_MinWidth]
	Jae	.NotToNarrow
	Mov	ecx,[ebx+CD_MinWidth]
.NotToNarrow	Cmp	edx,[ebx+CD_MaxHeight]
	Jbe	.NotToHigh
	Mov	edx,[ebx+CD_MaxHeight]
.NotToHigh	Cmp	edx,[ebx+CD_MinHeight]
	Jae	.NotToLow
	Mov	edx,[ebx+CD_MinHeight]
.NotToLow	Mov	[ebx+CD_Width],ecx
	Mov	[ebx+CD_Height],edx
	Ret
