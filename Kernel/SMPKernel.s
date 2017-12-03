	Bits	32
	Org	0x90000
	Section	.text

Boot	LGDT	[GDTLimit]
	Mov	ax,SYSDATA_SEL
	Mov	ds,ax
	Mov	es,ax
	Mov	fs,ax
	Mov	gs,ax
	Mov	ss,ax
	Mov	esp,0x95000
	;
	Push dword	0x2000		; Clears #NT, #IF etc. and sets IOPL = Ring 2.
	PopFD			; Interrupts will be enabled when the first task is dispatched

	Mov dword	[0x70000],1



	Mov	eax,0xfeedbeef
TankIt	Lea	edi,[0xb8000]
	Mov	ecx,80*25/2
	Rep Stosd
	Lea	eax,[eax+0xdeadbabe]
	Jmp	TankIt


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

GDTLimit	Dw	GDTLength-GDTTable-1
	Dd	GDTTable

GDTTable	Dd	0,0		; Null descriptor

SYSCODE_SEL	Equ	$-GDTTable
	Dw	0xFFFF,0
	Db	0,0x9A		; Present, Ring0-Code, Non-conforming, Readable
	Db	0xCF,0

SYSDATA_SEL	Equ	$-GDTTable
	Dw	0xFFFF,0
	Db	0,0x92		; Present, Ring0-Data, Expand-up, Writable
	Db	0xCF,0

GDTLength
