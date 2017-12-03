%ifndef Includes_Hardware_DMA_I
%define Includes_Hardware_DMA_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     DMA.I V1.0.1
;
;     Defines for using DMA (Direct Memory Access).
;




	Struc DMAEntry
	ResB	LN_SIZE
DMA_Status	ResD	1	; Status field, see below for definitions
DMA_Channel	ResD	1	; DMA channel
DMA_Owner	ResD	1	; Owner process
DMA_Buffer	ResD	1	; Pointer to DMA buffer 64k/128k for 8/16-bit channels
DMA_SIZE	EndStruc

	BITDEF	DMAS,ALLOCATED,0	; DMA channel is allocated; in use. DMA_Owner points to process owner.
	BITDEF	DMAS,CASCADE,1	; DMA channel is cascading, not allocatable



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -


DMA_IOBASE1	Equ	0x0	; Slave DMA (8-bit), channel 0-3
DMA_IOBASE2	Equ	0xc0	; Master DMA (16-bit), channel 4-7 (channel 4 = slave input)

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; DMA controller registers
;

DMA1REG_CMD	Equ	0x8	; Command register, write
DMA1REG_STAT	Equ	0x8	; Status regiser, read
DMA1REG_REQ	Equ	0x9	; Request regiser, write
DMA1REG_MASK	Equ	0xa	; Single-channel mask, write
DMA1REG_MODE	Equ	0xb	; Mode register, write
DMA1REG_CLEARFF	Equ	0xc	; Clear pointer flip-flop, write
DMA1REG_TEMPREG	Equ	0xd	; Temporary register, read
DMA1REG_RESET	Equ	0xd	; Master clear, write
DMA1REG_CLRMASK	Equ	0xe	; Clear mask
DMA1REG_MASKALL	Equ	0xf	; Mask, all-channels, write

DMA2REG_CMD	Equ	0xd0	; Command register, write
DMA2REG_STAT	Equ	0xd0	; Status regiser, read
DMA2REG_REQ	Equ	0xd2	; Request regiser, write
DMA2REG_MASK	Equ	0xd4	; Single-channel mask, write
DMA2REG_MODE	Equ	0xd6	; Mode register, write
DMA2REG_CLEARFF	Equ	0xd8	; Clear pointer flip-flop, write
DMA2REG_TEMPREG	Equ	0xda	; Temporary register, read
DMA2REG_RESET	Equ	0xda	; Master clear, write
DMA2REG_CLRMASK	Equ	0xdc	; Clear mask
DMA2REG_MASKALL	Equ	0xde	; Mask, all-channels, write


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; DMA address registers
;

DMAREG_ADDRESS0	Equ	0x00	; Address registers
DMAREG_ADDRESS1	Equ	0x02
DMAREG_ADDRESS2	Equ	0x04
DMAREG_ADDRESS3	Equ	0x06
	;
DMAREG_ADDRESS4	Equ	0xc0
DMAREG_ADDRESS5	Equ	0xc4
DMAREG_ADDRESS6	Equ	0xc8
DMAREG_ADDRESS7	Equ	0xcc

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; DMA count registers

DMAREG_COUNT0	Equ	0x01	; Count register
DMAREG_COUNT1	Equ	0x03
DMAREG_COUNT2	Equ	0x05
DMAREG_COUNT3	Equ	0x07
	;
DMAREG_COUNT4	Equ	0xc2
DMAREG_COUNT5	Equ	0xc6
DMAREG_COUNT6	Equ	0xca
DMAREG_COUNT7	Equ	0xce

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; DMA page registers
;

DMAREG_PAGE0	Equ	0x87	; Page register
DMAREG_PAGE1	Equ	0x83
DMAREG_PAGE2	Equ	0x81
DMAREG_PAGE3	Equ	0x82
	;
DMAREG_PAGE5	Equ	0x8b
DMAREG_PAGE6	Equ	0x89
DMAREG_PAGE7	Equ	0x8a

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; DMA modes
;

DMAMODE_READ	Equ	0x44	; I/O to memory (no autoinit, increment, single-mode)
DMAMODE_WRITE	Equ	0x48	; Memory to I/O (no autoinit, increment, single-mode)
DMAMODE_CASCADE	Equ	0xc0	; Pass thru DREQ->HRQ, DACK<-HLDA only

DMA_AUTOINIT	Equ	0x10	; Autoinit


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
