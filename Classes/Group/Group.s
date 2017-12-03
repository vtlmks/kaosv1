;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Groupclass.s V1.0.0
;
;     Group.class V1.0.0
;

;
; TODO : Make sure that the group::GetMetrics count on columnar/rowed grouptype aswell when
;        calculating width/height...
;

	%Include	"..\includes\taglist.i"
	%Include	"..\Includes\TypeDef.I"
	%Include	"..\includes\Lists.I"
	%Include	"..\includes\nodes.i"
	%Include	"..\includes\macros.i"
	%Include	"..\includes\libraries.i"
	%Include	"..\Includes\UserInterface\Classes.I"
	%Include	"..\Includes\UserInterface\Pens.I"
	%Include	"..\includes\Classes\Group.I"
	%Include	"..\includes\LVO\Exec.I"
	%Include	"..\includes\LVO\Utility.I"
	%Include	"..\includes\LVO\graphics.I"
	%Include	"..\includes\LVO\UserInterface.I"
	%Include	"..\includes\Exec\Memory.I"
	%Include	"..\includes\graphics\graphics.I"

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

	Lea	eax,[ClassTag]
	Ret

	Struc Button
_SysBase	ResD	1	; ExecBase
_UteBase	ResD	1	; UtilityBase
_GfxBase	ResD	1	; GraphicsBase
_UIBase	ResD	1	; UserInterfaceBase
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

ClassName	Db	"group.class",0
ClassIDString	Db	"group.class 1.0 (2001-03-25)",0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
ClassOpenCount	Dd	0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
ClassInit	Mov	ebp,edx		; LibBase
	Mov	[ebp+_SysBase],ecx
	;
	Lea	eax,[UteN]		; for taglist exploration etc.
	XOr	ebx,ebx
	LIB	OpenLibrary,[ebp+_SysBase]
	Test	eax,eax
	Jz	.Fail
	Mov	[ebp+_UteBase],eax
	;
	Lea	eax,[GfxN]		; for rendering...
	XOr	ebx,ebx
	LIB	OpenLibrary,[ebp+_SysBase]
	Test	eax,eax
	Jz	.Fail
	Mov	[ebp+_GfxBase],eax
	;
	Lea	eax,[UIN]		; for rendering...
	XOr	ebx,ebx
	LIB	OpenLibrary,[ebp+_SysBase]
	Test	eax,eax
	Jz	.Fail
	Mov	[ebp+_UIBase],eax
	;
	Mov	eax,ebp
	LIB	RegisterClass,[ebp+_UIBase]
	Test	eax,eax
	Jz	.Fail
	Mov	[ebp+_ClassID],eax
	;
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

.ExtendedMethod	RETURN	0
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

	%Include	"Group\Group_AddMember.S"
	%Include	"Group\Group_Create.S"
	%Include	"Group\Group_Event.S"
	%Include	"Group\Group_GetAttributes.S"
	%Include	"Group\Group_GetMetrics.S"
	%Include	"Group\Group_Layout.S"
	%Include	"Group\Group_Refresh.S"
	%Include	"Group\Group_RemMember.S"
	%Include	"Group\Group_Remove.S"
	%Include	"Group\Group_Render.S"
	%Include	"Group\Group_SetAttributes.S"

