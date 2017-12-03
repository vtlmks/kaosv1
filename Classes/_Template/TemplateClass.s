;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Templateclass.s V1.0.0
;
;     Template.class V1.0.0
;
;

	%Include	"z:\includes\taglist.i"
	%Include	"z:\Includes\TypeDef.I"
	%Include	"z:\includes\Lists.I"
	%Include	"z:\includes\nodes.i"
	%Include	"z:\includes\macros.i"
	%Include	"z:\includes\libraries.i"
	%Include	"z:\Includes\UserInterface\Classes.I"
	%Include	"z:\includes\LVO\Exec.I"
	%Include	"z:\includes\LVO\Utility.I"
	%Include	"z:\includes\Exec\Memory.I"
	%Include	"z:\includes\graphics\graphics.I"
	%Include	"z:\includes\lvo\graphics.I"
	%Include	"z:\includes\LVO\Userinterface.I"
	;----
	%Include	"z:\includes\Classes\Template.I"	; change this

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

	Lea	eax,[ClassTag]
	Ret

	Struc Button
_SysBase	ResD	1	; ExecBase
_UteBase	ResD	1	; UtilityBase
_GfxBase	ResD	1	; GraphicsBase

_UIBase	ResD	1	; Userinterfacebase
_ClassID	ResD	1	; ClassID
_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

ClassVersion	Equ	1
ClassRevision	Equ	0

ClassTag	Dd	LT_FLAGS,0
	Dd	LT_VERSION,ClassVersion
	Dd	LT_REVISION,ClassRevision
	Dd	LT_TYPE,NT_LIBRARY
	Dd	LT_PRIORITY,0
	Dd	LT_NAME,ClassName
	Dd	LT_IDSTRING,ClassIDString
	Dd	LT_INIT,ClassInitTable
	Dd	TAG_DONE

ClassInitTable	Dd	_SIZE
	Dd	ClassBase
	Dd	ClassInit
	Dd	-1

ClassName	Db	"template.class",0
ClassIDString	Db	"template.class 1.0 (2000-10-30)",0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
ClassOpenCount	Dd	0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
ClassInit	Mov	ebp,edx		; LibBase
	Mov	[ebp+_SysBase],ecx
	;
	Lea	eax,[UteN]
	XOr	ebx,ebx
	LIB	OpenLibrary,[ebp+_SysBase]
	Test	eax,eax
	Jz	.Fail
	Mov	[ebp+_UteBase],eax
	;-
	Lea	eax,[GfxN]
	XOr	ebx,ebx
	LIB	OpenLibrary,[ebp+_SysBase]
	Test	eax,eax
	Jz	.Fail
	Mov	[ebp+_GfxBase],eax
	;-
	Lea	eax,[UIN]
	XOr	ebx,ebx
	LIB	OpenLibrary,[ebp+_SysBase]
	Test	eax,eax
	Jz	.Fail
	Mov	[ebp+_UIBase],eax
	;-
	Mov	eax,ebp
	LIB	RegisterClass,[ebp+_UIBase]
	Test	eax,eax
	Jz	.Fail
	Mov	[ebp+_ClassID],eax
	;-
	XOr	eax,eax
	Ret

.Fail	Mov	eax,-1
	Ret

UteN	Db	"utility.library",0
GfxN	Db	"graphics.library",0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
ClassOpen	Inc dword	[ClassOpenCount]
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
ClassClose	Cmp dword	[ClassOpenCount],0
	Je	.Done
	Dec dword	[ClassOpenCount]
.Done	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
ClassExpunge	Mov	eax,-1
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassNull	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassBase	Dd	ClassOpen		; 0
	Dd	ClassClose		; 4
	Dd	ClassExpunge		; 8
	Dd	ClassNull		; 12
	Dd	ClassNull		; 16
	Dd	ClassNull		; 20
	;
	Dd	ClassMethod		; 24
	Dd	-1

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Inputs (from exec.library/DoMethod()
;
; ebx - MethodID
; ecx - Taglist (or data)
; edx - libbase

ClassMethod	PushFD
	PushAD
	Cmp	ebx,CM_EXTBASE
	Jge	.ExtendedMethod
	Mov	ebp,edx
	Call	[ClassMethodList+ebx*4]
	RETURN	eax
	PopAD
	PopFD
	Ret

.ExtendedMethod	RETURN	0			; No extended methods for this class
	PopAD
	PopFD
	Ret

ClassMethodList	Dd	ClassCreate
	Dd	ClassRemove
	Dd	ClassGetAttributes
	Dd	ClassSetAttributes
	Dd	ClassAddMember
	Dd	ClassRemMember
	Dd	ClassRefresh
	Dd	ClassRender
	Dd	ClassLayout
	Dd	ClassGetMetrics
	Dd	ClassEvent

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassCreate	Mov	eax,BC_SIZE
	XOr	ebx,ebx
	LIB	AllocMem,[ebp+_SysBase]
	Push	eax
	INITLIST	[eax+LN_SIZE]
	Pop	eax

	Push dword	[ebp+_ClassID]
	Pop dword	[eax+CD_ClassID]

	Mov dword	[eax+CD_MinWidth],10
	Mov dword	[eax+CD_MaxWidth],20
	Mov dword	[eax+CD_MinHeight],30
	Mov dword	[eax+CD_MaxHeight],40
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassRemove	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassGetAttributes
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassSetAttributes
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassAddMember	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassRemMember	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassRefresh	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassRender	ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassLayout	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassGetMetrics	Ret
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassEvent	Ret
