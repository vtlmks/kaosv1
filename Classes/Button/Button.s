;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Buttonclass.s V1.0.0
;
;     Button.class V1.0.0
;
;


	%Include	"..\includes\macros.i"
	%Include	"..\Includes\TypeDef.I"
	%Include	"..\includes\taglist.i"
	%Include	"..\includes\Lists.I"
	%Include	"..\includes\nodes.i"
	%Include	"..\includes\libraries.i"
	%Include	"..\includes\Ports.I"
	%Include	"..\Includes\Libraries\Font.I"
	%Include	"..\Includes\UserInterface\Classes.I"
	%Include	"..\Includes\UserInterface\Pens.I"
	%Include	"..\includes\Classes\Button.I"
	%Include	"..\includes\Classes\Window.I"
	%Include	"..\includes\Exec\Memory.I"
	%Include	"..\includes\LVO\Exec.I"
	%Include	"..\includes\LVO\Font.I"
	%Include	"..\includes\LVO\Userinterface.I"
	%Include	"..\includes\LVO\Utility.I"
	%Include	"..\includes\LVO\graphics.I"
	%Include	"..\includes\graphics\graphics.I"

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

	Lea	eax,[ClassTag]
	Ret

	Struc Button
_SysBase	ResD	1	; ExecBase
_UteBase	ResD	1	; UtilityBase
_GfxBase	ResD	1	; GraphicsBase
_UIBase	ResD	1	; UserinterfaceBase
_FontBase	ResD	1	; FontBase
_Font	ResD	1	; Pointer to Font data...
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

ClassName	Db	"button.class",0
ClassIDString	Db	"button.class 1.0 (2000-10-20)",0

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

	Lea	eax,[GfxN]
	XOr	ebx,ebx
	LIB	OpenLibrary
	Test	eax,eax
	Jz	.Fail
	Mov	[ebp+_GfxBase],eax

	Lea	eax,[UIN]
	XOr	ebx,ebx
	LIB	OpenLibrary
	Test	eax,eax
	Jz	.Fail
	Mov	[ebp+_UIBase],eax

	Lea	eax,[FntN]
	XOr	ebx,ebx
	LIB	OpenLibrary
	Test	eax,eax
	Jz	.Fail
	Mov	[ebp+_FontBase],eax

	Mov	eax,ebp
	LIB	RegisterClass,[ebp+_UIBase]
	Test	eax,eax
	Jz	.Fail
	Mov	[ebp+_ClassID],eax


	Lea	eax,[FontN]
	LIB	OpenFont,[ebp+_FontBase]
	Mov	[ebp+_Font],eax

	XOr	eax,eax
	Ret

.Fail	Mov	eax,-1
	Ret


UteN	Db	"utility.library",0
FntN	Db	"font.library",0
GfxN	Db	"graphics.library",0
UIN	Db	"userinterface.library",0
FontN	Db	"xen.font",0

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

	%Include	"Button\Button_AddMember.S"
	%Include	"Button\Button_Create.s"
	%Include	"Button\Button_Event.S"
	%Include	"Button\Button_GetAttributes.S"
	%Include	"Button\Button_GetMetrics.S"
	%Include	"Button\Button_Layout.S"
	%Include	"Button\Button_Refresh.S"
	%Include	"Button\Button_RemMember.S"
	%Include	"Button\Button_Remove.S"
	%Include	"Button\Button_Render.S"
	%Include	"Button\Button_SetAttributes.S"

