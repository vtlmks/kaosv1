;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AssignPath.s V1.0.0
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; AssignPath - Create an assign to a path
;
; Inputs:
;  eax - Assignname without trailing colon
;  ebx - Path
;
; Output:
;  eax - Null for success or errorcode for failure, see below..
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -


	Struc DosAssignStruc
DAS_AssignName	ResD	1	; Assign name
DAS_AssignPath	ResD	1	; Path to assign
DAS_DosEntry	ResD	1	; Dosentry for assign
DAS_AssignVolume	ResB	32	; Temp volume buffer
DAS_AssignTemp	ResB	192	; Temp buffer for assign path
DAS_AssignSplit	ResB	192	; Remains of the path, without volume and delimiter
DAS_ReturnCode	ResD	1	; Assign node to return
DAS_SIZE	EndStruc


ASSIGNERR_DUPE	Equ	-1	; Duplicate found or invalid assignname
ASSIGNERR_NODOSENTRY Equ	-2	; No dosentry matching assignpath
ASSIGNERR_FAILURE	Equ	-3	; General failure

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DOS_AssignPath	PushFD
	PushAD
	LINK	DAS_SIZE
	Cld
	Mov	[ebp+DAS_AssignName],eax
	Mov	[ebp+DAS_AssignPath],ebx
	;--
	Call	DA_FindDosEntry
	Jc	.Failure
	Call	DA_FindDupe
	Jc	.Failure
	Call	DA_AssignPath
	;--
.Failure	Mov	eax,[ebp+DAS_ReturnCode]
	UNLINK	DAS_SIZE
	RETURN	eax
	PopAD
	PopFD
	Ret


;
; todo: this won't try Lock()'ing anything, it will just have a smile
; and ADDTAIL whatever you tell it to, just make sure there is a DosEntry
; available for the assign otherwise this will return with a NODOSENTRY error.
;
;



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Find the dosentry for the assign
;
DA_FindDosEntry	Mov	esi,[ebp+DAS_AssignPath]
	Lea	edi,[ebp+DAS_AssignVolume]
.L	Lodsb
	Stosb
	Test	al,al
	Jz	.Failure
	Cmp	al,":"
	Jne	.L
	Mov byte	[edi-1],0
	;
	Lea	edi,[ebp+DAS_AssignSplit]	; Copy the remains of the path
.L1	Lodsb
	Stosb
	Test	al,al
	Jnz	.L1
	;
	Lea	eax,[ebp+DAS_AssignVolume]
	LIBCALL	FindDosEntry,DosBase
	Test	eax,eax
	Jz	.Failure
	Cmp dword	[eax+DE_TYPE],DLT_VOLUME	; We don't support assigning assigns to other assigns
	Jne	.Failure		; as of yet..
	Mov	[ebp+DAS_DosEntry],eax
	Clc
	Ret
	;
.Failure	Mov dword	[ebp+DAS_ReturnCode],ASSIGNERR_NODOSENTRY
	Stc
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Check if a duplicate DosEntry already exists, if so - fail
;
DA_FindDupe	Mov	esi,[ebp+DAS_AssignName]
	Lea	edi,[ebp+DAS_AssignTemp]
.L	Lodsb
	Stosb
	Test	al,al
	Jnz	.L
	;
	Lea	eax,[ebp+DAS_AssignTemp]
	LIBCALL	FindDosEntry,DosBase
	Test	eax,eax
	Jnz	.Failure
	Clc
	Ret
	;
.Failure	Mov dword	[ebp+DAS_ReturnCode],ASSIGNERR_DUPE
	Stc
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DA_AssignPath	Mov	eax,DEA_SIZE+500
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	edx,eax
	Mov dword	[edx+DE_TYPE],DLT_ASSIGN	; DosEntry type assign
	Mov	eax,[ebp+DAS_DosEntry]
	Mov	[edx+DEA_DOSENTRY],eax	; DosEntry data points to a volume dosentry
	;
	Lea	esi,[ebp+DAS_AssignTemp]
	Lea	edi,[edx+DEA_SIZE]
	Mov	[edx+LN_NAME],edi		; Setup pointer for LN_NAME, copy it after the struct
.L	Lodsb			; Copy the path, excluding volume and it's delimiter
	Stosb
	Test	al,al
	Jnz	.L
	;
	Mov	[edx+DEA_PATH],edi
	Lea	esi,[ebp+DAS_AssignSplit]
.L1	Lodsb
	Stosb
	Test	al,al
	Jnz	.L1
	;
	INITLIST	[edx+DEA_ADDLIST]
	;
	Lea	eax,[SysBase+SB_DosList]
	Mov	ebx,edx
	ADDTAIL			; Add new entry to doslist
	;
	Mov dword	[ebp+DAS_ReturnCode],0
	Ret

