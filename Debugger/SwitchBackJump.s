
	%Include	"..\Includes\TypeDef.I"
	%Include	"..\Includes\Lists.I"
	%Include	"..\Includes\Nodes.I"
	%Include	"..\Includes\SysBase.I"
	%Include	"..\Includes\Hardware\Keyboard.I"

	Section	.text
	Org	0x40000
	Bits	32

SwitchBack2	Cli
	Cld
	Mov	eax,cr3
	Mov	[SW_CR3],eax
	Mov	[SW_ESP],esp
	SGDT	[SW_GDT]
	SIDT	[SW_IDT]
	LGDT	[GDTLimit]
	;
	Lea	esi,[PreRealmode]
	Mov	edi,0x4000
	Mov	ecx,0x100
	Rep Movsd
	;
	Lea	esi,[SWWithin]
	Mov	edi,0x4100
	Mov	ecx,2048
	Rep Movsd
	;
	XOr	eax,eax
	CPUID
	Bt	edx,CPUIDB_PGE
	Jnc	.NoGlobal
	Mov	eax,cr4
	XOr	eax,10000000b		; Disable Global pages....
	Mov	cr4,eax
	;
.NoGlobal	Mov	eax,cr0
	And	eax,0x7fffffff		; Disable paging for awhile
	Mov	cr0,eax
	;
	XOr	eax,eax
	Mov	cr3,eax		; Flush the TLB
	;
	Mov	esp,0x2000		; Realmode stack ptr @ 0x42000
	XOr	ebp,ebp		; Realmode stack baseptr
	Mov	eax,REALMODE_DATA_SEL
	Mov	ds,ax
	Mov	es,ax
	Mov	fs,ax
	Mov	gs,ax
	Jmp dword	REALMODE_CODE_SEL:0x4000

SW_CR3	Dd	0
SW_GDT	Dw	0,0,0
SW_IDT	Dw	0,0,0
SW_ESP	Dd	0



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

REALMODE_CODE_SEL	Equ	$-GDTTable
REALMODE_CODE	Dw	0xffff,0
	Db	0,0x9a		; Realmode-code
	Db	0,0

REALMODE_DATA_SEL	Equ	$-GDTTable
REALMODE_DATA	Dw	0xffff,0
	Db	0,0x92		; Realmode-data
	Db	0,0


GDTLength:	; counter, don't remove.

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PreRealmode	Mov	eax,cr0	; Pre-realmode, turn off protectedmode and make
	And	al,0xfe	; a intersegment jump to reload cs..
	Mov	cr0,eax
	Jmp	0x0:0x4100	;..

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SWWithin	Incbin	"SwitchbackWithin.bin"
