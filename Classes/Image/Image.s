;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Imageclass.s V1.0.0
;
;     Image.class V1.0.0
;
;


	%Include	"..\Includes\Macros.i"
	%Include	"..\Includes\TypeDef.I"
	%Include	"..\Includes\Taglist.i"
	%Include	"..\Includes\Lists.I"
	%Include	"..\Includes\Nodes.i"
	%Include	"..\Includes\Libraries.i"
	%Include	"..\Includes\Ports.I"
	%Include	"..\Includes\UserInterface\Classes.I"
	%Include	"..\Includes\UserInterface\Pens.I"
	%Include	"..\Includes\Classes\Window.I"
	%Include	"..\Includes\Classes\Image.I"
	%Include	"..\Includes\Exec\Memory.I"
	%Include	"..\Includes\LVO\Exec.I"
	%Include	"..\Includes\LVO\Userinterface.I"
	%Include	"..\Includes\LVO\Utility.I"
	%Include	"..\Includes\LVO\Graphics.I"
	%Include	"..\Includes\Graphics\Graphics.I"

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

	Lea	eax,[ClassTag]
	Ret

	Struc Image
_SysBase	ResD	1	; ExecBase
_UteBase	ResD	1	; UtilityBase
_GfxBase	ResD	1	; GraphicsBase
_UIBase	ResD	1	; UserinterfaceBase
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

ClassName	Db	"image.class",0
ClassIDString	Db	"image.class 1.0 (2001-12-05)",0

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

	Mov	eax,ebp
	LIB	RegisterClass,[ebp+_UIBase]
	Test	eax,eax
	Jz	.Fail
	Mov	[ebp+_ClassID],eax

	XOr	eax,eax
	Ret

.Fail	Mov	eax,-1
	Ret


UteN	Db	"utility.library",0
GfxN	Db	"graphics.library",0
UIN	Db	"userinterface.library",0

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
	%Include	"Image\Image_AddMember.S"
	%Include	"Image\Image_Create.s"
	%Include	"Image\Image_Event.S"
	%Include	"Image\Image_GetAttributes.S"
	%Include	"Image\Image_GetMetrics.S"
	%Include	"Image\Image_Layout.S"
	%Include	"Image\Image_Refresh.S"
	%Include	"Image\Image_RemMember.S"
	%Include	"Image\Image_Remove.S"
	%Include	"Image\Image_Render.S"
	%Include	"Image\Image_SetAttributes.S"
