;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Clip.s V1.0.0
;
;     Clip.library V1.0.0
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
	%Include	"..\..\Includes\LVO\Dos.I"
	%Include	"..\..\Includes\LVO\Exec.I"
	%Include	"..\..\Includes\LVO\Graphics.I"
	%Include	"..\..\Includes\LVO\Utility.I"

	Struc ClipLibMemory
_SysBase	ResD	1
_DosBase	ResD	1
_GfxBase	ResD	1
_UteBase	ResD	1
_SIZE	EndStruc


ClipStart	Lea	eax,[ClipLibTag]
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

ClipVersion	Equ	1
ClipRevision	Equ	0

ClipLibTag	Dd	LT_FLAGS,0
	Dd	LT_VERSION,ClipVersion
	Dd	LT_REVISION,ClipRevision
	Dd	LT_TYPE,NT_LIBRARY
	Dd	LT_PRIORITY,0
	Dd	LT_NAME,ClipName
	Dd	LT_IDSTRING,ClipIDString
	Dd	LT_INIT,ClipInitTable
	Dd	TAG_DONE

ClipInitTable	Dd	_SIZE
	Dd	ClipBase
	Dd	ClipInit
	Dd	-1

ClipName	Db	"clip.library",0
ClipIDString	Db	"clip.library 1.0 (2001-09-01)",0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
ClipOpenCount	Dd	0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
OpenClipLib	Inc dword	[ClipOpenCount]
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
CloseClipLib	Cmp dword	[ClipOpenCount],0
	Je	.Done
	Dec dword	[ClipOpenCount]
.Done	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
ExpungeClipLib	Mov	eax,-1
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
NullClipLib	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
ClipInit	Mov	ebp,edx		; LibBase
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
ClipBase	Dd	OpenClipLib		; 0
	Dd	CloseClipLib		; 4
	Dd	ExpungeClipLib		; 8
	Dd	NullClipLib		; 12
	Dd	NullClipLib		; 16
	Dd	NullClipLib		; 20
	;
	Dd	CLIP_ClipLine		; 24
	Dd	CLIP_ClipPixel		; 28
	Dd	CLIP_ClipRect		; 32
	Dd	-1


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	%Include	"ClipLine.s"
	%Include	"ClipPixel.s"
	%Include	"ClipRect.s"


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -


