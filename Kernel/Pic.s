;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Pic.I V1.0.0
;
;     PIC 8259 supportcode.
;
;
; This file contains all the code for initializing, enabling and disabling
; Interrupt Requests (IRQ's) within KAOS. This is done by programming the 8259.
;
; MaskIRQ	- Interrupt to mask
; UnMaskIRQ	- Interrupt to unmask
;

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; MaskIRQ() -- Mask specified IRQ number in eax
;
; Inputs:
; eax = Interrupt to mask
;
MaskIRQ	PushFD
	PUSHX	eax,ecx
	Cli
	Mov	ecx,eax	; ecx=IRQ number
	Mov	eax,1
	And	ecx,0xf	; 0-15
	Shl	eax,cl
	And	al,al
	Jz	.IRQ2
	Mov	ah,al
	In	al,PIC_M+1
	Or	al,ah
	Out	PIC_M+1,al
	Jmp	.IRQDone
.IRQ2	In	al,PIC_S+1
	Or	al,ah
	Out	PIC_S+1,al
.IRQDone	POPX	eax,ecx
	PopFD
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; UnMaskIRQ() -- UnMask specified IRQ number in eax
;
; Input:
; eax = Interrupt to unmask
;
UnMaskIRQ	PushFD
	PUSHX	eax,ecx
	Cli
	Mov	ecx,eax	; ecx=IRQ number
	Mov	eax,1
	And	ecx,0xf	; 0-15
	Shl	eax,cl
	And	al,al
	Jz	.IRQ2
	Mov	ah,al
	In	al,PIC_M+1
	Not	ah
	And	al,ah
	Out	PIC_M+1,al
	Jmp	.IRQDone
.IRQ2	In	al,PIC_S+1
	Not	ah
	And	al,ah
	Out	PIC_S+1,al
.IRQDone	POPX	eax,ecx
	Popfd
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; SetupIRQs -- Setups all public IRQ's (unmasks them).
;
SetupIRQs	Lea	esi,[PublicIRQTable]
.L	Lodsd
	Test	eax,eax
	Jz	.Done
	Call	UnMaskIRQ
	Jmp	.L
.Done	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PublicIRQTable	Dd	3
	Dd	4
	Dd	5
	Dd	6
	Dd	7
	Dd	9
	Dd	10
	Dd	11
	Dd	12
	Dd	13
	Dd	14
	Dd	15
	Dd	0
