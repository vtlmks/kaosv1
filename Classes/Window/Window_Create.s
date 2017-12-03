;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Window_Create.s V1.0.0
;
;     Window.class V1.0.0
;
;

	Struc TempWinMem
twm_Process	ResD	1	; Our mighty parent
twm_Taglist	ResD	1	; DoMethod() tags
twm_ReturnData	ResD	1	; Return rootobject to userside
twm_SysBase	ResD	1	;
twm_UteBase	ResD	1	;
twm_GfxBase	ResD	1	;
twm_UIBase	ResD	1	; UserInterfaceBase
twm_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassCreate	Mov	eax,twm_SIZE
	XOr	ebx,ebx
	LIB	AllocMem,[ebp+_SysBase]
	Mov	edi,eax
	Mov	[edi+twm_Taglist],ecx
	Mov	eax,[ebp+_SysBase]
	Mov	ebx,[ebp+_UteBase]
	Mov	ecx,[ebp+_GfxBase]
	Mov	edx,[ebp+_UIBase]
	Mov	[edi+twm_SysBase],eax
	Mov	[edi+twm_UteBase],ebx
	Mov	[edi+twm_GfxBase],ecx
	Mov	[edi+twm_UIBase],edx
	;
	XOr	eax,eax
	LIB	FindProcess,[ebp+_SysBase]
	Mov	[edi+twm_Process],eax

	Mov	[WindowProcTags+4],edi
	Lea	ecx,[WindowProcTags]
	LIB	AddProcess,[ebp+_SysBase]
	LIB	Sleep,[ebp+_SysBase]

	Push dword	[edi+twm_ReturnData]
	Mov	eax,edi
	LIB	FreeMem,[ebp+_SysBase]
	Pop	eax
	;-
	Push dword	[ebp+_ClassID]
	Pop dword	[eax+CD_ClassID]
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
WindowProcTags	Dd	AP_USERDATA,0
	Dd	AP_PROCESSPOINTER,WindowProc
	Dd	AP_PRIORITY,0
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,4000
	Dd	AP_RING,3
	Dd	AP_QUANTUM,1
	Dd	AP_NAME,WindowProcN
	Dd	TAG_DONE

WindowProcN	Db	"Userprocn.Window#x",0


	Struc WindowProcMemf
wp_Data	ResD	1	; Userdata at procstart
wp_WindowObject	ResD	1	; Window Object
wp_SysBase	ResD	1	; Exec.library
wp_UteBase	ResD	1	; Utility.library
wp_GfxBase	ResD	1	; Graphics.library
wp_UIBase	ResD	1	; UserInterface.library
wp_Message	ResD	1	; Incoming message, temp
wp_UserPort	ResD	1	; User message port
wp_ActiveObject	ResD	1	; Active Object
wp_OldMouse	ResD	1	; Old Mousebutton State
wp_Dummy	ResD	1	; Dummy, for any data
wp_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
WindowProc	LINK	wp_SIZE
	Mov	[ebp+wp_Data],edx
	Mov	eax,[edx+twm_SysBase]
	Mov	ebx,[edx+twm_UteBase]
	Mov	ecx,[edx+twm_GfxBase]
	Mov	edx,[edx+twm_UIBase]
	Mov	[ebp+wp_SysBase],eax
	Mov	[ebp+wp_UteBase],ebx
	Mov	[ebp+wp_GfxBase],ecx
	Mov	[ebp+wp_UIBase],edx

	Mov	eax,WC_SIZE
	XOr	ebx,ebx
	LIB	AllocMem,[ebp+wp_SysBase]
	Mov	esi,eax
	Mov	[ebp+wp_WindowObject],eax

	Push	eax
	INITLIST	[eax+LN_SIZE]
	Pop	eax

	Lea	ebx,[FakeDamageList]
	Mov	[eax+WC_ClipRegions],ebx

	Lea	eax,[WindowTaglist]
	Mov	ebx,[ebp+wp_WindowObject]
	Mov	ecx,[ebp+wp_Data]
	Mov	ecx,[ecx+twm_Taglist]
	LIB	FetchTags,[ebp+wp_UteBase]

	LIB	CreateMsgPort,[ebp+wp_SysBase]
	Mov	[esi+WC_WindowPort],eax

	Mov	eax,[ebp+wp_Data]
	Mov	[eax+twm_ReturnData],esi

	Mov	eax,[eax+twm_Process]
	LIB	Awake,[ebp+wp_SysBase]

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.Main	LIB	Wait,[ebp+wp_SysBase]
.L	LIB	GetMsg,[ebp+wp_SysBase]
	Test	eax,eax
	Jz	.Main
	Mov	[ebp+wp_Message],eax

	PushAD
	Mov	eax,[eax+WM_Command]
	Call	[WinMsgTypes+eax*4]
	PopAD

	Mov	eax,[ebp+wp_Message]
	LIB	ReplyMsg,[ebp+wp_SysBase]
	Jmp	.L

