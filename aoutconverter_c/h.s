
	%Include	"..\Includes\TypeDef.I"
	%Include	"..\Includes\Lists.I"
	%include	"..\Includes\Nodes.I"
	%include	"..\Includes\TagList.I"
	%include	"..\Includes\Libraries.I"
	%include	"..\Includes\Macros.I"
	%Include	"..\Includes\Ports.I"
	%include	"..\Includes\LVO\Exec.I"
	%include	"..\Includes\LVO\Font.I"
	%Include	"..\includes\LVO\graphics.i"
	%include	"..\Includes\LVO\UserInterface.I"
	%Include	"..\Includes\Libraries\Font.I"
	%include	"..\Includes\UserInterface\Classes.I"
	%Include	"..\Includes\Classes\Group.I"
	%Include	"..\Includes\Classes\Window.I"

	%Include	"..\Includes\Classes\checkbox.i"
	%Include	"..\Includes\Classes\ProgressBar.I"

	Bits	32
	Section	.text

PROGRESSBAR_ID	Equ	1001


	Struc	Fart
_ExecBase	ResD	1
_RootObject	ResD	1
_UIBase	ResD	1
_FontBase	ResD	1
_GfxBase	ResD	1
_Window	ResD	1
_PBarObject	ResD	1
_PBarCount	ResD	1	; Temp
_SIZE	EndStruc

Start	LINK	_SIZE
	Mov	[ebp+_ExecBase],eax

	Lea	eax,[UIN]	; name
	XOr	ebx,ebx	; version
	LIB	OpenLibrary,[ebp+_ExecBase]
	Mov	[ebp+_UIBase],eax

	Lea	eax,[GfxN]
	LIB	OpenLibrary
	Mov	[ebp+_GfxBase],eax

	Lea	eax,[FontLibN]
	LIB	OpenLibrary
	Mov	[ebp+_FontBase],eax

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	LIB	CreateMsgPort,[ebp+_ExecBase]
	Lea	ebx,[WindowTags]
	Mov	[ebx+12],eax

	Lea	ecx,[CreateTags]
	LIB	CreateObjectList,[ebp+_UIBase]
	Mov	[ebp+_RootObject],eax

	Mov	eax,[ebp+_RootObject]
	LIB	OpenWindow,[ebp+_UIBase]
	Mov	[ebp+_Window],eax

	Mov dword	[ebp+_PBarCount],0
;;;	Mov	eax,[ebp+_Window]
	Mov	eax,[ebp+_RootObject]
	Mov	ebx,PROGRESSBAR_ID
	LIB	FindObject,[ebp+_UIBase]
	Mov	[ebp+_PBarObject],eax
	;--
	Push	eax
	Lea	eax,[PbarObjTxt]
	Int	0xff
	Pop	eax
	Int	0xfe
	;--


.Main	LIB	Wait,[ebp+_ExecBase]
.L	LIB	GetMsg,[ebp+_ExecBase]
	Test	eax,eax
	Jz	.Main


;	;-----
;	PushAD
;	Cmp dword	[ebp+_PBarCount],100
;	Jne	.NotFull
;	Mov dword	[ebp+_PBarCount],-1
;.NotFull	Inc dword	[ebp+_PBarCount]
;	Mov	eax,[ebp+_PBarObject]
;	Mov	ebx,CM_SETATTRIBUTES
;	Push dword	TAG_DONE
;	Push dword	[ebp+_PBarCount]
;	Push dword	PBT_POSITION
;	Mov	ecx,esp
;	LIB	UserMethod,[ebp+_UIBase]
;	Add	esp,12
;	PopAD
;	;-----


	Mov	ecx,[eax+WM_Object]
	Mov	ebx,[eax+WME_Event]
	Bt	ebx,CREB_GADGET_UP
	Jnc	.NoGadgetUp

	PushAD
	Lea	eax,[GadgetUpTxt]
	Int	0xff
	Mov	eax,ecx
	Int	0xfe
	PopAd

.NoGadgetUp	Bt	ebx,CREB_GADGET_DOWN
	Jnc	.NoGadgetDown

	PushAD
	Lea	eax,[GadgetDownTxt]
	Int	0xff
	Mov	eax,ecx
	Int	0xfe
	PopAd

.NoGadgetDown	LIB	ReplyMsg,[ebp+_ExecBase]
	Jmp	.L

	UNLINK	_SIZE
	Ret

GadgetDownTxt	Db	"GADGET_DOWN event recieved from object 0x",0
GadgetUpTxt	Db	"GADGET_UP event recieved from object 0x",0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
CreateTags	Dd	COT_APPNAME,AppN
	Dd	COT_CONFIGNAME,ConfigN
	Dd	COT_OBJECTLIST,ObjectList
	Dd	TAG_DONE

