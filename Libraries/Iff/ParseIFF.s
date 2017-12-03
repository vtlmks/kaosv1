;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     ParseIFF.S V1.0.0
;
;     ParseIFF.
;

;
; Input:
;  eax = IFF
;  ebx = Parsemode
;
IFF_ParseIFF	PushFD
	PUSHX	ebx,ecx,edx,esi,edi,ebp
	Call	[ParseModes+ebx*4]
	POPX	ebx,ecx,edx,esi,edi,ebp
	PopFD
	Ret

ParseModes	Dd	ParseIFF_Scan
	Dd	ParseIFF_Step
	Dd	ParseIFF_Rawstep

ParseIFF_Scan
ParseIFF_Step	XOr	eax,eax
	Ret

; IFFPARSE_RAWSTEP
;
; Step to next chunk, add one if the current chunk is odd.
; read the first 8 chars from the new chunk and fill in a contextnode.

ParseIFF_Rawstep





	Cmp	edx,"FORM"
	Jne	.CheckCat
	Mov dword	[eax+IFF_TYPE],IFFTYPE_FORM
	XOr	eax,eax
	Ret

.CheckCat	Cmp	edx,"CAT "
	Jne	.CheckList
	Mov dword	[eax+IFF_TYPE],IFFTYPE_CAT
	XOr	eax,eax
	Ret

.CheckList	Cmp	edx,"LIST"
	Jne	.NoHit
	Mov dword	[eax+IFF_TYPE],IFFTYPE_LIST
	XOr	eax,eax
	Ret

.NoHit	Mov	eax,IFFERR_MANGLED
	Ret


	Dd	.RawReadHead
	Dd	.RawReadChunk

.RawReadHead
	Ret

.RawReadChunk
	Ret

	Dd	.FormChunk
	Dd	.CatChunk
	Dd	.ListChunk

.FormChunk
	Ret

.CatChunk
	Ret

.ListChunk
	Ret




