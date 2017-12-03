;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;PutMsg()
; - ADDTAIL() the message to the selected ports message list. It's up to the process that the supplied
;   message is a valid message.
; - Set the LN_TYPE to NP_MESSAGE. If there is no Replyport, set LN_TYPE to NP_FREEMSG.
; - It is up to the user to initialize the ReplyTo field.
;
;Input:
; eax - port where the message are destined.
; ebx - message to be sent.
;
;Output:
; eax - Bool, zero for success
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_PutMsg	PushFD
	PUSHX	ebx,ecx

	Test	eax,eax
	Jz	.Exit

	Push	eax
	SPINLOCK	eax

	Lea	eax,[eax+MP_MSGLIST]
	Cmp dword	[ebx+MN_REPLYPORT],0
	Jne	.TypeMessage
	Mov byte	[ebx+LN_TYPE],NT_FREEMSG
	Jmp	.TypeFreeMsg
.TypeMessage	Mov byte	[ebx+LN_TYPE],NT_MESSAGE
.TypeFreeMsg	ADDTAIL
	;
	Pop	eax
	Bt dword	[eax+MP_FLAGS],MPB_SYSSELECTED
	Jc	.Restore
	Bt dword	[eax+MP_FLAGS],MPB_SYSDISABLED
	Jc	.NotWaiting
	Bt dword	[eax+MP_FLAGS],MPB_SELECTED
	Jnc	.NotWaiting
	;
.Restore	Mov	ebx,[eax+MP_SIGPROC]	; check if the process that will recieve the message is sleeping
	Btr dword	[ebx+PC_Flags],PCB_SLEEP

	;
.NotWaiting	SPINUNLOCK	eax

.Exit	XOr	eax,eax
	POPX	ebx,ecx
	PopFD
	Ret
