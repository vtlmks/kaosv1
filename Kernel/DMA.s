;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     DMA.s V1.0.1
;
;     Initializes the DMA list, sets up buffers and masks channel 4
;     as cascade and allocated.
;
;     The code for allocating channels, initiating transfers and freeing
;     channels are since 1.0.1 part of exec.library. AllocDMA(), InitDMA()
;     and FreeDMA() will handle everything from now on.
;
;

; DMA area 0x10000-0x80000, 7x64kb buffers..


DMA_BUFFERSIZE	Equ	0x10000	; Buffersize, 64k
DMA_BUFFEROFFSET	Equ	0x10000	; First buffer

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
InitDMA	Ret


	XOr	edi,edi		; Channel counter, 0-7
	Mov	esi,DMA_BUFFEROFFSET	; First DMA buffer address
	;
.L	Mov	eax,DMA_SIZE
	Mov	ebx,MEMF_NOKEY
	LIBCALL	AllocMem,ExecBase
	Mov	ebx,eax
	Lea	eax,[SysBase+SB_DMAList]
	Mov	[ebx+DMA_Channel],edi
	Cmp	edi,4
	Je near	.Cascade
	;
	Mov	[ebx+DMA_Buffer],esi
	ADDTAIL
	Add	esi,DMA_BUFFERSIZE
	Cmp	edi,8
	Jne near	.L
	Ret
	;-
.Cascade	Mov dword	[ebx+DMA_Status],DMASF_ALLOCATED|DMASF_CASCADE
	ADDTAIL
	Jmp near	.L


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; items below this line are obsolete and will be removed asap, they
; now remain in the exec.library as AllocDMA, FreeDMA and InitDMA instead.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -






