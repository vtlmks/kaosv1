;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     GetStringWidth.s V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; GetStringWidth
;
; Inputs:
;
;  eax = Font pointer as returned by OpenFont()
;  ebx = Nullterminated string, 0-n characters allowed
;
; Output:
;
;  eax = Length in pixels of the string when rendered with the
;        the given font.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -


	Struc GetStringWidth
GSW_FontPtr	ResD	1	; Font struc pointer
GSW_StringPtr	ResD	1	; Null terminated string pointer to measure
GSW_SIZE	EndStruc


FONT_GetStrWidth	PushFD
	PushAD
	LINK	GSW_SIZE
	Mov	[ebp+GSW_FontPtr],eax
	Test	eax,eax
	Jz	.Done
	Mov	[ebp+GSW_StringPtr],ebx
	Test	ebx,ebx
	Jz	.Done
	;
	Call	GSW_GetSize

.Done	UNLINK	GSW_SIZE
	RETURN	eax
	PopAD
	PopFD
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
GSW_GetSize	Mov	eax,[ebp+GSW_FontPtr]
	Mov	eax,[eax+FS_FontType]
	Call	[.GetSizeTable+eax*4]
	Ret


	Align	4
.GetSizeTable	Dd	GSW_SizeAmiga
	Dd	GSW_SizeTTF



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
GSW_SizeAmiga	Mov	ebx,[ebp+GSW_FontPtr]
	Mov	edi,[ebx+FS_FontData]

	Mov	ecx,[edi+tf_CharLoc]
	XOr	edx,edx

	Mov	esi,[ebp+GSW_StringPtr]
.L	Lodsb
	Test	al,al
	Jz	.Done
	Sub	al,[edi+tf_LoChar]

	Movzx	ebx,word [ecx+2+eax*4]	; charwidth in pixels
	Add	edx,ebx
	Movzx	ebx,byte [edi+tf_Flags]
	Bt	ebx,TFB_PROPORTIONAL
	Jnc	.NonProp
	Inc	edx		; replace with spacing/kerning values later
.NonProp	Jmp	.L

.Done	Mov	eax,edx
	Ret





;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
GSW_SizeTTF	Mov	ebx,[ebp+GSW_FontPtr]
	Mov	edi,[ebx+FS_FontData]

	XOr	eax,eax
	Ret

