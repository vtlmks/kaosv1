;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     RawKey.s V1.0.0
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UIH_RawKey	Mov	edi,eax		; Message ptr

	Call	UIH_RawKeyDebug		; Send everything to debugger

;;	Ret

	Mov	edx,[SysBase+SB_FocusWindow]
	Test	edx,edx
	Jz	.Failure
	Mov	edx,[edx+WC_WindowPort]
	Test	edx,edx
	Jz	.Failure
	;
	Movzx	eax,byte [edi+UIPKT_DATA]

	Bt	eax,KBB_CapsLock
	Jc	.Caps
	Bt	eax,KBB_LShift
	Jc	.Shift
	Bt	eax,KBB_RShift
	Jc	.Shift

	Mov	eax,[KeyboardLCase+eax]
	Jmp	.PutMsg
.Shift	Mov	eax,[KeyboardUCase+eax]
	Jmp	.PutMsg
.Caps	Mov	eax,[KeyboardCCase+eax]

.PutMsg	Mov	ecx,eax
	Mov	eax,WMIE_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Test	eax,eax
	Jz	.Failure
	Mov	esi,eax
	Mov	ebx,ecx

	Mov	eax,[edi+UIPKT_DATA]
	Mov	[esi+WMIE_KeyRaw],al
	Mov	[esi+WMIE_KeyQualifier],ah
	Mov	[esi+WMIE_KeyVanilla],bl
	Mov byte	[esi+LN_TYPE],NT_FREEMSG
	Mov dword	[esi+MN_LENGTH],WMIE_SIZE
	Mov dword	[esi+WMIE_Type],WMIET_KEYBOARD
	Mov	eax,edx
	Mov	ebx,esi
	LIBCALL	PutMsg,ExecBase
.Failure	Ret




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; This forces a keyboard packet to the debugger
;
UIH_RawKeyDebug	PushAD
	Movzx	eax,byte [edi+UIPKT_DATA]
	Movzx	ebx,byte [edi+UIPKT_DATA+1]
	Bt	ebx,KBB_CapsLock
	Jc	.Caps
	Bt	ebx,KBB_LShift
	Jc	.Shift
	Bt	ebx,KBB_RShift
	Jc	.Shift
	Mov	edx,[KeyboardLCase+eax]
	Jmp	.PutMsg
.Shift	Mov	edx,[KeyboardUCase+eax]
	Jmp	.PutMsg
.Caps	Mov	edx,[KeyboardCCase+eax]

.PutMsg	Test	dl,dl
	Jz	.Failure		; Skip non-printables..

	Mov	eax,UIPKT_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Test	eax,eax
	Jz	.Failure
	Mov	esi,eax

	Mov	[esi+UIPKT_DATA],edx
	Mov dword	[esi+UIPKT_COMMAND],UIPKTCMD_RAWKEY
	Mov byte	[esi+MN_NODE+LN_TYPE],NT_FREEMSG

	Mov	eax,[SysBase+SB_FocusProcess]
	Lea	eax,[eax+PC_PortList]
	SUCC	eax
	Mov	ebx,esi
	LIBCALL	PutMsg,ExecBase

.Failure	PopAD
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
KeyboardLCase	Db	0,0,'1234567890-=',8,0,'qwertyuiop[]',10,0
	Db	"asdfghjkl;'`",0,'\zxcvbnm,./',0,'*',0,' '
	Db	0,0,0,0,0,0,0,0,0,0,0,0,0,'789-456+1230.',0
	Db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

KeyboardUCase	Db	0,0,'!@#$%^&*()_+',8,0,'QWERTYUIOP{}',10,0
	Db	'ASDFGHJKL:"~',0,'|ZXCVBNM<>?',0,'*',0,' '
	Db	0,0,0,0,0,0,0,0,0,0,0,0,0,'789-456+1230.',0
	Db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

KeyboardCCase	Db	0,0,'1234567890-=',8,0,'QWERTYUIOP[]',10,0
	Db	"ASDFGHJKL;'`",0,'\ZXCVBNM,./',0,'*',0,' '
	Db	0,0,0,0,0,0,0,0,0,0,0,0,0,'789-456+1230.',0
	Db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

