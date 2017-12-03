;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;DeleteMsgPort()
; - (?) Should it be up to the user to make sure there are no pending messages at the message port?
;   or should we flush them? Problem would be that if the messages are supposed to be discarded by
;   the user task, and we reply them, then there will be alot of messages pending in memory, or if the
;   replyport is Zero, we would fuck up the IDT....
; - REMOVE() the port from the current process's port list.
; - Free the memory allocated by the port.
;
;Input:
; eax - Port to be discarded.
;
;Output:
; eax - bool, null for success.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_DeleteMsgPort	PushFD
	PushAD

	Test	eax,eax
	Jz	.NoPort

	Mov	ecx,[SysBase+SB_CurrentProcess]
	Lea	ecx,[eax+PC_PortList]
	SPINLOCK	ecx
	PUSHX	eax,ecx
	REMOVE
	POPX	eax,ecx
	SPINUNLOCK	ecx
	LIBCALL	FreeMem,ExecBase
	PopAD
.NoPort	XOr	eax,eax
	PopFD
	Ret
