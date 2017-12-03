
	%Include	"Includes\TypeDef.I"
	%Include	"Includes\Hardware\Keyboard.I"
	%Include	"Includes\Hardware\Pic.I"

SYSCODE_SEL	EQU	8	; Kernel code selector
SYSDATA_SEL	EQU	16	; Kernel data selector, temporary


	Bits	16
	Org	0x80000
	Section	.text

desc_lml     EQU      0
desc_bsl     EQU      2
desc_bsm     EQU      4
desc_acc     EQU      5
desc_lmh     EQU      6
desc_bsh     EQU      7


start	jmp	$

	cli		; Should be done already, just a bit paranoide
	cld		; clear the direction flag

	mov	ax,0x8000
	mov	ds,ax
	mov	es,ax
	mov	fs,ax
	mov	gs,ax
	mov	ss,ax

	xor	eax,eax
	mov	ax,cs
	shl	eax,4

	add	dword [GDTLimit + 2],eax

	mov	[GDTSysCode + desc_bsl],ax	; base 0-15
	mov	[GDTSysData + desc_bsl],ax	; base 0-15
	shr	eax,8
	mov	[GDTSysCode + desc_bsm],ah	; base 16-23
	mov	[GDTSysData + desc_bsm],ah	; base 16-23

	lgdt 	[GDTLimit]        ; Init protected mode

	mov	eax,cr0
	or	al,1
	mov	cr0,eax

	Jmp dword	SYSCODE_SEL:SMPStart	; Here all fun begins..


	Bits	32

SMPStart	Mov	ax,SYSDATA_SEL
	Mov	ds,ax
	Mov	es,ax

.L	Inc dword	[0x70000]
	Jmp	.L

	Db	'END OF 32BIT SMPSTART!'
;
;;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;Start	Mov	ax,0x7000
;	Mov	ds,ax
;	XOr	di,di
;.L1	Inc word	[ds:di]
;;;;;	Jmp	.L1
;
;	Mov	ax,cs
;	Mov	ds,ax
;	Mov	es,ax
;
;	Push dword	0		; Clear EFlags, #NT, #IF and IOPL=0
;	PopFD
;
;	XOr	ebx,ebx
;	Mov	bx,cs
;	Shl	ebx,4
;	Lea	eax,[GDTTable+ebx]
;	Mov	[GDTLimit+2],eax
;	LGDT	[cs:GDTLimit]
;
;
;	Mov	eax,cr0
;	Or	al,1
;	Mov	cr0,eax
;
;	Jmp	$
;
;	Mov	ax,SYSDATA_SEL
;	Mov	ds,ax
;	Mov	es,ax
;	Mov	fs,ax
;
;	Lea	esi,[SMPStart+ebx]
;	Mov	edi,0x90000
;	Mov	ecx,400
;.L	Mov	eax,[fs:esi]
;	Mov	[fs:edi],eax
;	Add	esi,4
;	Add	edi,4
;	Dec	ecx
;	Jnz	.L
;
;
;	Jmp dword	SYSCODE_SEL:0x90000	; Here all fun begins..
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

GDTLimit	Dw	GDTLength-GDTTable-1
	Dd	GDTTable

GDTTable	Dd	0,0	; Null descriptor

GDTSysCode	Dw	0xFFFF,0
	Db	0,0x9A	; Present, Ring0-Code, Non-conforming, Readable
	Db	0xCF,0

GDTSysData	Dw	0xFFFF,0
	Db	0,0x92	; Present, Ring0-Data, Expand-up, Writeable
	Db	0xCF,0

GDTLength	; counter, don't remove..

;;SMPStart	Incbin	"smpkernel.bin"

