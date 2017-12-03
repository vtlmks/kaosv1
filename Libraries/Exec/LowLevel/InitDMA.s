;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     InitDMA.s V1.0.0
;



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; InitDMA -- Initialize an allocated DMA channel
;
;  Inputs:
;
;  eax = Allocated DMA channel as returned by AllocDMA()
;  ebx = Length in bytes-1, a value of zero gives 1 byte and 0xffff thus gives 65536 bytes.
;  ecx = Mode (read, write, ...)
;
;  Output:
;
;  eax = Zero for success, non-zero for failure.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_InitDMA	PushFD
	PushAD
	;
	Mov	edi,[ebp+DMA_Channel]
	Mov	ebp,eax
	Cmp	edi,4
	Ja	.DMA16bit
	Mov	al,4
	Add	al,[ebp+DMA_Channel]
	Out	DMA1REG_MASK,al			; Mask DMA channel
	;
	XOr	al,al
	Out	DMA1REG_CLEARFF,al		; Clear byte
	;
	Mov	al,cl
	Add	al,[ebp+DMA_Channel]
	Out	DMA1REG_MODE,al			; Set DMA mode
	;
	Mov	eax,[ebp+DMA_Buffer]
	Movzx	dx,byte [.DMAAddress+edi]
	Out	dx,al			; Low byte of 16-bit address
	Mov	al,ah
	Out	dx,al			; High byte of 16-bit address
	;
	Movzx	dx,byte [.DMALength+edi]
	Mov	al,bl
	Out	dx,al			; Low byte of length
	Mov	al,bh
	Out	dx,al			; High byte of length
	;
	Mov	eax,[ebp+DMA_Buffer]
	Shr	eax,16
	Movzx	dx,byte [.DMALowerPage+edi]
	Out	dx,al			; Page address of address
	;
	Mov	al,[ebp+DMA_Channel]
	Mov	dx,DMA1REG_MASK
	Out	dx,al			; Unmask DMA channel
	PopAD
	PopFD
	Ret
	;--
	;
	; setup 16-bit channel 5-7
	;
.DMA16bit	Mov	al,[ebp+DMA_Channel]
	Out	DMA2REG_MASK,al			; Mask DMA channel
	;
	XOr	al,al
	Out	DMA2REG_CLEARFF,al		; Clear byte
	;
	Mov	al,[ebp+DMA_Channel]
	Sub	al,4
	Add	al,cl
	Out	DMA2REG_MODE,al			; Set DMA mode
	;
	Mov	eax,[ebp+DMA_Buffer]
	Movzx	dx,byte [.DMAAddress+edi]
	Out	dx,al			; Low byte of 16-bit address
	Mov	al,ah
	Out	dx,al			; High byte of 16-bit address
	;
	Movzx	dx,byte [.DMALength+edi]
	Mov	al,bl
	Out	dx,al			; Low byte of length
	Mov	al,bh
	Out	dx,al			; High byte of length
	;
	Mov	eax,[ebp+DMA_Buffer]
	Shr	eax,16
	Movzx	dx,byte [.DMALowerPage+edi]
	Out	dx,al			; Page address of address
	;
	Mov	al,[ebp+DMA_Channel]
	And	al,0x3
	Mov	dx,DMA2REG_MASK
	Out	dx,al			; Unmask DMA channel
	;
	PopAD
	PopFD
	Ret




.DMAAddress	Db	DMAREG_ADDRESS0	; DMA base addresses
	Db	DMAREG_ADDRESS1
	Db	DMAREG_ADDRESS2
	Db	DMAREG_ADDRESS3
	Db	DMAREG_ADDRESS4
	Db	DMAREG_ADDRESS5
	Db	DMAREG_ADDRESS6
	Db	DMAREG_ADDRESS7

.DMALength	Db	DMAREG_COUNT0	; DMA count/length registers
	Db	DMAREG_COUNT1
	Db	DMAREG_COUNT2
	Db	DMAREG_COUNT3
	Db	DMAREG_COUNT4
	Db	DMAREG_COUNT5
	Db	DMAREG_COUNT6
	Db	DMAREG_COUNT7

.DMALowerPage	Db	DMAREG_PAGE0	; DMA page registers
	Db	DMAREG_PAGE1
	Db	DMAREG_PAGE2
	Db	DMAREG_PAGE3
	Db	0
	Db	DMAREG_PAGE5
	Db	DMAREG_PAGE6
	Db	DMAREG_PAGE7




