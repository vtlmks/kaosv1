;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     ObtainPen.s V1.0.0
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Input
;  eax = Red(8Bit), Green(8Bit), Blue(8Bit) or SystemPen (bit 31 set..)
;  ebx = Window
;
; Output
;  eax = 8, 16 or 32 bit color ; depending on the screen depth
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
GFX_ObtainPen	PUSHX	ebx,ecx,edx
	PushFD
	Bt	eax,31
	Jc near	.GetSystemPen
	;
.ObtainPen	Mov	edx,ebx
	And	eax,0xffffff
	XOr	ebx,ebx
	Mov	ecx,eax
	And	ecx,0xff	; Blue in ecx 0:7
	Mov	bl,ah	; Green in ebx 0:7
	Shr	eax,16	; Red in eax 0:7
	Mov	edx,[edx+WC_Screen]
	Mov	edx,[edx+SC_Depth]
	Call	[.OPDepth+edx*4]
.Exit	PopFD
	POPX	ebx,ecx,edx
	Ret

.OPDepth	Dd	.Exit
	Dd	.OPConv8
	Dd	.OPConv16
	Dd	.Exit
	Dd	.Exit

;	16 - 5 6 5
.OPConv16	Shr	eax,3
	Shr	ebx,2
	Shr	ecx,3
	Shl	eax,5
	Or	eax,ebx
	Shl	eax,6
	Or	eax,ecx	; eax = 16 bit color...
	Ret


; OPConv8 balanced to standard gray conversion...
; R = 30%  ;  G = 59%  ;  B = 11%
;
.OPConv8	Push	ecx
	Push	ebx
	Mov	ebx,30
	Mul	ebx
	Mov	ecx,eax	; Red done

	Pop	eax
	Mov	ebx,59
	Mul	ebx
	Add	ecx,eax	; Green done

	Pop	eax
	Mov	ebx,11
	Mul	ebx
	Add	eax,ecx	; Blue done
	Test	eax,eax
	Jz	.Exit8

	XOr	edx,edx
	Mov	ebx,100
	Div	ebx	; Normalized
.Exit8	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.GetSystemPen	Cmp dword	[ebx+WC_Pens],0
	Je	.NoWindowPens
	Jmp near	.Exit

.NoWindowPens	Mov	edx,[ebx+WC_Screen]
	Mov	ecx,[edx+SC_Pens]

.L	Cmp	[ecx],eax
	Je	.FoundPen
	Lea	ecx,[ecx+8]
	Cmp dword	[ecx],-1
	Jne	.L
	Jmp near	.Exit

.FoundPen	Mov	eax,[ecx+4]
	Cmp dword	[edx+SC_Depth],1
	Je near	.Exit
	Mov	ecx,[edx+SC_Colors]
	Mov	eax,[ecx+eax*4]
	Jmp near	.Exit
