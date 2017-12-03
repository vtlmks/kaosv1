;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AddDosEntry.s V1.0.0
;
;     Create and add a new entry to the doslist.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; AddDosEntry -- Add an entry to the doslist
;
; Input:
;  eax - type
;  ebx - taglist
;
; Output:
;  eax - New entry or null for failure
;
;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

	Struc AddDosEntry
DOSAD_Type	ResD	1	; Entry type
DOSAD_TagList	ResD	1	; Entry taglist
DOSAD_Name	ResD	1	; Name string
DOSAD_NamePtr	ResD	1	; Pointer to name in new entry
DOSAD_DevName	ResD	1
DOSAD_HandlerName	ResD	1
DOSAD_SIZE	EndStruc




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DOS_AddDosEntry	PushFD
	PushAD
	LINK	DOSAD_SIZE
	Mov	[ebp+DOSAD_Type],eax
	Mov	[ebp+DOSAD_TagList],ebx

	Mov	eax,1000
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	edx,eax
	;
	Mov	eax,DL_NAME
	Mov	ebx,[ebp+DOSAD_TagList]
	LIBCALL	GetTagData,UteBase
	Test	eax,eax
	Jz	.Failure
	Mov	[ebp+DOSAD_Name],eax
	Lea	ebx,[SysBase+SB_DosList]	; Check for dupes in DosList
	LIBCALL	FindName,UteBase
	Test	eax,eax
	Jnz	.Failure
	;
	Mov	esi,[ebp+DOSAD_TagList]
	Lea	edi,[edx+DE_SIZE]		; Start of taglist data
	Cld
.L	Movsd			; Copy taglist
	Movsd
	Cmp dword	[esi],0
	Jnz	.L
	Lea	edi,[edi+4]		; Copy to end of taglist, take care for TAG_DONE
	;
	Mov	eax,[ebp+DOSAD_Name]
	Mov	ebx,[ebp+DOSAD_Type]
	Mov	[edx+LN_NAME],eax		; hurr hurr... fix this asap.. =))..
	Mov	[edx+DE_TYPE],ebx
	Lea	eax,[SysBase+SB_DosList]
	Mov	ebx,edx
	ADDTAIL
	;
.Done	UNLINK	DOSAD_SIZE
	RETURN	edx
	PopAD
	PopFD
	Ret

.Failure	UNLINK	DOSAD_SIZE
	RETURN	0
	PopAD
	PopFD
	Ret