;
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;; DMASetMode - Set the DMA channel mode
;;
;; Input:
;;  ah - DMA Mode
;;  al - DMA Channel
;;
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;	Align	16
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;DMASetMode	PUSHX	ax,ebx,dx
;	XOr	edx,edx
;	Movzx	ebx,ax
;	Shr	bx,8
;	And	bx,7
;	Mov	dl,[DMAWriteMode+ebx]	; DMA port
;	And	ah,3
;	Add	al,ah
;	Out	dx,al		; Set DMA mode
;	POPX	ax,ebx,dx
;	Ret
;
;
;
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;; DMAClearChannel - Clear the DMA channel (null it)
;
;; Input:
;;  ah - DMA Channel
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;	Align	16
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;DMAClearChannel	PUSHX	ax,ebx,dx
;	XOr	ebx,ebx
;	Movzx	ebx,ax
;	Shr	bx,8
;	And	bx,7
;	Mov	dl,[DMAClear+ebx]		; DMA Channel
;	XOr	al,al
;	Out	dx,al		; Clear channel
;	POPX	ax,ebx,dx
;	Ret
;
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;; DMASetAddress - Set the start address
;;
;; Input:
;;  ah - Channel
;; edi - Address of block
;;
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;	Align	16
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;DMASetAddress	PUSHX	eax,ebx,edi,esi
;	Test	ah,0xfc		; Check for 8 bit DMA channel
;	Jz	.DMA8Bit
;	Mov	ebx,edi
;	And	ebx,0x10000		; Max transfer of 64kb
;	Shr	ebx,1
;	Shr	di,1
;	And	di,0x7fff
;	Or	di,bx
;	;
;.DMA8Bit	Movzx	esi,ax		; DMA Channel
;	Shr	si,8
;	And	si,7		; Index
;	;
;	Mov	eax,edi
;	XOr	dx,dx
;	Mov	dl,[DMAAddress+esi]	; DMA port
;	Out	dx,al		; Send low byte
;	Mov	al,ah
;	Out	dx,al		; Send high byte
;	Mov	dl,[DMALowerPage+esi]
;	Shr	eax,16
;	Out	dx,al		; Lower page byte
;	Shl	si,1
;	Mov	dx,[DMAHigherPage+esi]
;	Mov	al,ah
;	Out	dx,al		; Higher page byte
;	POPX	eax,ebx,edi,esi
;	Ret
;
;
;
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;; DMASetBlockSize - Set the DMA blocksize (max 64kb)
;;
;; Input:
;;  ah - DMA channel
;;  cx - Block Size
;;
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;	Align	16
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;DMASetBlockSize	PUSHX	ax,ebx,dx
;	Movzx	ebx,ax		; DMA channel
;	Shr	bx,8
;	And	bx,7
;	XOr	dx,dx
;	Mov	dl,[DMALength+ebx]	; DMA port
;	Mov	al,cl
;	Out	dx,al		; Size (low)
;	Mov	al,ch
;	Out	dx,al		; Size (high)
;	POPX	ax,ebx,dx
;	Ret
;
;
;
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;; DMAMaskChannel - Mask the DMA channel (disable)
;;
;; Input:
;;  ah - DMA channel
;;
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;	Align	16
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;DMAMaskChannel	PUSHX	ax,bx,dx
;	XOr	ebx,ebx
;	Shr	ax,8
;	Mov	bx,ax		; DMA channel
;	And	bx,7
;	XOr	dx,dx
;	Mov	al,[DMAWriteSingle+ebx]	; DMA port
;	Or	al,4		; DMA SetMaskBit
;	Out	dx,al
;	POPX	ax,bx,dx
;	Ret
;
;
;
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;; DMAUnMaskChannel - UnMask the DMA channel (enable)
;;
;; Input:
;;  ah - DMA channel
;;
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;	Align	16
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;DMAUnMaskChannel	PUSHX	ax,bx,dx
;	Shr	ax,8
;	Mov	bx,ax		; DMA channel
;	And	bx,7
;	XOr	dx,dx
;	Mov	dl,[DMAWriteSingle+bx]	; DMA port
;	And	al,3
;	Out	dx,al		; UnMask channel
;	POPX	ax,bx,dx
;	Ret
;
;
;
;
;;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;; DMA registers relative to each DMA channel (0-7)
;;
;
;DMAAddress	Db	0x00,0x02,0x04,0x06,0xc0,0xc4,0xc8,0xcc
;DMALength	Db	0x01,0x03,0x05,0x07,0xc2,0xc6,0xca,0xce
;DMAReadStatus	Db	0x08,0x08,0x08,0x08,0xd0,0xd0,0xd0,0xd0
;DMAWriteStatus	Db	0x08,0x08,0x08,0x08,0xd0,0xd0,0xd0,0xd0
;DMAWriteRequest	Db	0x09,0x09,0x09,0x09,0xd2,0xd2,0xd2,0xd2
;DMAWriteSingle	Db	0x0a,0x0a,0x0a,0x0a,0xd4,0xd4,0xd4,0xd4
;DMAWriteMode	Db	0x0b,0x0b,0x0b,0x0b,0xd6,0xd6,0xd6,0xd6
;DMAClear	Db	0x0c,0x0c,0x0c,0x0c,0xd8,0xd8,0xd8,0xd8
;DMAReadTemp	Db	0x0d,0x0d,0x0d,0x0d,0xda,0xda,0xda,0xda
;DMAMasterClear	Db	0x0d,0x0d,0x0d,0x0d,0xda,0xda,0xda,0xda
;DMAClearMask	Db	0x0e,0x0e,0x0e,0x0e,0xdc,0xdc,0xdc,0xdc
;DMAWriteAllMask	Db	0x0f,0x0f,0x0f,0x0f,0xde,0xde,0xde,0xde
;DMALowerPage	Db	0x87,0x83,0x81,0x82,0x00,0x8b,0x89,0x8a
;DMAHigherPage	Dw	0x487,0x483,0x481,0x482,0x000,0x48b,0x489,0x48a
;

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

