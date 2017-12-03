;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     RenderFont.s V1.0.0
;
;

	Struc RenderFont
RF_FontPtr	ResD	1	; Pointer to font as returned by OpenFont()
RF_Window	ResD	1	; Window to render font in
RF_X	ResD	1	; Render position X
RF_Y	ResD	1	; Render position Y
RF_Flags	ResD	1	; Flags, attributes etc., definitions below
RF_String	ResD	1	; Pointer to nullterminated string to output
RF_Size	ResD	1	; Size in pixels
RF_Color	ResD	1	; Color
RF_TaglistPtr	ResD	1	; Taglist ptr
RF_CharBuffer	ResD	1	; Temporary Render Buffer.... One char.
RF_UteBase	ResD	1	; Utility.library base
RF_GfxBase	ResD	1	; Graphics.library base
RF_FitWidth	ResD	1
	;
RF_YSize	ResD	1	; Temp ysize
RF_Modulo	ResD	1	; Temp modulo
RF_Index	ResD	1	; Temp x index

RF_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; RenderFont:
;
; Input:
;  ecx = Taglist
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
FONT_RenderFont	PushAD
	PushFD
	LINK	RF_SIZE
	Mov	[ebp+RF_TaglistPtr],ecx
	Mov	eax,[edx+_UteBase]
	Mov	ebx,[edx+_GfxBase]
	Mov	[ebp+RF_UteBase],eax
	Mov	[ebp+RF_GfxBase],ebx
	Mov dword	[ebp+RF_Index],0
	;
	Call	RF_FetchTags
	Jc	.Failure

	Call	RF_Init

.NoMore	UNLINK	RF_SIZE
	PopFD
	PopAD
	Ret

.Failure	UNLINK	RF_SIZE
	PopFD
	PopAD
	Mov	eax,0
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
RF_Init	Cmp dword	[ebp+RF_FitWidth],0
	Jne	.RenderFit
	Mov	esi,[ebp+RF_String]
	XOr	edx,edx
.L	Lodsb
	Test	al,al
	Jz	.NoMore
	Mov	dl,al
	Pushad
	Call	RF_Render
	Popad
	Jmp	.L

	;--

.RenderFit	Mov	eax,[ebp+RF_FontPtr]
	Mov	ebx,[ebp+RF_String]
	Mov	ecx,[ebp+RF_FitWidth]
	Call	FONT_FitString
	Test	eax,eax
	Jz	.NoMore
	Mov	ecx,eax
	Mov	esi,[ebp+RF_String]
.L1	Lodsb
	Test	al,al
	Jz	.NoMore
	Mov	dl,al
	Pushad
	Call	RF_Render
	Popad
	Dec	ecx
	Jnz	.L1
.NoMore	Ret





;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
RF_Render	Mov	eax,[ebp+RF_FontPtr]
	Mov	eax,[eax+FS_FontType]
	Call	[RenderTable+eax*4]
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
RF_RenderAmiga	Cld
	Mov	ebx,[ebp+RF_FontPtr]
	Mov	edi,[ebx+FS_CharBuffer]
	Mov	[ebp+RF_CharBuffer],edi
	Mov	ebx,[ebx+FS_FontData]

	Mov	ecx,[ebx+tf_CharLoc]
	Sub	dl,[ebx+tf_LoChar]

	Call	RF_CopyRows
	Movzx	ecx,word [ecx+2+edx*4]

	; Spec rutin, ta bort mig sa djevla snabbt som m0jligt

	Mov	edi,ecx
	Movzx	eax,word [ebx+tf_YSize]
	Mov	ecx,[ebp+RF_Y]
	Mov	edx,-1
	Mov	esi,[ebp+RF_CharBuffer]
	Mov	ebx,[ebp+RF_X]
	Add dword	ebx,[ebp+RF_Index]
.Loopot2	Push	edi
	Push	ebx
