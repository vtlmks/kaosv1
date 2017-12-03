;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     UIHandler.s V1.0.0
;


	Struc UIHMemory
UIH_MsgPort	ResD	1
UIH_Message	ResD	1
UIH_ScreenX	ResD	1
UIH_ScreenY	ResD	1
UIH_ScreenDepth	ResD	1
UIH_MouseX	ResD	1	; Mouse x
UIH_MouseY	ResD	1	; Mouse y
UIH_ButtonStatus	ResD	1	; Button status
UIH_OldButtons	ResD	1	; Old Button status
UIH_DeltaX	ResD	1	; Delta x
UIH_DeltaY	ResD	1	; Delta y
UIH_Window	ResD	1	; Window that we found
UIH_ClassID	ResD	1
UIH_ClassList	ResB	MLH_SIZE
UIH_SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UIHandler	LINK	UIH_SIZE
	Mov	[UIMemoryBase],ebp
	Call	UISetupPort
	Call	UISetupScreen
	Mov dword	[ebp+UIH_ClassID],0
	INITLIST	[ebp+UIH_ClassList]

.Main	LIBCALL	Wait,ExecBase
.L	LIBCALL	GetMsg,ExecBase
	Test	eax,eax
	Jz	.Main

	Mov	[ebp+UIH_Message],eax
	Mov	ebx,[eax+UIPKT_COMMAND]
	Lea	esi,[UIHFunctionTable]
.Parse	Lodsd
	Cmp	eax,-1
	Je	.NoMore
	Cmp	ebx,eax
	Je	.Match
	Add	esi,4
	Jmp	.Parse

.Match	Mov	eax,[ebp+UIH_Message]
	Call	[esi]

.NoMore	Mov	eax,[ebp+UIH_Message]
	LIBCALL	ReplyMsg,ExecBase
	Jmp	.L

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UIHFunctionTable	Dd	UIPKTCMD_RAWMOUSE,UIH_RawMouse
	Dd	UIPKTCMD_RAWKEY,UIH_RawKey
	Dd	-1



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UISetupPort	LIBCALL	CreateMsgPort,ExecBase
	Mov	[ebp+UIH_MsgPort],eax
	Lea	ebx,[UIHandlerPortN]
	LIBCALL	AddPort,ExecBase
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UISetupScreen	Lea	eax,[SysBase+SB_ScreenList]
	SUCC	eax
	Mov	ebx,[eax+SC_Width]
	Mov	ecx,[eax+SC_Height]
	Mov	edx,[eax+SC_Depth]
	Mov	[ebp+UIH_ScreenX],ebx
	Mov	[ebp+UIH_ScreenY],ecx
	Mov	[ebp+UIH_ScreenDepth],edx
	Ret


	%Include	"Userinterface\Handler\RawMouse.s"
	%Include	"Userinterface\Handler\RawKey.s"

