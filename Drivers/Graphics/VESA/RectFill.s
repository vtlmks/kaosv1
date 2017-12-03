;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     RectFill.s V1.0.0
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Inputs:
;
; ecx - Packet
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
VESA_RectFill	PushFD
	PushAD
	Cld
	Mov	ebp,ecx
	Mov	eax,[ebp+RFP_Window]
	Mov	eax,[eax+WC_Screen]
	Mov	esi,[eax+SC_Width]
	Add	esi,[ebp+RFP_LeftEdge]
	Sub	esi,[ebp+RFP_Width]
	Dec	esi

	Mov	eax,[ebp+RFP_Window]
	Mov	ebx,[eax+WC_Screen]
	Mov	edi,[ebx+SC_Address]	; Address of screen we are to draw on...
	Add	edi,[ebp+RFP_LeftEdge]	; X offset [for 8 bit, change later]
	Mov	eax,[ebp+RFP_TopEdge]	; Y offset
	Mov	ebx,[ebx+SC_Width]	; Screenwidth
	Mul	ebx
	Lea	edi,[edi+eax]
	;-
	Mov	eax,[ebp+RFP_Color]
	Shl	eax,8
	Or	eax,[ebp+RFP_Color]
	Shl	eax,8
	Or	eax,[ebp+RFP_Color]
	Shl	eax,8
	Or	eax,[ebp+RFP_Color]

	Mov	edx,[ebp+RFP_Height]
	Sub	edx,[ebp+RFP_TopEdge]
	Inc	edx
	;
	Mov	ebx,[ebp+RFP_Width]
	Sub	ebx,[ebp+RFP_LeftEdge]
	Inc	ebx

	Mov	ebp,ebx
	Shr	ebp,2
	And	ebx,3

.Loop	Mov	ecx,ebp
	Rep Stosd
	Mov	ecx,ebx
	Rep Stosb
	Add	edi,esi
	Dec	edx
	Jnz	.Loop
	PopAD
	PopFD
	Ret

