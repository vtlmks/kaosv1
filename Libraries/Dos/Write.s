;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Write.s V1.0.0
;
;     Additional body description goes here.
;


	Struc DosWrite
DWRITE_FH	ResD	1	; Argument, Filehandler
DWRITE_LENGTH	ResD	1	; Argument, Length to write
DWRITE_BUFFER	ResD	1	; Argument, Buffer to write
	;
DWRITE_DOSPACKET	ResD	1	; DosPacket
DWRITE_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Write - Write a file
;
; Inputs:
;  eax - Filehandler, as returned by Open()
;  ebx - Length, in bytes
;  ecx - Buffer
;
; Output:
;  eax - Number of bytes written
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DOS_Write	PushFD
	PUSHX	ebx,ecx,ebp,edi
	;
	LINK	DWRITE_SIZE
	Mov	[ebp+DWRITE_FH],eax
	Mov	[ebp+DWRITE_LENGTH],ebx
	Mov	[ebp+DWRITE_BUFFER],ecx
	;
	Mov	eax,DP_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	[ebp+DWRITE_DOSPACKET],eax
	;
	Mov	edi,[ebp+DWRITE_FH]
	Mov	ebx,[ebp+DWRITE_DOSPACKET]
	Mov	ecx,[edi+FH_PORT]
	Mov	[ebx+DP_MESSAGE+MN_REPLYPORT],ecx
	Mov dword	[ebx+DP_TYPE],DOSPKT_WRITE
	Mov	[ebx+DP_FH],edi
	Mov	ecx,[ebp+DWRITE_LENGTH]
	Mov	[ebx+DP_ARG0],ecx
	Mov	ecx,[ebp+DWRITE_BUFFER]
	Mov	[edi+FH_BUFFER],ecx
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
	Mov	eax,[ebp+DWRITE_DOSPACKET]
	Push dword	[eax+DP_RES0]
	;
	LIBCALL	FreeMem,ExecBase
	Pop	eax
	UNLINK	DWRITE_SIZE
	PopFD
	POPX	ebx,ecx,ebp,edi
	Ret

