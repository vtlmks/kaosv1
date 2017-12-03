;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     CloneTaglist.I V1.0.0
;
;     Makes a copy of a TagList, remember to free with FreeTaglist.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; CloneTaglist
;
;Input:
;  eax - Pointer to taglist to be cloned.
;
;Output:
; eax - pointer to clone, or zero for failure
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UTIL_CloneTaglist	PUSHX	ebx,ecx,edx,edi,esi,ebp
	PushFD
	;
	Push	eax	; Count Entries
	XOr	ecx,ecx
.Loop	Mov	ebx,[eax]
	Test	ebx,ebx
	Jz	.EndFound
	Lea	eax,[eax+8]
	Lea	ecx,[ecx+8]
	Jmp	.Loop
	;--
.EndFound	Lea	ecx,[ecx+4]	; add for TAG_DONE
	Push	ecx
	Mov	eax,ecx
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Test	eax,eax
	Jz	.NoMem
	;--
	Pop	ecx
	Pop	esi
	Mov	edi,eax
	Cld
	Rep Movsb
	;--
.Done	PopFD
	POPX	ebx,ecx,edx,edi,esi,ebp
	Ret
	;--
.NoMem	Lea	esp,[esp+8]	; Account for previous pushes
	XOr	eax,eax
	Jmp	.Done