FakeDamageList	Dd	0x100,0x100,0x110,0x110
	Dd	0x100,0x120,0x110,0x130
	Dd	0x100,0x140,0x110,0x150
	Dd	0x100,0x160,0x110,0x170
	Dd	0x100,0x180,0x110,0x190

	Dd	0x110,0x110,0x120,0x120
	Dd	0x110,0x130,0x120,0x140
	Dd	0x110,0x150,0x120,0x160
	Dd	0x110,0x170,0x120,0x180

	Dd	0x120,0x100,0x130,0x110
	Dd	0x120,0x120,0x130,0x130
	Dd	0x120,0x140,0x130,0x150
	Dd	0x120,0x160,0x130,0x170
	Dd	0x120,0x180,0x130,0x190

	Dd	0x130,0x110,0x140,0x120
	Dd	0x130,0x130,0x140,0x140
	Dd	0x130,0x150,0x140,0x160
	Dd	0x130,0x170,0x140,0x180

	Dd	0x140,0x100,0x150,0x110
	Dd	0x140,0x120,0x150,0x130
	Dd	0x140,0x140,0x150,0x150
	Dd	0x140,0x160,0x150,0x170
	Dd	0x140,0x180,0x150,0x190

	Dd	0x150,0x110,0x160,0x120
	Dd	0x150,0x130,0x160,0x140
	Dd	0x150,0x150,0x160,0x160
	Dd	0x150,0x170,0x160,0x180

	Dd	0x160,0x100,0x170,0x110
	Dd	0x160,0x120,0x170,0x130
	Dd	0x160,0x140,0x170,0x150
	Dd	0x160,0x160,0x170,0x170
	Dd	0x160,0x180,0x170,0x190

	Dd	0x170,0x110,0x180,0x120
	Dd	0x170,0x130,0x180,0x140
	Dd	0x170,0x150,0x180,0x160
	Dd	0x170,0x170,0x180,0x180

	Dd	0x180,0x100,0x190,0x110
	Dd	0x180,0x120,0x190,0x130
	Dd	0x180,0x140,0x190,0x150
	Dd	0x180,0x160,0x190,0x170
	Dd	0x180,0x180,0x190,0x190

	Dd	0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
WinMsgTypes	Dd	WinIEvent
	Dd	WinClassMethod
	Dd	WinUserMethod
	Dd	WinInterClass

WindowTaglist	Dd	WCT_USERPORT,WC_UserPort,FALSE ; should be TRUE
	Dd	WCT_LEFT,CD_LeftEdge,TRUE
	Dd	WCT_TOP,CD_TopEdge,TRUE
	Dd	WCT_WIDTH,CD_Width,TRUE
	Dd	WCT_HEIGHT,CD_Height,TRUE
	Dd	TAG_DONE

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
WinIEvent	Mov	eax,[ebp+wp_Message]
	Mov	eax,[eax+WMIE_Type]
	Call	[.EventType+eax*4]
	Ret

.EventType	Dd	.ActivateWindow
	Dd	.DeActivateWindow
	Dd	.MouseEvent
	Dd	.KeyboardEvent

