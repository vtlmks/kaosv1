;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;GetMsg() - Get the first message from a message port allocated by the
; current process. The messages are sorted in a prioritized list.
;
;OutPut:
; eax - Message
;
;
; 20010722	- later on we need to add the inner spinlock aswell...
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_GetMsg	PushFD
	PUSHX	ebx,ecx,edx
	Mov	eax,[SysBase+SB_CurrentProcess]
	Lea	eax,[eax+PC_PortList]
	SPINLOCK	eax
	Push	eax

.Loop	NEXTNODE	eax,.NoMsgPort
	Bt dword	[eax+MP_FLAGS],MPB_SYSSELECTED
	Jc	.FetchMsg
	Bt dword	[eax+MP_FLAGS],MPB_SYSDISABLED
	Jc	.Loop
.FetchMsg	Lea	ebx,[eax+MP_MSGLIST]
	NEXTNODE	ebx,.Loop
	Mov	ecx,[eax+MP_ID]		; Fetch MessagePortID
	Mov	eax,ebx
	Mov	[eax+MN_PORTID],ecx	; Give the MessagePortID to the user.
	;
	Push	eax
	REMOVE
	Pop	eax
	;

.ExitGetMsg	Pop	ebx
	SPINUNLOCK	ebx
	POPX	ebx,ecx,edx
	POPFD
	Ret

.NoMsgPort	XOr	eax,eax
	Jmp	.ExitGetMsg
