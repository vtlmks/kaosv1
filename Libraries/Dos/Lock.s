;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Lock.s V1.0.0
;
;
;     Locks a file or directory for read/write


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Inputs:
;
;  eax = path		; Relative or absolute path
;  ebx = lock mode	; LOCKF_READ|LOCKF_WRITE
;
; Output:
;
;  eax = pointer to lock or null for failure
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc DOSLockStruct
DOSL_LockPath	ResD	1	; Pointer to path of file or directory to lock
DOSL_LockMode	ResD	1	; Mode of lock operation
DOSL_LockMem	ResD	1	; Lock node memory
DOSL_DosEntry	ResD	1	; Pointer to the dosentry
DOSL_PacketMem	ResD	1	; Temporary packet memory
DOSL_PacketPort	ResD	1	; Temporary packet port
DOSL_NewLockPath	ResB	192	; The new path to the lock of the file or directory to be locked
DOSL_VolumeN	ResB	16	; Temporary volume name for DosEntry extraction
DOSL_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DOS_Lock	PushFD
	PushAD
	LINK	DOSL_SIZE
	Cld
	Mov	[ebp+DOSL_LockPath],eax
	Mov	[ebp+DOSL_LockMode],ebx

	Mov	eax,LOCK_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	[ebp+DOSL_LockMem],eax

	Call	DOSL_GetPath
	Call	DOSL_GetDosEntry
	Jc	.Failure
	Call	DOSL_SendPacket
	Jc	.Failure

	Mov	eax,[ebp+DOSL_LockMem]
	UNLINK	DOSL_SIZE
	RETURN	eax
	PopAD
	PopFD
	Ret

	;--

.Failure	Mov	eax,[ebp+DOSL_LockMem]
	LIBCALL	FreeMem,ExecBase
	UNLINK	DOSL_SIZE
	RETURN	0
	PopAD
	PopFD
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Extract either an absolute path for the lock or build one from the relative
; path we got..
;
DOSL_GetPath	Mov	esi,[ebp+DOSL_LockPath]
	Lea	edi,[ebp+DOSL_NewLockPath]
.L	Lodsb
	Stosb
	Test	al,al
	Jz	.Relative
	Cmp	al,":"
	Jne	.L
	;
.L1	Lodsb			; Path is absolute, copy rest of it aswell
	Stosb
	Test	al,al
	Jnz	.L1
	Ret

.Relative	Ret	; todo: get currentdir and mangle it with the DOSL_LockPath

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Get matching dosentry for the path
;
DOSL_GetDosEntry	Lea	esi,[ebp+DOSL_NewLockPath]
	Lea	edi,[ebp+DOSL_VolumeN]
.L	Lodsb
	Stosb
	Cmp	al,":"
	Jne	.L
	Mov byte	[edi-2],0		; Terminate and exclude volume delimiter
	;
	Mov	edi,[ebp+DOSL_LockMem]
	Mov	eax,[ebp+DOSL_LockMode]
	Mov	[edi+LOCK_MODE],eax	; Save lockmode in lockhandler
	Lea	edi,[edi+LOCK_PATH]	; Save lockpath in lockhandler aswell
.L1	Lodsb
	Stosb
	Test	al,al
	Jnz	.L1
	;
	Lea	eax,[ebp+DOSL_VolumeN]
	LIBCALL	FindDosEntry,DosBase
	Mov	[ebp+DOSL_DosEntry],eax
	Test	eax,eax
	Jz	.Failure
	Mov	edi,[ebp+DOSL_LockMem]
	Mov	[edi+LOCK_DOSENTRY],eax	; Save dosentry in lockhandler
	Clc
	Ret
.Failure	Stc
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DOSL_SendPacket	Mov	eax,DP_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	[ebp+DOSL_PacketMem],eax
	;
	LIBCALL	CreateMsgPort,ExecBase
	Mov	[ebp+DOSL_PacketPort],eax
	;
	Mov	ebx,[ebp+DOSL_PacketMem]
	Mov	ecx,[ebp+DOSL_PacketPort]
	Mov	[ebx+DP_MESSAGE+MN_REPLYPORT],ecx
	Mov dword	[ebx+DP_TYPE],DOSPKT_LOCK
	Mov	ecx,[ebp+DOSL_LockMem]	; Lock handler is provided as an argument to FS
	Mov	[ebx+DP_ARG0],ecx
	;
	Mov	eax,[ebp+DOSL_DosEntry]
	Mov	eax,[eax+DE_PORT]
	LIBCALL	PutMsg,ExecBase
	Mov	eax,[ebp+DOSL_PacketPort]
	Mov	ebx,MPSELECT_SYSTEMSET
	LIBCALL	SelectMsgPort,ExecBase
	LIBCALL	Wait,ExecBase
	LIBCALL	GetMsg,ExecBase
	Mov	ebx,MPSELECT_SYSTEMRESET
	LIBCALL	SelectMsgPort,ExecBase
	;
	Mov	ebx,[eax+DP_RES0]		; Save results, since we FreeMem

	Mov	eax,[ebp+DOSL_PacketMem]
	LIBCALL	FreeMem,ExecBase
	Mov	eax,[ebp+DOSL_PacketPort]
	LIBCALL	DeleteMsgPort,ExecBase

	Test	ebx,ebx		; Check DP_RES0 for any errors that the filesystem might return
	Jnz	.Failure

	Lea	eax,[SysBase+SB_LockList]
	Mov	ebx,[ebp+DOSL_LockMem]	; Add lock entry to system locklist
	ADDTAIL
	Clc
	Ret

.Failure	Stc
	Ret

