;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     PCI.s V1.0.0
;
;     PCI bus functions.
;




   	Struc PCIListEntry
PCILE_Default	ResB	PCI_SIZE	; Default PCI data
PCILE_Extended	ResB	240	; Extended PCI data, may be either Bridge, Non-bridge or Cardbus
PCILE_SIZE	EndStruc



InitPCIList	INITLIST	[SysBase+SB_PCIList]

	; Do the locomotion

.Loop	Mov byte	[Devicenumber],0
.Deviceloop	Mov byte	[Functionnumber],0
.Innerloop	Mov	ax,0x8000
	Add	al,[Busnumber]
	Shl	eax,5
	Add	al,[Devicenumber]
	Shl	eax,3
	Add	al,[Functionnumber]
	Shl	eax,8
	;-
	Mov	dx,PCI_CONFIGADDRESS
	Out	dx,eax
	Mov	ebp,eax
	Mov	dx,PCI_CONFIGDATA
	In	eax,dx

	Test	eax,eax
	Jz near	.NoWrite
	Cmp	eax,-1
	Je near	.NoWrite

	;--
	Lea	ebx,[SysBase+SB_PCIList]	; Check for dupes
.L	NEXTNODE	ebx,.NoEqual
	Cmp	[ebx+PCI_VendorID],eax	; Check vendor/deviceid
	Jne	.L
	Jmp	.NoWrite
	;--


.NoEqual	Push	ebp
	Mov	eax,PCILE_SIZE
	Mov	ebx,MEMF_NOKEY
	LIBCALL	AllocMem,ExecBase
	Mov	edi,eax

	Mov	bl,[Busnumber]
	Mov	[edi+PCI_Bus],bl
	Mov	bl,[Devicenumber]
	Mov	[edi+PCI_Device],bl
	Mov	bl,[Functionnumber]
	Mov	[edi+PCI_Function],bl
	;
	Lea	edi,[edi+PCI_VendorID]
	Pop	ebp
	Push	eax		; New node

	Mov	eax,ebp
.Dataloop	Mov	dx,PCI_CONFIGADDRESS
	Out	dx,eax
	Mov	ebp,eax
	Mov	dx,PCI_CONFIGDATA
	In	eax,dx
	Stosd
	Mov	eax,ebp
	;
	Add	al,4
	Cmp	al,252
	Jne	.Dataloop
	Sub	al,252
	;-
	Lea	eax,[SysBase+SB_PCIList]
	Pop	ebx		; Node
	ADDTAIL
	;
.NoWrite	Inc byte	[Functionnumber]
	Cmp byte	[Functionnumber],8
	Jne near	.Innerloop
	Inc byte	[Devicenumber]
	Cmp byte	[Devicenumber],32
	Jne near	.Deviceloop
	Inc byte	[Busnumber]
	Cmp byte	[Busnumber],4
	Jne near	.Loop
	Ret

Functionnumber	Db	0
Devicenumber	Db	0
Busnumber	Db	0


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; PCISetPFA
;
; Inputs: eax - PCI Config Address
;
;	Bits  0 -  7 = Address
;	Bits  8 - 10 = Function (0-7)
;	Bits 11 - 15 = Device (0-31)
;	Bits 16 - 24 = Bus (0-255)
;
; Output: eax - PCI Data Register
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PCISetPFA	PUSHX	ecx,edx
	Mov	ecx,eax
	Mov	edx,PCI_CONFIGADDRESS
	Mov	eax,0x80000000
	Or	eax,ecx
	And	eax,0x80fffffc
	Out	dx,eax
	Mov	dl,0xfc
	Or	dl,cl
	POPX	ecx,edx
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; PCIReadByte
;
; Inputs: eax - PCI Config Address
;
;	Bits  0 -  7 = Address
;	Bits  8 - 10 = Function (0-7)
;	Bits 11 - 15 = Device (0-31)
;	Bits 16 - 24 = Bus (0-255)
;
; Output: al - Byte read
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PCIReadByte	Call	PCISetPFA
	Push	dx
	Mov	dx,ax
	In	al,dx
	Pop	dx
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; PCIReadWord
;
; Inputs: eax - PCI Config Address
;
;	Bits  0 -  7 = Address
;	Bits  8 - 10 = Function (0-7)
;	Bits 11 - 15 = Device (0-31)
;	Bits 16 - 24 = Bus (0-255)
;
; Output: ax - Word read
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PCIReadWord	Call	PCISetPFA
	Push	dx
	Mov	dx,ax
	In	ax,dx
	Pop	dx
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; PCIReadLong
;
; Inputs: eax - PCI Config Address
;
;	Bits  0 -  7 = Address
;	Bits  8 - 10 = Function (0-7)
;	Bits 11 - 15 = Device (0-31)
;	Bits 16 - 24 = Bus (0-255)
;
; Output: eax - Long read
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PCIReadLong	Call	PCISetPFA
	Push	dx
	Mov	dx,ax
	In	eax,dx
	Pop	dx
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; PCIWriteByte
;
; Inputs: eax - PCI Config Address
;          bl - Byte to write
;
;	Bits  0 -  7 = Address
;	Bits  8 - 10 = Function (0-7)
;	Bits 11 - 15 = Device (0-31)
;	Bits 16 - 24 = Bus (0-255)
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PCIWriteByte	Call	PCISetPFA
	Push	dx
	Mov	dx,ax
	Mov	al,bl
	Out	dx,al
	Pop	dx
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; PCIWriteWord
;
; Inputs: eax - PCI Config Address
;          bx - Word to write
;
;	Bits  0 -  7 = Address
;	Bits  8 - 10 = Function (0-7)
;	Bits 11 - 15 = Device (0-31)
;	Bits 16 - 24 = Bus (0-255)
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PCIWriteWord	Call	PCISetPFA
	Push	dx
	Mov	dx,ax
	Mov	ax,bx
	Out	dx,ax
	Pop	dx
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; PCIWriteWord
;
; Inputs: eax - PCI Config Address
;         ebx - Word to write
;
;	Bits  0 -  7 = Address
;	Bits  8 - 10 = Function (0-7)
;	Bits 11 - 15 = Device (0-31)
;	Bits 16 - 24 = Bus (0-255)
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PCIWriteLong	Call	PCISetPFA
	Push	dx
	Mov	dx,ax
	Mov	eax,ebx
	Out	dx,eax
	Pop	dx
	Ret



