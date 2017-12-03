;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Open.s V1.0.1
;
;     Open files for reading and/or writing. Files may either
;     be open relative to the current path or by defining an
;     absolute path with a device string, i.e. "System:NiceFiles/file".
;
;     Currentpath is however o'root currently, so "mydir/myseconddir/file"
;     will resolve to "system:mydir/myseconddir/file".
;


	Struc DosOpen
DOPEN_FILENAME	ResD	1	; Filename to open, including path
DOPEN_MODE	ResD	1	; Mode to open file with
DOPEN_FILEHANDLE	ResD	1
DOPEN_DOSPACKET	ResD	1
DOPEN_DOSENTRY	ResD	1
DOPEN_PORT	ResD	1
DOPEN_FSHPORT	ResD	1
DOPEN_DEVICESTR	ResB	64	; Device string, e.g. SYS:
DOPEN_TEMPDIR	ResB	128	; Tempdirectory buffer, used for assigns
DOPEN_FILEPATH	ResB	128	; Temppath
DOPEN_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Open - Open a file
;
; Inputs:
;  eax - Filename, including path.
;  ebx - Mode
;
; Output:
;  eax - Pointer to FH or null for failure.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DOS_Open	PUSHX	ebx,ecx,edx,edi,esi,ebp
	PushFD
	LINK	DOPEN_SIZE
	Cld
	Mov	[ebp+DOPEN_FILENAME],eax
	Mov	[ebp+DOPEN_MODE],ebx


	; REMOVE ALL BELOW =========================== including me...
;;;;;;;	Lea	eax,[FileN]
	Mov	ebx,29829
	; REMOVE ALL ABOVE =========================== including me...

	Mov	eax,FH_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	[ebp+DOPEN_FILEHANDLE],eax


	Call	DO_FindDosEntry
	Jc	.Failure
	Call	DO_SendPacket

	Mov	eax,[ebp+DOPEN_FILEHANDLE]
	Cmp dword	[eax+FH_CURRENTBLOCK],-1
	Je	.FileNotFound
	;
.Done	UNLINK	DOPEN_SIZE
	PopFD
	POPX	ebx,ecx,edx,edi,esi,ebp
	Ret


.FileNotFound	Lea	eax,[FSFailureTxt]
	Int	0xff

.Failure	Mov	eax,[ebp+DOPEN_FILEHANDLE]
	LIBCALL	FreeMem,ExecBase
	XOr	eax,eax
	Jmp	.Done


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Lookup the dosentry, if one was defined by a device string, or default
; to the process current dir.
;


DO_FindDosEntry	Mov	esi,[ebp+DOPEN_FILENAME]
.L	Lodsb
	Test	al,al
	Jz	.CurrentDir
	Cmp	al,":"
	Je	.Found
	Jmp	.L
.Found	Mov	esi,[ebp+DOPEN_FILENAME]
	Lea	edi,[ebp+DOPEN_DEVICESTR]
.L1	Lodsb
	Cmp	al,":"
	Je	.NoMore
	Stosb
	Jmp	.L1
.NoMore	XOr	al,al
	Stosb
	;
	Lea	edi,[ebp+DOPEN_FILEPATH]	; Copy remains of the path after the volume delimiter
.FL	Lodsb
	Stosb
	Test	al,al
	Jnz	.FL
	;--
	Lea	eax,[ebp+DOPEN_DEVICESTR]
	LIBCALL	FindDosEntry,DosBase
	Test	eax,eax
	Jz	.Failure


	;---

	Cmp dword	[eax+DE_TYPE],DLT_ASSIGN
	Je	OpenAsAssign



	;--

	;
.NoAssign	Mov	[ebp+DOPEN_DOSENTRY],eax
	Mov	ecx,[ebp+DOPEN_FILEHANDLE]
	Mov	[ecx+FH_DOSENTRY],eax
	Clc
	Ret
	;