ObjectList	Dd	CLASS_WINDOW,WindowTags
	Dd	 CLASS_GROUP,Group2Tags

	Dd	  CLASS_GROUP,GroupTags
	Dd	   CLASS_OBJECT,ButtonTags
	Dd	   CLASS_OBJECT,ButtonTags
	Dd	   CLASS_OBJECT,ButtonTags
	Dd	  CLASS_GROUPEND,0

	Dd	  CLASS_GROUP,GroupTags
	Dd	   CLASS_GROUP,Group2Tags
	Dd	    CLASS_OBJECT,ButtonTags
	Dd	    CLASS_OBJECT,ButtonTags
	Dd	    CLASS_OBJECT,ButtonTags
	Dd	   CLASS_GROUPEND,0

	Dd	   CLASS_GROUP,Group2Tags
	Dd	    CLASS_OBJECT,ButtonTags
	Dd	    CLASS_OBJECT,ButtonTags
	Dd	    CLASS_OBJECT,ButtonTags
	Dd	   CLASS_GROUPEND,0

	Dd	   CLASS_GROUP,Group2Tags
	Dd	    CLASS_OBJECT,LabelTags
	Dd	    CLASS_OBJECT,CheckboxTags
	Dd	   CLASS_GROUPEND,0

	Dd	   CLASS_GROUP,Group2Tags
	Dd	    CLASS_OBJECT,ProgressbarTags
	Dd	    CLASS_OBJECT,CheckboxTags
	Dd	   CLASS_GROUPEND,0

	Dd	   CLASS_GROUP,Group2Tags
	Dd	    CLASS_OBJECT,CheckboxTags
	Dd	    CLASS_OBJECT,Checkbox2Tags
	Dd	    CLASS_OBJECT,CheckboxTags
	Dd	    CLASS_OBJECT,Checkbox2Tags
	Dd	    CLASS_OBJECT,CheckboxTags
	Dd	    CLASS_OBJECT,Checkbox2Tags
	Dd	   CLASS_GROUPEND,0

	Dd	  CLASS_GROUPEND,0

	Dd	 CLASS_GROUPEND,0
	Dd	-1

WindowTags	Dd	CT_CLASSNAME,WindowClassN
	Dd	WCT_USERPORT,0
	Dd	WCT_LEFT,0x120
	Dd	WCT_TOP,0x120
	Dd	WCT_WIDTH,0x100
	Dd	WCT_HEIGHT,0x100
	Dd	WCT_FLAGS,0
	Dd	WCT_EVENTFLAGS,0
	Dd	TAG_DONE

GroupTags	Dd	CT_CLASSNAME,GroupClassN
	Dd	GCT_FLAGS,GCF_HORIZONTAL
	Dd	TAG_DONE

Group2Tags	Dd	CT_CLASSNAME,GroupClassN
	Dd	GCT_FLAGS,GCF_VERTICAL
	Dd	TAG_DONE

ButtonTags	Dd	CT_CLASSNAME,ButtonClassN
	Dd	TAG_DONE

LabelTags	Dd	CT_CLASSNAME,LabelClassN
	Dd	LBT_TEXT,LabelTextStr
	Dd	LBT_FONT,FontN
	Dd	LBT_FONTSIZE,8
	Dd	LBT_COLOR,0xff00ff
	Dd	TAG_DONE


CheckboxTags	Dd	CT_CLASSNAME,CheckboxClassN
	Dd	TAG_DONE

Checkbox2Tags	Dd	CT_CLASSNAME,CheckboxClassN
	Dd	CBT_STATE,CBSTATE_CHECKED
	Dd	TAG_DONE

SpacerTags	Dd	CT_CLASSNAME,SpacerClassN
	Dd	TAG_DONE

TTYTags	Dd	CT_CLASSNAME,TTYClassN
	Dd	TAG_DONE

ProgressbarTags	Dd	CT_CLASSNAME,ProgressbarClassN
	Dd	CT_OBJECTID,PROGRESSBAR_ID
	Dd	PBT_MINVALUE,0
	Dd	PBT_MAXVALUE,100
	Dd	PBT_POSITION,1
	Dd	PBT_HEIGHT,5
	Dd	PBT_WIDTH,100
	Dd	TAG_DONE


AppN	Db	"Appname..",0
ConfigN	Db	"Cfgname..",0
ButtonClassN	Db	"button.class",0
GroupClassN	Db	"group.class",0
SpacerClassN	Db	"spacer.class",0
TTYClassN	Db	"tty.class",0
WindowClassN	Db	"window.class",0
CheckboxClassN	Db	"checkbox.class",0
LabelClassN	Db	"label.class",0
ProgressbarClassN	Db	"progressbar.class",0

LabelTextStr	Db	"Press me!",0

PbarObjTxt	Db	0xa,"PBar object ptr = ",0

;FontN	Db	"big.font",0
FontN	Db	"xen.font",0
FontLibN	Db	"font.library",0
UIN	Db	"userinterface.library",0
GfxN	Db	"graphics.library",0