.ActivateWindow	Lea	eax,[mo]
	Int	0xff
	Ret

.DeActivateWindow	Lea	eax,[ko]
	Int	0xff
	Ret

.MouseEvent	Mov	ebx,[ebp+wp_OldMouse]
	Bt	ebx,WMIEMBB_LEFT
	Jc	.ActiveObject

	Mov	eax,[ebp+wp_WindowObject]
	Mov	ebx,[ebp+wp_Message]
	Call	WinFindObject
	Jnc near	.NoObjectFound
	Mov	[ebp+wp_ActiveObject],eax
.ActiveObject	Mov	eax,[ebp+wp_ActiveObject]
	Test	eax,eax
	Jz	.Exit	; No Active Object!!! rename label later.
	Mov dword	[eax+CD_ReturnFlags],0
	Mov dword	[eax+CD_ReturnEvents],0
	Mov	ebx,CM_EVENT
	Mov	ecx,[ebp+wp_Message]
	LIB	DoMethod,[ebp+wp_UIBase]

	Mov	ebx,[eax+CD_ReturnEvents]
	Test	ebx,ebx
	Jz	.NoEvents
	Push	ebx
	Mov	eax,WME_SIZE
	XOr	ebx,ebx
	LIB	AllocMem,[ebp+wp_SysBase]
	Pop	ebx
	Mov dword	[eax+WM_Command],WMCMD_EVENT
	Mov	ecx,[ebp+wp_ActiveObject]
	Mov	[eax+WM_Object],ecx
	Mov	[eax+WME_Event],ebx
	Mov	ebx,eax
	Mov	eax,[ebp+wp_WindowObject]
	Mov	eax,[eax+WC_UserPort]
	LIB	PutMsg,[ebp+wp_SysBase]
.NoEvents:
.Exit	Mov	eax,[ebp+wp_Message]

	Mov	ebx,[eax+WMIE_MouseY]	; Here the values for MouseX/Y is within the window...
	Mov	ecx,[eax+WMIE_MouseX]
	Mov	edx,[ebp+wp_WindowObject]
	Sub	ebx,[edx+CD_TopEdge]
	Sub	ecx,[edx+CD_LeftEdge]

	Cmp	ebx,0x10	; 0x10 is in this case TitleBar-Height
	Ja	.NoTitleBar


;BBP_Height	ResD	1
;BBP_Width	ResD	1
;BBP_DestY	ResD	1
;BBP_DestX	ResD	1
;BBP_SourceY	ResD	1
;BBP_SourceX	ResD	1
;BBP_Window	ResD	1


;	PushAD
;	Lea	eax,[0xfff0077E]	; WindowStruct [Root window]
;	Push	eax
;	Mov	eax,[ebp+wp_WindowObject]
;	Mov	[eax+CD_LeftEdge],ebx
;	Mov	[eax+CD_TopEdge],ecx
;	Push	ebx
;	Push	ecx
;	Add	ebx,[eax+WMIE_MouseDeltaX]
;	Add	ecx,[eax+WMIE_MouseDeltaY]
;	Push	ebx
;	Push	ecx
;	Mov	eax,[ebp+wp_WindowObject]
;
;	Push dword	[eax+CD_Width]
;	Push dword	[eax+CD_Height]
;	Call	ClassRender
;	PopAD

	PushAD
	Mov	ebx,[eax+WMIE_MouseDeltaX]
	Mov	ecx,[eax+WMIE_MouseDeltaY]
	Mov	eax,[ebp+wp_WindowObject]
	Add	[eax+CD_LeftEdge],ebx
	Add	[eax+CD_TopEdge],ecx
	Push	eax
	Call	ClassRender
	Pop	eax
	Call	ClassRefresh
	PopAD

	Jmp	.NoStatusBar

