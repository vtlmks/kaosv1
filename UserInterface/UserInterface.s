;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     UserInterface.s V1.0.0
;
;     UserInterface.library and handler V1.0.0
;
;

UIStart	Lea	eax,[UILibTag]
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

UIVersion	Equ	1
UIRevision	Equ	1

UILibTag	Dd	LT_FLAGS,0
	Dd	LT_VERSION,UIVersion
	Dd	LT_REVISION,UIRevision
	Dd	LT_TYPE,NT_LIBRARY
	Dd	LT_PRIORITY,0
	Dd	LT_NAME,UIName
	Dd	LT_IDSTRING,UIIDString
	Dd	LT_INIT,UIInitTable
	Dd	TAG_DONE

UIInitTable	Dd	0	; _SIZE
	Dd	UIBase
	Dd	UIInit
	Dd	-1


UIMemoryBase	Dd	0	; Pointer to UIHandler process memory


UIName	Db	"userinterface.library",0
UIIDString	Db	"userinterface.library 1.0 (2001-06-10)",0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
UI_OpenCount	Dd	1

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
OpenUI	PushFD
	PushAD
	Cmp dword	[UI_OpenCount],0
	Jne	.UIOpened
	Call	UIInit
.UIOpened	Inc dword	[UI_OpenCount]
	PopAD
	PopFD
	Lea	eax,[UIBase]
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
CloseUI	Cmp dword	[UI_OpenCount],0
	Je	.Done
	Dec dword	[UI_OpenCount]
.Done	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
ExpungeUI	Mov	eax,-1
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
NullUI	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
UIInit	Lea	ecx,[UIHandlerProcTags]
	LIBCALL	AddProcess,ExecBase
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Dd	UI_DoMethod		; -72
	Dd	UI_UnregisterClass	; -68
	Dd	UI_RegisterClass		; -64
	Dd	UI_UserMethod		; -60
	Dd	UI_FindScreen		; -56
	Dd	UI_DisposeObject		; -52
	Dd	UI_CreateObject		; -48
	Dd	UI_LayoutObjectList	; -44
	Dd	UI_DisposeObjectList	; -40
	Dd	UI_CreateObjectList	; -36
	Dd	UI_OpenWindow		; -32
	Dd	UI_CloseWindow		; -28
	;
	Dd	NullUI		; -24
	Dd	NullUI		; -20
	Dd	NullUI		; -16
	Dd	ExpungeUI		; -12
	Dd	CloseUI		; -8
	Dd	OpenUI		; -4
UIBase:



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UIHandlerProcTags	Dd	AP_PROCESSPOINTER,UIHandler
	Dd	AP_USERDATA,0
	Dd	AP_PRIORITY,0
	Dd	AP_STACKSIZE,4000
	Dd	AP_RING,3
	Dd	AP_QUANTUM,2
	Dd	AP_NAME,UIHandlerN
	Dd	TAG_DONE

UIHandlerN	Db	"userinterface.handler",0
UIHandlerPortN	Db	"userinterface.port",0


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	%Include	"Userinterface\Handler\UIHandler.s"

	%Include	"Userinterface\Library\CloseWindow.s"
	%Include	"Userinterface\Library\CreateObject.s"
	%Include	"Userinterface\Library\CreateObjectList.s"
	%Include	"Userinterface\Library\DisposeObject.s"
	%Include	"Userinterface\Library\DisposeObjectList.s"
	%Include	"Userinterface\Library\DoMethod.s"
	%Include	"Userinterface\Library\FindScreen.s"
	%Include	"Userinterface\Library\LayoutObjectList.s"
	%Include	"Userinterface\Library\OpenWindow.s"
	%Include	"Userinterface\Library\RegisterClass.s"
	%Include	"Userinterface\Library\UnregisterClass.s"
	%Include	"Userinterface\Library\UserMethod.s"

