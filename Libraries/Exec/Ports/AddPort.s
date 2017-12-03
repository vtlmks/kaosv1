;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AddPort.s V1.0.0
;
;     Add a message port to the public message list.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; AddPort
;
;Input:
;  eax - Pointer to port allocated with CreateMsgPort
;  ebx - Pointer to a name for the port.
;
;Output:
;  eax - null for failure, everything else indicates success.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc AddPort
ADP_NAME	ResD	1
ADP_PORTPOINTER	ResD	1
ADP_SIZE	EndStruc

	Struc NamedPort
NP_NODE	ResB	LN_SIZE
NP_PORTPOINTER	ResD	1
NP_NAME	ResB	34
NP_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_AddPort	PushFD
	PushAD
	LINK	ADP_SIZE
	Mov	[ebp+ADP_PORTPOINTER],eax
	Mov	[ebp+ADP_NAME],ebx
	;
	Mov	eax,ebx
	Lea	ebx,[SysBase+SB_PortList]
	LIBCALL	FindName,UteBase
	Test	eax,eax
	Jnz	.Exit
	;
	Mov	eax,NP_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Test	eax,eax
	Jz	.Exit
	;
	Mov	ebx,[ebp+ADP_PORTPOINTER]
	Mov	[eax+NP_PORTPOINTER],ebx
	Mov	esi,[ebp+ADP_NAME]
	Lea	edi,[eax+NP_NAME]
	Mov byte	[eax+LN_TYPE],NT_MSGPORT
	Mov	[eax+LN_NAME],edi
	Mov byte	[eax+LN_PRI],0		; CHANGE
	Mov	ecx,32
	Rep Movsb
	;
	Mov	ebx,eax
	Lea	eax,[SysBase+SB_PortList]
	SPINLOCK	eax
	Push	eax
	ADDTAIL			; Change to a AddNodeSorted.
	Pop	eax
	SPINUNLOCK	eax
	;
.Exit	UNLINK	ADP_SIZE
	RETURN	eax
	PopAD
	PopFD
	Ret
