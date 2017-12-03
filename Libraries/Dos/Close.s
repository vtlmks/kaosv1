;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Close.s V1.0.0
;
;     Additional body description goes here.
;



	Struc DosClose
DCLOSE_FH	ResD	1
DCLOSE_DOSPACKET	ResD	1
DCLOSE_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Close - Close a previously opened file
;
; Inputs:
;  eax - Filehandler, as returned by Open()
;
; Output:
;  eax - Null for success
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DOS_Close	PUSHX	ebx,ecx,edi,ebp
	PushFd
	;
	LINK	DCLOSE_SIZE
	Mov	[ebp+DCLOSE_FH],eax
	;
	Mov	eax,DP_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	[ebp+DCLOSE_DOSPACKET],eax
	;
	Mov	edi,[ebp+DCLOSE_FH]
	Mov	ebx,[ebp+DCLOSE_DOSPACKET]
	Mov	ecx,[edi+FH_PORT]
	Mov	[ebx+DP_MESSAGE+MN_REPLYPORT],ecx
	Mov dword	[ebx+DP_TYPE],DOSPKT_CLOSE
	Mov	[ebx+DP_FH],edi
	;
	Mov	eax,[edi+FH_DOSENTRY]
	Mov	eax,[eax+DE_PORT]
	LIBCALL	PutMsg,ExecBase



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
	Push	ebx
	;
	Mov	eax,[ebp+DCLOSE_DOSPACKET]
	LIBCALL	FreeMem,ExecBase
	Mov	eax,[edi+FH_PORT]
	LIBCALL	DeleteMsgPort,ExecBase
	Mov	eax,[ebp+DCLOSE_FH]
	LIBCALL	FreeMem,ExecBase
	Pop	eax
	UNLINK	DCLOSE_SIZE
	PopFD
	POPX	ebx,ecx,edi,ebp
	Ret
