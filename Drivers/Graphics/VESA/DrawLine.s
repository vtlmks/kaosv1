;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Drawline.s V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; ecx - Taglist
;

	Struc DrawLine
DL_Packet	ResD	1	; Packet
DL_Window	ResD	1	; Window structure
DL_ScreenWidth	ResD	1	; Width Of Screen
DL_Dx	ResD	1	; Dx
DL_Dy	ResD	1	; Dy
DL_X0	ResD	1	; X0
DL_X1	ResD	1	; X1
DL_Y0	ResD	1	; Y0
DL_Y1	ResD	1	; Y1
DL_Color	ResD	1	; Color
DL_ABSDx	ResD	1	; Abs(Dx)
DL_ABSDy	ResD	1	; Abs(Dy)
DL_SDx	ResD	1	; Sgn(Dx)
DL_SDy	ResD	1	; Sgn(Dy)
DL_Addx	ResD	1	; ABSDx>>1
DL_Addy	ResD	1	; ABSDy>>1
DL_SIZE	EndStruc

VESA_DrawLine	PushFD
	PushAD
	LINK	DL_SIZE
	Mov	[ebp+DL_Packet],ecx

	Call	.DLFetchData
	Call	.DLCalcData

	Mov	eax,[ebp+DL_Window]
	Mov	ebx,[eax+WC_Screen]
	Mov	edi,[ebx+SC_Address]	; Address of screen we are to draw on...
	Add	edi,[ebp+DL_X0]		; X offset [for 8 bit, change later]
	Mov	eax,[ebp+DL_Y0]		; Y offset
	Mov	ebx,[ebx+SC_Width]	; Screenwidth
	Mov	[ebp+DL_ScreenWidth],ebx
	Mul	ebx
	Lea	edi,[edi+eax]

	;-
	Call	.DLDrawLine
	UNLINK	DL_SIZE
	PopAD
	PopFD
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.DLDrawLine	Cmp dword	[ebp+DL_Dy],0
	Je	.DLHorizontalLine
	Cmp dword	[ebp+DL_Dx],0
	Je	.DLVerticalLine

	Mov	ecx,[ebp+DL_Color]
	Mov byte	[edi],cl		; Has to draw the first pixel, unless straight lines.

	Mov	ecx,[ebp+DL_ABSDy]
	Cmp	[ebp+DL_ABSDx],ecx
	Jae	.DrawDx

	;- Init DrawDy
	Mov	eax,[ebp+DL_SDy]
	Mov	ebx,[ebp+DL_ScreenWidth]
	IMul	ebx
	Mov	ebx,[ebp+DL_ABSDx]
	Mov	edx,[ebp+DL_ABSDy]
	Mov	esi,eax
	Mov	eax,[ebp+DL_Addx]

	Mov	edx,[ebp+DL_Color]

.LoopY	Lea	eax,[eax+ebx]		; x+=dxabs
	Cmp	eax,edx		; if(x>dyabs)
	Jbe	.NoXAdd		;
	Sub	eax,[ebp+DL_ABSDy]	; x-=dyabs
	Add	edi,[ebp+DL_SDx]		; px+=sdx
.NoXAdd	Lea	edi,[edi+esi]		; py+=sdy
	Mov	[edi],dl		; color
	Dec	ecx
	Jnz	.LoopY
	Ret

	;- Init DrawDx
.DrawDx	Mov	ecx,[ebp+DL_ABSDx]
	Mov	eax,[ebp+DL_SDy]
	Mov	ebx,[ebp+DL_ScreenWidth]
	IMul	ebx
	Mov	ebx,[ebp+DL_ABSDx]
	Mov	edx,[ebp+DL_ABSDy]
	Mov	esi,eax
	Mov	eax,[ebp+DL_Addy]

	Mov	ebx,[ebp+DL_Color]

.LoopX	Lea	eax,[eax+edx]		; y+=dyabs
	Cmp	eax,ebx		; if(y>dxabs)
	jbe	.NoYAdd		;
	Sub	eax,[ebp+DL_ABSDx]	; y-=dxabs
	Lea	edi,[edi+esi]		; py+=sdy
.NoYAdd	Add	edi,[ebp+DL_SDx]		; px+=sdx
	Mov	[edi],bl		; color
	Dec	ecx
	Jnz	.LoopX
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.DLHorizontalLine	Mov	edx,[ebp+DL_ABSDx]
	Inc	edx
	Mov	ecx,[ebp+DL_Color]
.LoopH	Mov	[edi],cl		; color
	Add	edi,[ebp+DL_SDx]
	Dec	edx
	Jnz	.LoopH
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.DLVerticalLine	Mov	ebx,[ebp+DL_ScreenWidth]
	Mov	eax,[ebp+DL_SDy]
	IMul	ebx
	Mov	edx,[ebp+DL_ABSDy]
	Inc	edx
	Mov	esi,eax
	Mov	ecx,[ebp+DL_Color]	; color
.LoopV	Mov	[edi],cl
	Lea	edi,[edi+esi]
	Dec	edx
	Jnz	.LoopV
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.DLCalcData	Mov	eax,[ebp+DL_X1]
	Mov	ebx,[ebp+DL_Y1]
	Sub	eax,[ebp+DL_X0]
	Sub	ebx,[ebp+DL_Y0]
	;-
	Mov	[ebp+DL_Dx],eax
	Mov	[ebp+DL_Dy],ebx
	;-
	Mov	ecx,1
	Bt	eax,31
	Jnc	.PosX
	Sub	ecx,2
	Neg	eax
	;-
.PosX	Mov	edx,1
	Bt	ebx,31
	Jnc	.PosY
	Sub	edx,2
	Neg	ebx
	;-
.PosY	Mov	[ebp+DL_ABSDx],eax
	Mov	[ebp+DL_ABSDy],ebx
	;-
	Mov	[ebp+DL_SDx],ecx
	Mov	[ebp+DL_SDy],edx
	;-
	Shr	eax,1
	Shr	ebx,1
	Mov	[ebp+DL_Addx],ebx
	Mov	[ebp+DL_Addy],eax
	;
	;-- Get color
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.DLFetchData	Mov	esi,[ebp+DL_Packet]
	Mov	eax,[esi+LP_Window]
	Mov	ebx,[esi+LP_X0]
	Mov	ecx,[esi+LP_Y0]
	Mov	edx,[esi+LP_X1]
	Mov	edi,[esi+LP_Y1]
	Mov	[ebp+DL_Window],eax
	Mov	[ebp+DL_X0],ebx
	Mov	[ebp+DL_Y0],ecx
	Mov	[ebp+DL_X1],edx
	Mov	[ebp+DL_Y1],edi
	Mov	eax,[esi+LP_Color]
	Mov	[ebp+DL_Color],eax
	Ret
