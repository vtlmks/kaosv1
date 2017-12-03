;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;ReplyMsg()
; - ADDTAIL() the message to the port in the MP_REPLYPORT.
; - Set the LN_TYPE to NT_REPLYMESSAGE
; - It is up to the user to set the ReplyTo field.
;
;Input:
; eax - Message to reply
;
;Output:
; eax - bool, zero for success
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_ReplyMsg	PushFD
	Test	eax,eax
	Jz near	.NoMessage
	PUSHX	ebx,ecx
	Push	eax
	;
	Cmp byte	[eax+LN_TYPE],NT_FREEMSG
	Jne	.ReplyMsg

	Pop	eax
	LIBCALL	FreeMem,ExecBase		; Free NT_FREEMSG's

	Jmp	.NotWaiting

.ReplyMsg	Mov	ebx,eax
	Mov byte	[eax+LN_TYPE],NT_REPLYMSG
	Mov	eax,[ebx+MN_REPLYPORT]
	Lea	eax,[eax+MP_MSGLIST]	; eax=list, ebx=message (node)
	SPINLOCK	eax
	;--
	Push	eax
	ADDTAIL
	Pop	eax
	;--
	SPINUNLOCK	eax

	Pop	eax
	Mov	ecx,[eax+MN_REPLYPORT]
	Bt dword	[ecx+MP_FLAGS],MPB_SYSSELECTED
	Jc	.Restore
	Bt dword	[ecx+MP_FLAGS],MPB_SYSDISABLED
	Jc	.NotWaiting
	Bt dword	[ecx+MP_FLAGS],MPB_SELECTED
	Jnc	.NotWaiting
	;
.Restore	Mov	eax,[eax+MN_REPLYPORT]
	Mov	eax,[eax+MP_SIGPROC]	; restore waiting process from waitlist.
	And dword	[eax+PC_Flags],~PCF_SLEEP

.NotWaiting	POPX	ebx,ecx
.NoMessage	PopFD
	Ret
