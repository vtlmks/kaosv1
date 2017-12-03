;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Read.s V1.0.0
;
;     Additional body description goes here.
;



	Struc DosRead
DREAD_FH	ResD	1
DREAD_LENGTH	ResD	1
DREAD_BUFFER	ResD	1
DREAD_DOSPACKET	ResD	1
DREAD_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Read - Read a file
;
; Inputs:
;  eax - Filehandler, as returned by Open()
;  ebx - Length, in bytes
;  ecx - Buffer
;
; Output:
;  eax - Number of bytes read
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DOS_Read	PushFd
	Test	eax,eax
	Jz near	.Failure
	Test	ebx,ebx
	Jz near	.Failure
	Test	ecx,ecx
	Jz near	.Failure
	PUSHX	ebx,ecx,ebp,edi
	;

	LINK	DREAD_SIZE
	;
	Mov	[ebp+DREAD_FH],eax
	Mov	[ebp+DREAD_LENGTH],ebx
	Mov	[ebp+DREAD_BUFFER],ecx
	;
	Mov	eax,DP_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	[ebp+DREAD_DOSPACKET],eax
	;
	Mov	edi,[ebp+DREAD_FH]
	Mov	ebx,[ebp+DREAD_DOSPACKET]
	Mov	ecx,[edi+FH_PORT]
	Mov	[ebx+DP_MESSAGE+MN_REPLYPORT],ecx
	Mov dword	[ebx+DP_TYPE],DOSPKT_READ
	Mov	[ebx+DP_FH],edi
	Mov	ecx,[ebp+DREAD_LENGTH]
	Mov	[ebx+DP_ARG0],ecx
	Mov	ecx,[ebp+DREAD_BUFFER]
	Mov	[edi+FH_BUFFER],ecx
	;
	Mov	eax,[edi+FH_DOSENTRY]
	Mov	eax,[eax+DE_PORT]
	LIBCALL	PutMsg,ExecBase
	;
	Mov	eax,[edi+FH_PORT]
	Mov	ebx,MPSELECT_SYSTEMSET
	LIBCALL	SelectMsgPort,ExecBase
	LIBCALL	Wait,ExecBase
	LIBCALL	GetMsg,ExecBase
	Mov	ebx,MPSELECT_SYSTEMRESET
	LIBCALL	SelectMsgPort,ExecBase
	;
	Mov	eax,[ebp+DREAD_DOSPACKET]
	Mov	ebx,[eax+DP_RES0]
	;
	LIBCALL	FreeMem,ExecBase
	UNLINK	DREAD_SIZE
	Mov	eax,ebx
	POPX	ebx,ecx,ebp,edi
	PopFD
	Ret


.Failure	XOr	eax,eax
	PopFD
	Ret
