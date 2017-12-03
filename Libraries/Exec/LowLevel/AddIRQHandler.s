;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AddIRQHandler.s V1.0.0
;
;     Add an IRQ handler to a specified IRQ.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Inputs:
;  eax - IRQ number (0-15), 0,1,2 and 8 are reserved.
;  ebx - Pointer to handler
;
; Output:
;  eax - Pointer to new IRQ entry or null for failure.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_AddIRQ	PushFD
	PUSHX	ebx,ecx

	Test	eax,eax
	Jz	.Failure
	Cmp	eax,1
	Je	.Failure
	Cmp	eax,2
	Je	.Failure
	Cmp	eax,8
	Je	.Failure

	Push	ebx
	Push dword	[IRQTable-12+eax*4]
	Mov	eax,UIRQ_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	ebx,eax
	Mov byte	[eax+LN_TYPE],NT_INTERRUPT
	Pop	eax
	Pop	ecx
	Mov	[ebx+UIRQ_HANDLER],ecx
	ADDTAIL

	Mov	eax,ebx
	POPX	ebx,ecx
	PopFD
	Ret

.Failure	XOr	eax,eax
	POPX	ebx,ecx
	PopFD
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
IRQTable	Dd	SysBase+SB_IRQ3
	Dd	SysBase+SB_IRQ4
	Dd	SysBase+SB_IRQ5
	Dd	SysBase+SB_IRQ6
	Dd	SysBase+SB_IRQ7
	Dd	0		; Reserved
	Dd	SysBase+SB_IRQ9
	Dd	SysBase+SB_IRQ10
	Dd	SysBase+SB_IRQ11
	Dd	SysBase+SB_IRQ12
	Dd	SysBase+SB_IRQ13
	Dd	SysBase+SB_IRQ14
	Dd	SysBase+SB_IRQ15
