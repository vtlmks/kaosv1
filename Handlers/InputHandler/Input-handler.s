;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Input-handler.s V1.0.0
;
;     Input handler.
;
;     Filters input and sends data to the window process that is in focus.
;
;

	Struc IH
IH_MsgPort	ResD	1	; Inputhandler messageport
IH_ScreenX	ResD	1	; Screen maximum X
IH_ScreenY	ResD	1	; Screen maximum Y
IH_ScreenDepth	ResD	1	; Screen depth
IH_MouseX	ResD	1	; Mouse x
IH_MouseY	ResD	1	; Mouse y
IH_ButtonStatus	ResD	1	; Button status
IH_OldButtons	ResD	1	; Old Button status
IH_DeltaX	ResD	1	; Delta x
IH_DeltaY	ResD	1	; Delta y
IH_Window	ResD	1	; Window that we found
IH_SIZE	EndStruc



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
IHVersion	Equ	1
IHRevision	Equ	5

IHInitTable	Dd	IH_SIZE
	Dd	IHBase
	Dd	IHInit
	Dd	-1

IHName	Db	"inputhandler.library",0
IHIDString	Db	"inputhandler.library 1.5 (2001-06-12)",0

IH_OpenCount	Dd	1

OpenIH	Mov	eax,IHBase
	Ret

CloseIH
ExpungeIH	Mov	eax,-1
	Ret

NullIH	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

IHInit	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Dd	IHRefreshMouse		; -36
	Dd	IHGetMouseState		; -32
	Dd	IHGetMouseCoords		; -28
	;-
	Dd	NullIH		; -24
	Dd	NullIH		; -20
	Dd	NullIH		; -16
	Dd	ExpungeIH		; -12
	Dd	CloseIH		; -8
	Dd	OpenIH		; -4
IHBase	Dd	0



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
InputHandler	Lea	ecx,[InputMemTags]
	LIBCALL	AllocMem,ExecBase
	Mov	edi,eax
	Mov	[IHBase],eax		; Fix this asap
	LIBCALL	CreateMsgPort,ExecBase
	Mov	[edi+IH_MsgPort],eax
	Lea	ebx,[InputPortN]
	LIBCALL	AddPort,ExecBase

	Call	IH_Init
	;
	;

.Loop	LIBCALL	Wait,ExecBase
.Main	LIBCALL	GetMsg,ExecBase
	Test	eax,eax
	Jz	.Loop
	;
	PUSHX	eax,edi
	Mov	ecx,eax
	Call	PollIHMsgPort
	POPX	eax,edi
	;
	LIBCALL	ReplyMsg,ExecBase
	Jmp	.Main




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PollIHSysPort
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PollIHMsgPort	Mov	eax,[eax+IHPKT_COMMAND]
	Call	[IHCommandTable+eax*4]
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IH_Init	Lea	eax,[SysBase+SB_ScreenList]
	SUCC	eax
	Mov	ebx,[eax+SC_Width]
	Mov	ecx,[eax+SC_Height]
	Mov	edx,[eax+SC_Depth]
	Mov	[edi+IH_ScreenX],ebx
	Mov	[edi+IH_ScreenY],ecx
	Mov	[edi+IH_ScreenDepth],edx
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IH_Register
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IH_Unregister
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	%Include	"Handlers\InputHandler\GetMouseCoords.s"
	%Include	"Handlers\InputHandler\GetMouseState.s"
	%Include	"Handlers\InputHandler\RefreshMouse.s"
	;
	%Include	"Handlers\InputHandler\Rawkey.s"
	%Include	"Handlers\InputHandler\Rawmouse.s"



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IHCommandTable	Dd	IH_Register
	Dd	IH_Unregister
	Dd	IH_RawKey
	Dd	IH_RawMouse

IHPortTable	Dd	PollIHSysPort
	Dd	PollIHMsgPort

InputMemTags	Dd	MMA_SIZE,IH_SIZE
	Dd	TAG_DONE


InputPortN	Db	"InputHandler",0

