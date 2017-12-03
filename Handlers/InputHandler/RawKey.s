;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Rawkey.s V1.0.0
;
;     Input-handler Rawkey and Vanillakey
;




;
;
; ecx == IHPKT structure
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IH_RawKey
;	Call	IHRKSendRawKey
	;
	; debug stuff below this..

	Push	ecx
	Lea	ecx,[InputPacketTags]
	LIBCALL	AllocMem,ExecBase
	Test	eax,eax
	Jz	.MemFailure

	Mov	edx,eax

	Mov dword	[edx+IHPKT_COMMAND],IHCMD_RAWKEY
	Mov byte	[edx+MN_NODE+LN_TYPE],NT_FREEMSG
	Pop	ecx

	Mov	eax,[ecx+IHPKT_DATA]
	XOr	ebx,ebx
	Mov	bl,ah
	Bt	bx,KBB_CapsLock
	Jc	.Caps
	Bt	bx,KBB_LShift
	Jc	.Shift
	Bt	bx,KBB_RShift
	Jc	.Shift

	Movzx	eax,al
	Mov	eax,[IHKeyboardLCase+eax]
	Jmp	.Mo

.Shift	Movzx	eax,al
	Mov	eax,[IHKeyboardUCase+eax]
	Jmp	.Mo

.Caps	Movzx	eax,al
	Mov	eax,[IHKeyboardCCase+eax]

.Mo	Mov	[edx+IHPKT_DATA],eax

	Mov	eax,[SysBase+SB_FocusProcess]
	Lea	eax,[eax+PC_PortList]
	SUCC	eax
	Mov	ebx,edx
	LIBCALL	PutMsg,ExecBase
	Ret

.MemFailure	Lea	eax,[.NoMemTxt]
	Int	0xff
	Ret

.NoMemTxt	Db	"** Rawkey -- nomemory left..",0xa,0


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
IHRKSendRawKey	PushAD
	XOr	edi,edi
	Mov	esi,[SysBase+SB_FocusWindow]
	Test	esi,esi
	Jz near	.NoEvent
	;

	Push	ecx
	Lea	ecx,[InputEventMemTags]
	LIBCALL	AllocMem,ExecBase
	Mov	edi,eax
	Mov byte	[edi+LN_TYPE],NT_FREEMSG
	Mov dword	[edi+MN_LENGTH],IHMSG_SIZE
	Mov dword	[edi+IHMSG_Type],IHEVENTF_RAWKEY
	Pop	ecx
	;--
	Mov	eax,[ecx+IHPKT_DATA]
	XOr	ebx,ebx
	Mov	bl,ah
	Bt	bx,KBB_CapsLock
	Jc	.Caps
	Bt	bx,KBB_LShift
	Jc	.Shift
	Bt	bx,KBB_RShift
	Jc	.Shift
	;--
	Movzx	eax,al
	Mov	eax,[IHKeyboardLCase+eax]
	Jmp	.SetKey
.Shift	Movzx	eax,al
	Mov	eax,[IHKeyboardUCase+eax]
	;Or byte	[edi+IHMSG_Qualifier],IHQUALIFIERF_SHIFT
	Jmp	.SetKey
.Caps	Movzx	eax,al
	Mov	eax,[IHKeyboardCCase+eax]
	Or byte	[edi+IHMSG_Qualifier],IHQUALIFIERF_CAPSLOCK
.SetKey	Mov byte	[edi+IHMSG_Key],al
	;--

;	Cmp dword	[esi+WC_ActiveObject],0
;	Je	.NoActiveObject
;	Mov	eax,[esi+WC_ActiveObject]
;	Mov	ebx,CM_EVENT
;	Mov	ecx,edi
;	LIBCALL	DoMethod,ExecBase

	Mov	eax,[SysBase+SB_FocusWindow]
	Mov	[edi+IHMSG_Object],eax

	Mov	eax,EventTxt
	Int	0xff

	Mov	eax,ActiveDesktopTxt
	Int	0xff
	Mov	eax,[SysBase+SB_FocusWindow]
	Int	0xfe

.NoActiveObject	;Bt dword	[esi+WC_EventFlags],IHEVENTB_RAWKEY
	;Jnc 	.NoEvent
	;
	Mov	eax,[esi+WC_WindowPort]
	Mov	ebx,edi
	LIBCALL	PutMsg,ExecBase
	PopAD
	Ret

.NoEvent	Mov	eax,edi
	LIBCALL	FreeMem,ExecBase
	PopAD
	Ret

EventTxt	Db	"Sending event",0xa,0
ActiveDesktopTxt	Db	"Activ desktop: ",0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
IHRKSendVanilla	Mov	esi,[edi+IH_Window]
	Bt dword	[esi+WC_EventFlags],IHEVENTB_VANILLAKEY
	Jnc	.NoEvent
	;
	Lea	ecx,[InputEventMemTags]
	LIBCALL	AllocMem,ExecBase
	Mov	ebx,eax
	Mov byte	[ebx+LN_TYPE],NT_FREEMSG
	Mov dword	[ebx+MN_LENGTH],IHMSG_SIZE
	Mov dword	[ebx+IHMSG_Type],IHEVENTF_VANILLAKEY

	; fill key value, qualifier etc

	Mov	eax,[esi+WC_WindowPort]
	LIBCALL	PutMsg,ExecBase
.NoEvent	Ret




InputEventMemTags	Dd	MMA_SIZE,IHMSG_SIZE
	Dd	MMA_FLAGS,MEMF_NOKEY
	Dd	TAG_DONE

InputPacketTags	Dd	MMA_SIZE,IHPKT_SIZE
	Dd	TAG_DONE


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IHKeyboardLCase	Db	0,0,'1234567890-=',8,0,'qwertyuiop[]',10,0
	Db	"asdfghjkl;'`",0,'\zxcvbnm,./',0,'*',0,' '
	Db	0,0,0,0,0,0,0,0,0,0,0,0,0,'789-456+1230.',0
	Db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

IHKeyboardUCase	Db	0,0,'!@#$%^&*()_+',8,0,'QWERTYUIOP{}',10,0
	Db	'ASDFGHJKL:"~',0,'|ZXCVBNM<>?',0,'*',0,' '
	Db	0,0,0,0,0,0,0,0,0,0,0,0,0,'789-456+1230.',0
	Db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

IHKeyboardCCase	Db	0,0,'1234567890-=',8,0,'QWERTYUIOP[]',10,0
	Db	"ASDFGHJKL;'`",0,'\ZXCVBNM,./',0,'*',0,' '
	Db	0,0,0,0,0,0,0,0,0,0,0,0,0,'789-456+1230.',0
	Db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
