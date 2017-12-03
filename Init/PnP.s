;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     PnP.s V1.0.0
;
;     Plug And Play (PnP) initialization.
;
;


SetupPNP	Push word	0xf000
	Pop	ds
	XOr	esi,esi

	Mov	ecx,16383
.NotFound	Lodsd
	Test	esi,esi
	Jz	.Error
	Cmp	eax,"$PnP"
	Jne	.NotFound
	;

	Push	esi
	Lea	esi,[esi-4]
	Lea	edi,[InitBase+INIT_PNPIStruct]	; Copy PnP Installation structure..
	Mov	ecx,34/4
	Rep Movsd
	Pop	esi
	;
	Mov	ax,cs
	Mov	ds,ax

.NoMore	Call	PnPGetNumNodes
	Jnz	.Error
	Call	PnPGetDeviceNodes

	Call	PnPGetESCDInfo
	Call	PnPReadESCD
.Error	Ret





;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PnPGetNumNodes	Push word	0xf000		; Bios selector
	Push word	ds		; NodeSize segment
	Push word	InitBase+INIT_PNPNodeSize	; NodeSize offset
	Push word	ds		; NumNodes segment
	Push word	InitBase+INIT_PNPNumNodes	; NumNodes segment
	Push word	PNP_GETNUMNODES
	Call far	[InitBase+INIT_PNPIStruct+PNPRMEntryPoint]
	Add	sp,12
	Test	ax,ax
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PnPGetDeviceNodes	Mov dword	[InitBase+INIT_PNPNode],0
.L	Push word	0xf000
	Push word	0x1
	Push word	ds
	Push word	InitBase+INIT_PNPDevBuffer
	Mov	bx,[Count]
	Add	[esp],bx
	Push word	ds
	Push word	InitBase+INIT_PNPNode
	Push word	PNP_GETSYSDEVNODE
	Call far	[InitBase+INIT_PNPIStruct+PNPRMEntryPoint]
	Add	sp,14
	Add word	[Count],256
	Test	ax,ax
	Jz	.L
	Ret

Count	Dw	0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PnPGetESCDInfo	Push word	0xf000
	Push word	ds
	Push word	InitBase+INIT_NVStorage
	Push word	ds
	Push word	InitBase+INIT_ESCDSize
	Push word	ds
	Push word	InitBase+INIT_MinESCDSize
	Push word	PNP_GETESCDINFO
	Call far	[InitBase+INIT_PNPIStruct+PNPRMEntryPoint]
	Add	sp,16
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PnPReadESCD	Push word	0xf000
	Mov	bx,InitBase+INIT_NVStorage+2
	Mov	ax,InitBase+INIT_NVStorage
	Shr	ax,4
	Shl	bx,12
	Add	ax,bx
	Push word	ax
	Push word	ds
	Push word	InitBase+INIT_ESCDBuffer
	Push word	PNP_READESCDDATA
	Call far	[InitBase+INIT_PNPIStruct+PNPRMEntryPoint]
	Add	sp,10
	Ret
