;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;CheckMsg() -	Check if there are any messages pending in any ports
;	opened by the process.
;
;OutPut:
; Carry set if there are any messages.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
CheckMsg	PushFD
	PUSHX	eax,ebx,ecx,edx
	Mov	eax,[SysBase+SB_CurrentProcess]
	Lea	eax,[eax+PC_PortList]
	SPINLOCK	eax
	Push	eax
	;
.Loop	NEXTNODE	eax,.NoMsgPorts
	Bt dword	[eax+MP_FLAGS],MPB_SYSSELECTED
	Jc	.FetchMsg
	Bt dword	[eax+MP_FLAGS],MPB_SYSDISABLED
	Jc	.Loop
.FetchMsg	Lea	ebx,[eax+MP_MSGLIST]
	Mov	ecx,ebx
	SPINLOCK	ecx
	SUCC	ebx
	SPINUNLOCK	ecx
	Cmp dword	[ebx+LN_SUCC],0
	Je	.Loop
	;
	Pop	eax
	SPINUNLOCK	eax
	;
	POPX	eax,ebx,ecx,edx
	PopFD
	Stc
	Ret
	;
.NoMsgPorts	Pop	eax
	SPINUNLOCK	eax
	;
	POPX	eax,ebx,ecx,edx
	PopFD
	Clc
	Ret

