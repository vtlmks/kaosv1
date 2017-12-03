;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     LoadSeg.s V1.0.0
;
;     LoadSeg - Load a segmented file.
;

	Struc SegmentList
SEGLIST:
SEGLIST_HUNKLIST	ResB	MLH_SIZE
SEGLIST_FH	ResD	1
SEGLIST_TEMPDATA	ResD	2	; Dont depend on values in this one...
SEGLIST_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Input:
;  eax = Filename
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DOS_LoadSeg	PushFD
	PUSHX	ebx,ecx,edx,esi,edi
	Push	eax
	Mov	eax,SEGLIST_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	edx,eax

	INITLIST	[edx+SEGLIST_HUNKLIST]

	Pop	eax
	Mov	ebx,OPENF_OLDFILE
	LIBCALL	Open,DosBase
	Test	eax,eax
	Jz	.NoFile
	Mov	[edx+SEGLIST_FH],eax
	;
	Call	CheckExecutable
;	Jnc	.Error

	;
	Call	ReadHunks
	Call	RelocateHunks

	;
.Error	Mov	eax,[edx+SEGLIST_FH]
	LIBCALL	Close,DosBase
	;
	Lea	eax,[edx+SEGLIST_HUNKLIST]
	;
	POPX	ebx,ecx,edx,esi,edi
	PopFD
	Ret

.NoFile	XOr	eax,eax
	POPX	ebx,ecx,edx,esi,edi
	PopFD
	Ret


;-   -  - -- ---=--=-==-===-========-===-==-=--=--- -- -  -   -
CheckExecutable	Mov	eax,[edx+SEGLIST_FH]
	Mov	ebx,4
	Lea	ecx,[edx+SEGLIST_TEMPDATA]
	LIBCALL	Read,DosBase
	;
	Mov	ecx,[ExeIdentifier]
	Cmp	[edx+SEGLIST_TEMPDATA],ecx
	Jne	.NoMatch
	;
	Stc
	Ret

.NoMatch	Clc
	Ret


;-   -  - -- ---=--=-==-===-========-===-==-=--=--- -- -  -   -
ReadHunks:
.Loop	Mov	eax,[edx+SEGLIST_FH]
	Mov	ebx,8
	Lea	ecx,[edx+SEGLIST_TEMPDATA]
	LIBCALL	Read,DosBase
	Test	eax,eax
	Jz near	.NoMoreHunks
	;
	Mov	ecx,[edx+SEGLIST_TEMPDATA+4]
	Lea	eax,[ecx+HUNK_SIZE]
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Test	eax,eax
	Jz	.NoMemory
	;
	Mov	ecx,[edx+SEGLIST_TEMPDATA]
	Mov	[eax+HUNK_TYPE],ecx
	Mov	ecx,[edx+SEGLIST_TEMPDATA+4]
	Mov	[eax+HUNK_LENGTH],ecx
	;
	Mov	ebx,eax
	Lea	eax,[edx+SEGLIST_HUNKLIST]
	ADDTAIL
	;
	Lea	ecx,[ebx+HUNK_BUFFER]
	Mov	eax,[edx+SEGLIST_FH]
	Mov	ebx,[edx+SEGLIST_TEMPDATA+4]
	LIBCALL	Read,DosBase
	Test	eax,eax
	Jz	.EndOfFile
	;
	Jmp	.Loop
	;
.NoMoreHunks	Ret


	; Tell the user that there were not enough memory to load the executable file
	; Then free all the loaded hunks and exit.

.NoMemory	Ret

.EndOfFile	Ret	; Unexpected end of file....

;-   -  - -- ---=--=-==-===-========-===-==-=--=--- -- -  -   -
RelocateHunks	Lea	ecx,[edx+SEGLIST_HUNKLIST]
.Loop	NEXTNODE	ecx,.NoMoreHunks
	Mov	eax,[ecx+HUNK_TYPE]
	PushAD
	Call	[HunkTypeTable-32004+eax*4]
	PopAD
	Jmp	.Loop
	;
.NoMoreHunks	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
LS_Header	Ret	; Flush

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
LS_Code	Ret	; Do nothing...

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
LS_Data	Ret	; Do Nothing

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
LS_BSS	Ret	; Do Nothing

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
LS_Reloc32	Lea	esi,[ecx+HUNK_BUFFER]
.Loop	Movzx	ebx,word [esi]
	Lea	edi,[edx+SEGLIST_HUNKLIST]
.GetSourceChunk	SUCC	edi
	Sub dword	ebx,byte 1
	Jnc	.GetSourceChunk
	Lea	eax,[edi+HUNK_BUFFER]
	Add	eax,[esi+4]	; Add delta...

	Movzx	ebx,word [esi+2]
	Lea	edi,[edx+SEGLIST_HUNKLIST]
.GetDestChunk	SUCC	edi
	Sub dword	ebx,byte 1
	Jnc	.GetDestChunk
	Lea	ebx,[edi+HUNK_BUFFER]
	Add	[eax],ebx

	Lea	esi,[esi+8]

	Lea	ebx,[ecx+HUNK_BUFFER]
	Add	ebx,[ecx+HUNK_LENGTH]
	Cmp	esi,ebx
	Jne	.Loop
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
LS_Reloc16	Ret	; Do Nothing

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
LS_Reloc8	Ret	; Do Nothing

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
LS_Symbol	Ret	; Flush

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
LS_Debug	Ret	; Flush

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
LS_Ext	Ret	; Do Something?!?!






;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
HunkTypeTable	Dd	LS_Header
	Dd	LS_Code
	Dd	LS_Data
	Dd	LS_BSS
	Dd	LS_Reloc32
	Dd	LS_Reloc16
	Dd	LS_Reloc8
	Dd	LS_Symbol
	Dd	LS_Debug
	Dd	LS_Ext


ExeIdentifier	Db	'MFS0'

