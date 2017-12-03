;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     OpenFont.s V1.0.0
;
;     Open a font..
;


%Macro	SWAPLONG	1
	Mov	eax,%1
	BSwap	eax
	Mov	%1,eax
%EndMacro

%Macro	SWAPWORD	1
	Mov	ax,word %1
	Xchg	ah,al
	Mov	%1,ax
%EndMacro

%Macro	PRINTTXT	1
	PushAD
	Mov	eax,%1
	Int	0xff
	PopAD
%EndMacro


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Input:
;
;  eax - Fontname
;
; Output:
;
;  eax - Pointer to fontstruct or null for failure
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
FONT_OpenFont	PushFD
	PushAD
	Mov	esi,eax
	Mov	ebp,edx

	Mov	eax,FS_SIZE
	XOr	ebx,ebx
	LIB	AllocMem,[ebp+_SysBase]
	Mov	edi,eax
	Test	eax,eax
	Jz	.Failure
	Mov byte	[edi+LN_TYPE],NT_FONT
	Mov	[edi+FS_FontName],esi
	;
;	Lea	eax,[SysBase+SB_FontList]
;	Mov	ebx,edi
;	ADDTAIL
	;
	; ADD: Check if font is already loaded ..
	;
	Call	ReadFont
	Jc	.Failure
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Lea	eax,[FontLoadTxt]
	Int	0xff
	Mov	eax,edi
	Int	0xfe
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	;
	Call	CheckFont

	;--
	RETURN	edi
	PopAD
	PopFD
	Ret

	;--
.Failure	RETURN	0
	PopAD
	PopFD
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
CheckFont	Mov	eax,[edi+FS_FontData]
	Cmp dword	[eax],0xf3030000
	Jne	.NoAmiga
	Mov dword	[edi+FS_FontType],FONTTYPE_AMIGA
	;--
	Lea	eax,[FontAmigaTxt]	; ** REMOVE
	Int	0xff		; ** REMOVE
	;--

.NoAmiga	Mov	eax,[edi+FS_FontType]
	Call	[FontTypeTable+eax*4]
	Ret




	%Include	"OpenFont_AmigaBitmap.I"
	%Include	"OpenFont_TrueType.I"


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ReadFont	Mov	eax,[edi+FS_FontName]
	Mov	ebx,OPENF_OLDFILE
	LIB	Open,[ebp+_DosBase]
	Test	eax,eax
	Jz	.Failure
	;
	Mov	[edi+FS_FontFH],eax
	XOr	ebx,ebx
	Mov	ecx,OFFSET_END
	LIB	Seek
	;
	Mov	eax,[edi+FS_FontFH]
	XOr	ebx,ebx
	Mov	ecx,OFFSET_BEGINNING
	LIB	Seek
	Test	eax,eax
	Jz	.Failure
	;
	Push	eax		; Save length
	XOr	ebx,ebx
	LIB	AllocMem,[ebp+_SysBase]
	Mov	[edi+FS_FontData],eax
	Mov	ecx,eax		; Buffer
	Mov	eax,[edi+FS_FontFH]	; FH
	Pop	ebx		; Length
	LIB	Read,[ebp+_DosBase]
	Mov	eax,[edi+FS_FontFH]
	LIB	Close
	Clc
	Ret
	;
.Failure	Stc
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
FontTypeTable	Dd	OpenAmigaBmp
	Dd	OpenTTF


FontLoadTxt	Db	0xa,"** Font loaded @ ",0
FontAmigaTxt	Db	0xa,"** Found Amiga bitmap font",0
