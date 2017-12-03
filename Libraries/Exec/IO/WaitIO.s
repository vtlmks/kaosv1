;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     WaitIO.I V1.0.0
;
;     Wait for an IO request to complete. If the request has already
;     completed, this function will return at once. Note that this
;     function will NOT return to the user until the I/O has finished.
;
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; WaitIO - Wait for an IO request to complete
;
; Input:
;
;  eax - IO request
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_WaitIO	PushFD
	POPX	ebp
	Bt dword	[eax+IO_FLAGS],IOB_QUICK
	Jc	.Done
	Cmp byte	[eax+LN_TYPE],NT_REPLYMSG
	Je	.Done
	Mov	eax,[eax+MN_REPLYPORT]
	Mov	ebx,MPSELECT_SYSTEMSET
	LIBCALL	SelectMsgPort,ExecBase
	LIBCALL	Wait,ExecBase
	LIBCALL	GetMsg,ExecBase
	Mov	ebx,MPSELECT_SYSTEMRESET
	LIBCALL	SelectMsgPort,ExecBase
.Done	POPX	ebp
	PopFD
	Ret
