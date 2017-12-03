;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;    Seek.s V1.0.0
;
;     Additional body description goes here.
;

	Struc DosSeek
DSEEK_FH	ResD	1
DSEEK_OFFSET	ResD	1
DSEEK_MODE	ResD	1
DSEEK_DOSPACKET	ResD	1
DSEEK_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Seek - Seek in a file
;
; Inputs:
;  eax - Filehandler, as returned by Open()
;  ebx - Position, in bytes
;  ecx - Mode (OFFSET_BEGINNING, OFFSET_CURRENT, OFFSET_END)
;
; Output:
;  eax - Old position
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DOS_Seek	PUSHX	ebx,ecx,edx,ebp,edi
	PushFd
	;
	LINK	DSEEK_SIZE
	Mov	[ebp+DSEEK_FH],eax
	Mov	[ebp+DSEEK_OFFSET],ebx
	Mov	[ebp+DSEEK_MODE],ecx
	;
	Mov	eax,DP_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	[ebp+DSEEK_DOSPACKET],eax
	;
	Mov	edi,[ebp+DSEEK_FH]
	Mov	ebx,[ebp+DSEEK_DOSPACKET]
	Mov	ecx,[edi+FH_PORT]
	Mov	[ebx+DP_MESSAGE+MN_REPLYPORT],ecx
	Mov dword	[ebx+DP_TYPE],DOSPKT_SEEK
	Mov	[ebx+DP_FH],edi
	Mov	ecx,[ebp+DSEEK_OFFSET]
	Mov	[ebx+DP_ARG0],ecx
	Mov	ecx,[ebp+DSEEK_MODE]
	Mov	[ebx+DP_ARG1],ecx
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
	Mov	eax,[ebp+DSEEK_DOSPACKET]
	Push dword	[eax+DP_RES0]
	LIBCALL	FreeMem,ExecBase
	Pop	eax
	UNLINK	DSEEK_SIZE
	PopFD
	POPX	ebx,ecx,edx,ebp,edi
	Ret
