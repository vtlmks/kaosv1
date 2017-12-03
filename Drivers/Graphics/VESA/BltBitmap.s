;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     BltBitmap.s V1.0.0
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Inputs:
;
; ecx - Packet
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
VESA_BltBitmap	PushFD
	PushAD
	Cld
	Mov	ebp,ecx
	Mov	eax,[ebp+BBP_Window]
	Mov	eax,[eax+WC_Screen]
	Mov	eax,[eax+SC_Width]
	Sub	eax,[ebp+BBP_Width]		; modulo

	Push	eax
	Mov	eax,[ebp+BBP_Window]
	Mov	ebx,[eax+WC_Screen]
	Mov	edi,[ebx+SC_Address]	; Address of screen we are to draw on...
	Add	edi,[ebp+BBP_DestX]	; X offset [for 8 bit, change later]
	Mov	eax,[ebp+BBP_DestY]	; Y offset
	Mov	ebx,[ebx+SC_Width]		; Screenwidth
	Mul	ebx
	Lea	edi,[edi+eax]		; destination

	Mov	eax,[ebp+BBP_Window]
	Mov	ebx,[eax+WC_Screen]
	Mov	esi,[ebx+SC_Address]	; Address of screen we are to draw on...
	Add	esi,[ebp+BBP_SourceX]	; X offset [for 8 bit, change later]
	Mov	eax,[ebp+BBP_SourceY]	; Y offset
	Mov	ebx,[ebx+SC_Width]		; Screenwidth
	Mul	ebx
	Lea	esi,[edi+eax]		; destination

	Pop	eax
	;-

;BBP_Height	ResD	1
;BBP_Width	ResD	1
;BBP_DestY	ResD	1
;BBP_DestX	ResD	1
;BBP_SourceY	ResD	1
;BBP_SourceX	ResD	1
;BBP_Window	ResD	1


	; eax = modulo, pos or neg

	Mov	edx,[ebp+BBP_Height]

	Mov	ebp,[ebp+RFP_Width]
	Mov	ebx,ebp
	Shr	ebp,2
	And	ebx,3

.Loop	Mov	ecx,ebp
	Rep Movsd
	Mov	ecx,ebx
	Rep Movsb
	Add	edi,eax
	Dec	edx
	Jnz	.Loop


	PopAD
	PopFD
	Ret

