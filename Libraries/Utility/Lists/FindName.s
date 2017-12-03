;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     FindName.s V1.0.0
;
;     Find a node by name in a linked list.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;FindName
;
;Input:
;  eax - Pointer to string to search for.
;  ebx - Pointer to list.
;
;Output:
;  eax - pointer to node, or null for failure.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UTIL_FindName	PUSHX	ebx,ecx,edx
	PushFD
	Mov	ecx,ebx
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
	POPX	ebx,ecx,edx
	Ret
	;--
.Fail	XOr	eax,eax
	Jmp	.Exit
