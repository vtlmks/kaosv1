;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     PutPixel.s V1.0.0
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Inputs on stack:
;  - Window
;  - X
;  - Y
;  - Color (32 bit)
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc PutPixelPacket
PPP_COLOR	ResD	1
PPP_Y	ResD	1
PPP_X	ResD	1
PPP_WINDOW	ResD	1
PPP_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
GFX_PutPixel	Pop	eax
	Push	ebp
	Lea	ebp,[esp+4]
	PushFD
	PushAD

	Mov	ecx,ebp
	Mov	ebx,[ebp+PPP_WINDOW]

	Mov	esi,[ebx+CD_LeftEdge]
	Mov	edi,[ebx+CD_TopEdge]
	Add	[ebp+PPP_X],esi
	Add	[ebp+PPP_Y],edi

	Mov	edx,[ebx+WC_Screen]
	Mov	edx,[edx+SC_Driver]
	Mov	edx,[edx+GDE_Base]
	Cmp dword	[ebx+WC_ClipRegions],0
	Je	.NoClipping

	Mov	edi,[ebx+WC_ClipRegions]
	Mov	eax,[ebp+PPP_X]
	Mov	ebx,[ebp+PPP_Y]
.Loop	CMP2	[edi],[edi+8],eax,.NotInside
	CMP2	[edi+4],[edi+12],ebx,.NotInside
	Jmp	.NotVisible

.NotInside	Lea	edi,[edi+16]
	Cmp dword	[edi],0
	Jne	.Loop

.NoClipping	Call	.PutPixel

.NotVisible	PopAD
	PopFD
	Pop	ebp
	Lea	esp,[esp+PPP_SIZE]
	Push	eax
	Ret



.PutPixel	Mov	edi,[ebp+PPP_WINDOW]
	Mov	esi,[edi+WC_Screen]
	Mov	eax,[esi+SC_Depth]
	Mov	esi,[esi+SC_Width]
	Call	[.DepthTable+eax*4]
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.DepthTable	Dd	.Dummy
	Dd	.PutPixel8	; 0
	Dd	.PutPixel16	; 1
	Dd	.Dummy
	Dd	.PutPixel32	; 3

.Dummy	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.PutPixel8	Mov	ecx,[ebp+PPP_COLOR]
	Mov	eax,ecx
	Mov	ebx,ecx
	Shr	ebx,8
	And	eax,0xff
	Shr	ecx,16
	And	ebx,0xff
	And	ecx,0xff
	Add	eax,ebx
	Add	eax,ecx
	Test	eax,eax
	Jz	.Black
	Mov	ebx,3
	XOr	edx,edx
	Div	ebx	; index in eax

.Black	Mov	edx,eax
	Mov	edi,[SysBase+SB_VESA+VESA_MEMPTR]
	Mov	eax,[ebp+PPP_Y]
	Mul	esi	; ResX
	Add	eax,[ebp+PPP_X]
;	Mov byte	[edi+eax],0xff
	Mov	dl,[ebp+PPP_COLOR]
	Mov	[edi+eax],dl
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.PutPixel16	Ret	; Pack R.8 G.8 B.8 -> 16 bit R.5 G.6 B.5

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.PutPixel32	Mov	edi,[SysBase+SB_VESA+VESA_MEMPTR]
	Mov	ebx,esi	; resx
	Mov	eax,[ebp+PPP_Y]
	Mul	ebx
	Shl	eax,2	; 4 bytes per pixel
	Add	eax,[ebp+PPP_X]
	Mov	ebx,[ebp+PPP_COLOR]
	Mov	[edi+eax],ebx	; add check with mask...
	Ret