.Failure	Lea	eax,[NoDosEntryTxt]
	Int	0xff
	Stc
	Ret


	;--
	; since we don't have a process CurrentDir or such at the moment, non device
	; specific Open() calls are routed to the root of System: ..
	;
.CurrentDir	Lea	eax,[PartN]		; Come forward o'root
	LIBCALL	FindDosEntry,DosBase
	Mov	[ebp+DOPEN_DOSENTRY],eax
	Mov	ecx,[ebp+DOPEN_FILEHANDLE]
	Mov	[ecx+FH_DOSENTRY],eax
	Clc
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
OpenAsAssign	Mov	edx,eax

	Mov	esi,[edx+DEA_DOSENTRY]
	Mov	esi,[esi+LN_NAME]
	Lea	edi,[ebp+DOPEN_TEMPDIR]
.L	Lodsb
	Stosb
	Test	al,al
	Jnz	.L
	Mov byte	[edi-1],":"
	;
	Mov	esi,[edx+DEA_PATH]
.L1	Lodsb
	Stosb
	Test	al,al
	Jnz	.L1

	Lea	eax,[ebp+DOPEN_TEMPDIR]
	Lea	ebx,[ebp+DOPEN_FILEPATH]
	LIBCALL	AddPart,DosBase
	Lea	esi,[ebp+DOPEN_TEMPDIR]
.L2	Lodsb
	Cmp	al,":"
	Jne	.L2
	Mov	[ebp+DOPEN_FILENAME],esi	; Path and filename, excluding volumename
	;-
	Mov	edx,[edx+DEA_DOSENTRY]
	Mov	[ebp+DOPEN_DOSENTRY],edx
	Mov	ecx,[ebp+DOPEN_FILEHANDLE]
	Mov	[ecx+FH_DOSENTRY],edx
	Clc
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
OpenAsCurrentDir	Ret





;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Transmit packet to the filesystem that is bound to the dosentry.
;

DO_SendPacket	Mov	eax,DP_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	[ebp+DOPEN_DOSPACKET],eax
	;
	LIBCALL	CreateMsgPort,ExecBase	; is freed by Close(FH);
	Mov	[ebp+DOPEN_PORT],eax
	Mov	ecx,[ebp+DOPEN_FILEHANDLE]
	Mov	[ecx+FH_PORT],eax
	;
	Mov	ebx,[ebp+DOPEN_DOSPACKET]
	Mov	ecx,[ebp+DOPEN_PORT]
	Mov	[ebx+DP_MESSAGE+MN_REPLYPORT],ecx
	Mov dword	[ebx+DP_TYPE],DOSPKT_OPEN
	Mov	ecx,[ebp+DOPEN_FILEHANDLE]
	Mov	[ebx+DP_FH],ecx
	Mov	ecx,[ebp+DOPEN_FILENAME]
	Mov	[ebx+DP_ARG0],ecx
	Mov	ecx,[ebp+DOPEN_MODE]
	Mov	[ebx+DP_ARG1],ecx
	;
	Mov	eax,[ebp+DOPEN_DOSENTRY]
	Mov	eax,[eax+DE_PORT]
	LIBCALL	PutMsg,ExecBase

	Mov	eax,[ebp+DOPEN_PORT]
	Mov	ebx,MPSELECT_SYSTEMSET
	LIBCALL	SelectMsgPort,ExecBase
	LIBCALL	Wait,ExecBase
	LIBCALL	GetMsg,ExecBase
	Mov	ebx,MPSELECT_SYSTEMRESET
	LIBCALL	SelectMsgPort,ExecBase
	;
	Mov	eax,[ebp+DOPEN_DOSPACKET]
	LIBCALL	FreeMem,ExecBase
	Ret


FSFailureTxt	Db	0xa,'Filesystem could not find file',0xa,0
NoDosEntryTxt	Db	0xa,'No dosentry was found',0xa,0
PartN	Db	'System',0

