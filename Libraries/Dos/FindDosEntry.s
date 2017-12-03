;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     FindDosEntry.s V1.0.0
;
;     Find an entry in the doslist.
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;FindDosEntry
;
;Input:
;  eax - Pointer to DosEntry to search for, without colon.
;
;Output:
;  eax - pointer to node, or null if DosEntry does not exist.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DOS_FindDosEntry	PUSHX	ebx,ecx,edx,ebp
	PushFD
	Lea	ecx,[SysBase+SB_DosList]
	;
.Loop	NEXTNODE	ecx,.Fail
	Push	eax
	Mov	ebx,[ecx+LN_NAME]
	LIBCALL	StriCmp,UteBase
	Test	eax,eax
	Pop	eax
	Jz	.Found
	Jmp	.Loop
	;
.Found	Mov	eax,ecx
	;
.Exit	PopFD
	POPX	ebx,ecx,edx,ebp
	Ret
	;--
.Fail	XOr	eax,eax
	Jmp	.Exit
