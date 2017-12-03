;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Font.s V1.0.0
;
;     Font.library V1.0.0
;

	%Include	"..\..\Includes\TypeDef.I"
	%Include	"..\..\Includes\Lists.I"
	%Include	"..\..\Includes\Macros.I"
	%Include	"..\..\Includes\Nodes.I"
	%Include	"..\..\Includes\Ports.I"
	%Include	"..\..\Includes\TagList.I"
	%Include	"..\..\Includes\Libraries.I"
	%Include	"..\..\Includes\Dos\Dos.I"
	%Include	"..\..\Includes\Exec\Memory.I"
	%Include	"..\..\Includes\Libraries\Font.I"
	%Include	"..\..\Includes\LVO\Dos.I"
	%Include	"..\..\Includes\LVO\Exec.I"
	%Include	"..\..\Includes\LVO\Graphics.I"
	%Include	"..\..\Includes\LVO\Utility.I"

	%Include	"..\..\Includes\TTF.I"


	Struc FontLibMemory
_SysBase	ResD	1
_DosBase	ResD	1
_GfxBase	ResD	1
_UteBase	ResD	1
_SIZE	EndStruc


FontStart	Lea	eax,[FontLibTag]
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

FontVersion	Equ	1
FontRevision	Equ	0

FontLibTag	Dd	LT_FLAGS,0
	Dd	LT_VERSION,FontVersion
	Dd	LT_REVISION,FontRevision
	Dd	LT_TYPE,NT_LIBRARY
	Dd	LT_PRIORITY,0
	Dd	LT_NAME,FontName
	Dd	LT_IDSTRING,FontIDString
	Dd	LT_INIT,FontInitTable
	Dd	TAG_DONE

FontInitTable	Dd	_SIZE
	Dd	FontBase
	Dd	FontInit
	Dd	-1

FontName	Db	"font.library",0
FontIDString	Db	"font.library 1.0 (2001-03-06)",0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
FontOpenCount	Dd	0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
OpenFontLib	Inc dword	[FontOpenCount]
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
CloseFontLib	Cmp dword	[FontOpenCount],0
	Je	.Done
	Dec dword	[FontOpenCount]
.Done	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
ExpungeFontLib	Mov	eax,-1
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
NullFontLib	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
FontInit	Mov	ebp,edx		; LibBase
	Mov	[ebp+_SysBase],ecx
	Mov	edx,ecx
	;
	Lea	eax,[UteN]
	XOr	ebx,ebx
	LIB	OpenLibrary
	Test	eax,eax
	Jz	.Fail
	Mov	[ebp+_UteBase],eax
	;
	Lea	eax,[GfxN]
	XOr	ebx,ebx
	LIB	OpenLibrary
	Test	eax,eax
	Jz	.Fail
	Mov	[ebp+_GfxBase],eax
	;
	Lea	eax,[DosN]
	XOr	ebx,ebx
	LIB	OpenLibrary
	Test	eax,eax
	Jz	.Fail
	Mov	[ebp+_DosBase],eax
	;
	XOr	eax,eax
	Ret

.Fail	Mov	eax,-1
	Ret

DosN	Db	"dos.library",0
GfxN	Db	"graphics.library",0
UteN	Db	"utility.library",0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
FontBase	Dd	OpenFontLib		; 0
	Dd	CloseFontLib		; 4
	Dd	ExpungeFontLib		; 8
	Dd	NullFontLib		; 12
	Dd	NullFontLib		; 16
	Dd	NullFontLib		; 20
	;
	Dd	FONT_OpenFont		; 24
	Dd	FONT_CloseFont		; 28
	Dd	FONT_RenderFont		; 34
	Dd	FONT_GetStrWidth		; 40
	Dd	FONT_FitString		; 46
	Dd	-1


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	%Include	"OpenFont.s"
	%Include	"CloseFont.s"
	%Include	"RenderFont.s"
	%Include	"GetStringWidth.s"
	%Include	"FitString.s"


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -


