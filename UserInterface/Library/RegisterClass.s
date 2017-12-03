;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     RegisterObject.s V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc	RegisterObject
UIRO_Class	ResD	1	; Object that wants to register.
UIRO_ClassNode	ResD	1	; Object node.
UIRO_ClassID	ResD	1	; ObjectID
UIRO_ClassList	ResD	1	; Pointer to the main Objectlist
UIRO_SIZE	EndStruc

	Struc	ObjectNode
	ResB	MLN_SIZE
ON_Class	ResD	1	; Object
ON_ClassID	ResD	1	; Object ID
ON_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UI_RegisterClass	PushFD
	PushAD
	LINK	UIRO_SIZE
	Mov	[ebp+UIRO_Class],eax

	Mov	eax,ON_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Test	eax,eax
	Jz	.NoMemory

	Mov	ebx,[UIMemoryBase]
	Inc dword	[ebx+UIH_ClassID]
	Push dword	[ebx+UIH_ClassID]
	Push dword	[ebx+UIH_ClassID]
	Push dword	[ebp+UIRO_Class]
	Pop dword	[eax+ON_Class]
	Pop dword	[eax+ON_ClassID]
	Pop dword	[ebp+UIRO_ClassID]

	Lea	ecx,[ebx+UIH_ClassList]
	Mov	[ebp+UIRO_ClassList],ecx

	Mov	ebx,eax
	Mov	eax,[ebp+UIRO_ClassList]
	SPINLOCK	eax
	Push	eax
	ADDTAIL
	Pop	eax
	SPINUNLOCK	eax

.NoMemory	Mov	eax,[ebp+UIRO_ClassID]
	UNLINK	UIRO_SIZE
	RETURN	eax
	PopAD
	PopFD
	Ret
