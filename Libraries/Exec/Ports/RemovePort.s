;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     RemovePort.s V1.0.0
;
;     Remove a message port from the public list.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;RemovePort
;
;Input:
;   eax - Pointer to port allocated with CreateMsgPort
;
;Output:
;  --
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_RemovePort	PushFD
	PUSHX	ebx

	Lea	ebx,[SysBase+SB_PortList]
	SPINLOCK	ebx

.L	NEXTNODE	ebx,.NoMore
	Cmp	[ebx+NP_PORTPOINTER],eax
	Jne	.L
	Mov	eax,ebx
	Push	eax
	REMOVE
	Pop	eax
	LIBCALL	FreeMem,ExecBase

	Lea	ebx,[SysBase+SB_PortList]
	SPINUNLOCK	ebx

.NoMore	POPX	ebx
	PopFD
	Ret