.NoTitleBar	Mov	edi,[ebp+wp_WindowObject]
	Mov	edx,[edi+CD_Height]
	Sub	edx,0x10	; 0x10 is in this case StatusBar-Height
	Cmp	ebx,edx
	Jb	.NoStatusBar

	Mov	edx,[edi+CD_Width]
	Sub	edx,0x10	; 0x10 is in this case ResizeButton-width
	Cmp	ecx,edx
	Jb	.NoStatusBar

	PushAD
	Mov	ebx,[eax+WMIE_MouseDeltaX]
	Mov	ecx,[eax+WMIE_MouseDeltaY]
	Mov	eax,[ebp+wp_WindowObject]
	Add	ebx,[eax+CD_Width]
	Add	ecx,[eax+CD_Height]

	Cmp	ebx,[eax+CD_MaxWidth]
	Jbe	.NotToWide
	Mov	ebx,[eax+CD_MaxWidth]
.NotToWide	Cmp	ebx,[eax+CD_MinWidth]
	Jae	.NotToNarrow
	Mov	ebx,[eax+CD_MinWidth]
.NotToNarrow	Cmp	ecx,[eax+CD_MaxHeight]
	Jbe	.NotToHigh
	Mov	ecx,[eax+CD_MaxHeight]
.NotToHigh	Cmp	ecx,[eax+CD_MinHeight]
	Jae	.NotToLow
	Mov	ecx,[eax+CD_MinHeight]

.NotToLow	Mov	[eax+CD_Width],ebx
	Mov	[eax+CD_Height],ecx

	Push	eax
	Call	ClassLayout
	Mov	eax,[esp]
	Call	ClassRender
	Pop	eax
	Call	ClassRefresh
	PopAD

.NoStatusBar	Mov	ebx,[eax+WMIE_MouseButton]
	Mov	[ebp+wp_OldMouse],ebx
	Ret

.NoObjectFound	Mov dword	[ebp+wp_ActiveObject],0
	Jmp	.Exit


.KeyboardEvent	Ret

mo	db	'activate',0xa,0
ko	db	'deactivate',0xa,0


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;WinFindObject
;
;Input
; eax = windowObject
;
;Output
; eax = Object that is under the mouse
; Carry clear for no object found, carry set for object found.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
WinFindObject	Mov	edi,ebx
	Mov	ecx,eax
	Mov	eax,[edi+WMIE_MouseY]
	Mov	edx,[edi+WMIE_MouseX]
	Sub	eax,[ecx+CD_TopEdge]
	Sub	edx,[ecx+CD_LeftEdge]
	Mov	[ebp+wp_Dummy],esp	; Find out which object
	;
.Main	PushAD
	Mov	esi,ecx
	Lea	ecx,[esi+LN_SIZE]		; we're pointing at in the window
.Loop	NEXTNODE	ecx,.NoMore
	Cmp dword	[ecx+CD_Type],CLASS_GROUP
	Jne	.NoGroup
	Call	.Main
	Jmp	.Loop
	;-
.NoGroup	Mov	ebx,[ecx+CD_TopEdge]	; Check Coordinates against CD_Width/CD_Height..
	Cmp	eax,ebx
	Jb	.Loop
	Add	ebx,[ecx+CD_Height]
	Cmp	eax,ebx
	Ja	.Loop
	Mov	ebx,[ecx+CD_LeftEdge]
	Cmp	edx,ebx
	Jb	.Loop
	Add	ebx,[ecx+CD_Width]
	Cmp	edx,ebx
	Ja	.Loop
	;
	Mov	esp,[ebp+wp_Dummy]	; Restore stackpointer
	Mov	eax,ecx
	Stc
	Ret

.NoMore	PopAD
	Clc
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
WinClassMethod	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
WinUserMethod	Mov	edi,[ebp+wp_Message]
	Mov	eax,[edi+WM_Object]
	Mov	ebx,[edi+WMCL_Method]
	Mov	ecx,[edi+WMCL_MethodData]
	LIB	DoMethod,[ebp+wp_UIBase]
	Mov	[edi+WMCL_ReturnData],eax

	Mov	eax,[ebp+wp_Message]
	Mov	eax,[eax+WMCL_Process]
	LIB	Awake,[ebp+wp_SysBase]
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
WinInterClass	Ret

