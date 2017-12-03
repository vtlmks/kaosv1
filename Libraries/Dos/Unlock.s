;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Unlock.s V1.0.0
;
;
;     Unlocks a file or directory that has been locked.


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Inputs:
;
;  eax = pointer to lock as returned by Lock(), it's safe to call this with
;        a null.
;
; Output:
;
;  eax = none
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc DOSUnlockStruc
DOSUL_PacketMem	ResD	1
DOSUL_PacketPort	ResD	1
DOSUL_SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DOS_Unlock	PushFD
	PushAD
	Test	eax,eax
	Jz near	.NoLock

	LINK	DOSUL_SIZE
	Mov	edi,eax		; Put lock in edi

	; Send Unlock to FileSystem first

	Mov	eax,DP_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	[ebp+DOSUL_PacketMem],eax
	;
	LIBCALL	CreateMsgPort,ExecBase
	Mov	[ebp+DOSUL_PacketPort],eax
	;
	Mov	ebx,[ebp+DOSUL_PacketMem]
	Mov	ecx,[ebp+DOSUL_PacketPort]
	Mov	[ebx+DP_MESSAGE+MN_REPLYPORT],ecx
	Mov dword	[ebx+DP_TYPE],DOSPKT_UNLOCK
	Mov	[ebx+DP_ARG0],edi		; Lock handler is provided as an argument to FS
	;
	Mov	eax,[edi+LOCK_DOSENTRY]
	Mov	eax,[eax+DE_PORT]
	LIBCALL	PutMsg,ExecBase
	;
	Mov	eax,[ebp+DOSUL_PacketPort]
	Mov	ebx,MPSELECT_SYSTEMSET
	LIBCALL	SelectMsgPort,ExecBase
	LIBCALL	Wait,ExecBase
	LIBCALL	GetMsg,ExecBase
	Mov	ebx,MPSELECT_SYSTEMRESET
	LIBCALL	SelectMsgPort,ExecBase
	;
	Mov	eax,[ebp+DOSUL_PacketMem]
	LIBCALL	FreeMem,ExecBase
	Mov	eax,[ebp+DOSUL_PacketPort]
	LIBCALL	DeleteMsgPort,ExecBase
	;
	Mov	eax,edi
	Push	eax
	REMOVE			; REMOVE the lock from locklist
	Pop	eax
	LIBCALL	FreeMem,ExecBase
	UNLINK	DOSUL_SIZE

.NoLock	PopAD
	PopFD
	Ret