.Loopot	Cmp dword	[esi],0
	Je	.NoPlutt

	Push	eax
	;
	Push dword	[ebp+RF_Window]
	Push	ebx
	Push	ecx
	Push dword	2
	LIB	PutPixel,[ebp+RF_GfxBase]
	Pop	eax

.NoPlutt	Lea	esi,[esi+4]
	Inc	ebx
	Dec	edi
	Jnz	.Loopot
	Pop	ebx
	Pop	edi
	Inc	ecx
	Dec	eax
	Jnz	.Loopot2
	Add	[ebp+RF_Index],edi
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
RF_CopyBitRow	PUSHX	eax,ebx,ecx,edx,esi,ebp
.L1	Movzx	ax,byte [esi]
.L	Cmp	edx,-1
	Je	.Mo
	Bt	ax,dx
	Jnc	.NoBit
	Mov dword	[edi],-1
	Jmp	.Bit
.NoBit	Mov dword	[edi],0
.Bit	Lea	edi,[edi+4]
	Dec	edx
	Dec	ecx
	Jnz	.L
	Jmp	.Done
.Mo	Mov	edx,7
	Inc	esi
	Jmp	.L1
.Done	POPX	eax,ebx,ecx,edx,esi,ebp
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
RF_CopyRows	PushAD
	Movzx	eax,word [ecx+edx*4]	; pixel offset to char
	Movzx	ecx,word [ecx+2+edx*4]	; charwidth in pixels
	Mov	edx,eax
	And	edx,7

	Shr	eax,3
	Mov	esi,[ebx+tf_CharData]
	Add	esi,eax		; add byte offset
	Mov	edi,[ebp+RF_CharBuffer]

	Movzx	eax,word [ebx+tf_YSize]
	Mov	[ebp+RF_YSize],eax
	Movzx	eax,word [ebx+tf_Modulo]
	Mov	[ebp+RF_Modulo],eax

	Test	eax,eax
	Jnz	.NoNullCharacter
	Lea	esi,[NullCharacter]
	Mov	ecx,3	; 3 pixels
	XOr	edx,edx
	Jmp	.NullCharacter

	; ebx = y width	ecx = x width
	; edx = bitoffset	esi = source
	; edi = dest
.NoNullCharacter	Mov	eax,7
	Sub	eax,edx
	Mov	edx,eax
.NullCharacter	Mov	ebx,[ebp+RF_YSize]
.L	Call	RF_CopyBitRow
	Add	esi,[ebp+RF_Modulo]
	Dec	ebx
	Jnz	.L
	PopAD
	Ret



NullCharacter	Times 64 Dd 0



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
RF_RenderTTF	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
RF_FetchTags	Cld
	Lea	esi,[RFTagTable]
	Mov	edx,[ebp+RF_UteBase]
.L	Lodsd
	Test	eax,eax
	Jz	.Done
	Mov	ebx,[ebp+RF_TaglistPtr]
	LIB	GetTagData
	Mov	ebx,eax
	Lodsd
	Mov	[ebp+eax],ebx
	Lodsd
	Test	eax,eax
	Jz	.L
	Test	ebx,ebx
	Jnz	.L
.Failure	Stc
	Ret
	;
.Done	Clc
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
RenderTable	Dd	RF_RenderAmiga
	Dd	RF_RenderTTF

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	;	Tag, Destination, Checkfornull (set to true)
RFTagTable	Dd	RTF_FONT,RF_FontPtr,TRUE
	Dd	RTF_TEXT,RF_String,TRUE
	Dd	RTF_WINDOW,RF_Window,TRUE
	Dd	RTF_SIZE,RF_Size,TRUE
	Dd	RTF_X,RF_X,FALSE
	Dd	RTF_Y,RF_Y,FALSE
	Dd	RTF_COLOR,RF_Color,FALSE
	Dd	RTF_FLAGS,RF_Flags,FALSE
	Dd	RTF_FITWIDTH,RF_FitWidth,FALSE
	Dd	0

