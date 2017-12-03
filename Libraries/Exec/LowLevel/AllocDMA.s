;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AllocDMA.s V1.0.0
;
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; AllocDMA -- Allocate a 8-bit or 16-bit DMA channel
;
;  Inputs:
;
;  eax = DMA channel, 0-3 for 8-bit, 5-7 for 16-bit
;
;  Output:
;
;  eax = DMA allocation or null for failure.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_AllocDMA	PushFD
	PUSHX	ecx,esi
	Cmp	eax,4
	Je	.Failure
	Cmp	eax,7
	Ja	.Failure

	Mov	ecx,eax
	Lea	esi,[SysBase+SB_DMAList]
.L	SUCC	esi
	Cmp	[esi+DMA_Channel],ecx
	Jne	.L


	Bt dword	[esi+DMA_Status],DMASB_ALLOCATED
	Jc	.Failure
	;
	XOr	eax,eax
	LIBCALL	FindProcess,ExecBase
	Mov	[esi+DMA_Owner],eax
	Mov	eax,esi
	POPX	ecx,esi
	PopFD
	Ret

.Failure	XOr	eax,eax
	POPX	ecx,esi
	PopFD
	Ret

