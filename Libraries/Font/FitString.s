;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     FitString.s V1.0.0
;
;  Calculates the number of characters that fits into the given pixel boundary,
;  when rendered with the given font.
;
;  This function will safely return null if any of the parameters are null.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Inputs:
;
;  eax = Font
;  ebx = String
;  ecx = Width in pixels
;
; Output:
;
;  eax = -1, whole string fits..
;        if not -1, eax contains the number of characters that fits or null for none..
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -


	Struc FitString
FSTR_FontPtr	ResD	1	; Font structure pointer
FSTR_StringPtr	ResD	1	; Null terminated string pointer
FSTR_Width	ResD	1	; Width in pixel to fit string in
FSTR_NumChars	ResD	1	; Return value
FSTR_SIZE	EndStruc


FONT_FitString	PushFD
	PushAD
	LINK	FSTR_SIZE
	;
	Call	FSTR_FetchData
	Jc	.Done
	Call	FSTR_GetSize
	;
.Done	Mov	eax,[ebp+FSTR_NumChars]
	UNLINK	FSTR_SIZE
	RETURN	eax
	PopAD
	PopFD
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
FSTR_FetchData	Mov dword	[ebp+FSTR_NumChars],0
	Test	eax,eax
	Jz	.Failure
	Mov	[ebp+FSTR_FontPtr],eax
	Test	ebx,ebx
	Jz	.Failure
	Mov	[ebp+FSTR_StringPtr],ebx
	Test	ecx,ecx
	Jz	.Failure
	Mov	[ebp+FSTR_Width],ecx
	Clc
	Ret
	;
.Failure	Stc
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
FSTR_GetSize	Mov	eax,[ebp+FSTR_FontPtr]
	Mov	eax,[eax+FS_FontType]
	Call	[.FitStringTable+eax*4]
	Ret

	Align	4
.FitStringTable	Dd	FSTR_FitAmiga
	Dd	FSTR_FitTTF




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
FSTR_FitAmiga	Mov	ebx,[ebp+FSTR_FontPtr]
	Mov	edi,[ebx+FS_FontData]
	Mov	ecx,[edi+tf_CharLoc]
	XOr	edx,edx
	Mov	esi,[ebp+FSTR_StringPtr]
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
.NonProp	Cmp	[ebp+FSTR_Width],edx
	Jb	.NoMore		; if width<edx
	Inc dword	[ebp+FSTR_NumChars]
	Jmp	.L

.Done	Mov dword	[ebp+FSTR_NumChars],-1
.NoMore	Ret




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
FSTR_FitTTF	Mov	ebx,[ebp+FSTR_FontPtr]
	Mov	edi,[ebx+FS_FontData]

	Mov dword	[ebp+FSTR_NumChars],0
	Ret

