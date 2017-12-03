

	%Include	"..\Includes\TypeDef.I"
	%Include	"..\Includes\Lists.I"
	%Include	"..\Includes\Nodes.I"
	%Include	"..\Includes\SysBase.I"
	%Include	"..\Includes\Hardware\Keyboard.I"

	Section	.text
	Bits	16
	Org	0x4100

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Welcome to 16-bits..
;

RealMode	Mov	ax,cs
	Mov	ds,ax
	Mov	es,ax
	Mov	ss,ax
	LIDT	[IDTLimit]
;;;	Sti

	;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	; remove, test..

	Mov	ax,0x4f02	; set 640x480x8..
	Mov	bx,0x101
	XOr	di,di
	Int	0x10
	;
	Mov	ax,3
	Int	0x10

.Dummy	Inc byte	[KeybMo]
	Call	.Wait
	Mov	al,KCMD_SetMI		; Set mode indicators
	Out	KEYBP_DATA,al
	Call	.Wait
	Mov	al,[KeybMo]
	And	al,0x7		; Mask led status
	Out	KEYBP_DATA,al
	Jmp	.Dummy

.Wait	In	al,KEYBP_CTRL
	Test	al,2
	Jne	.Wait
	Ret

KeybMo	Dd	0

	; remove, test..
	;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align 16		; alignment for idt..
IDTLimit	Dw	1024-1	; Realmode IDTR original values (base 0, limit 1023)
	Dd	0








;;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;	; now let's get back..
;
;	Bits	32
;
;	Mov	eax,cr0
;	Or	eax,1	; Set protectedmode again
;	Mov	cr0,eax
;	Jmp dword	SYSCODE_SEL:ReEnterPM	; long jump to 32-bit code segment
;
;ReEnterPM	Mov	ax,SYSDATA_SEL
;	Mov	ds,ax
;	Mov	ss,ax
;	Mov	es,ax
;
;	LGDT	[SW_GDT]
;	LIDT	[SW_IDT]
;	Mov	eax,[SW_CR3]
;	Mov	cr3,eax
;	Or	eax,0x80000000		; Enable paging
;
;	Lea	eax,[WeAreBackTxt]
;	Int	0xff
;	Ret
;
;
;
;
;WeAreBackTxt	Db	"We're back...",0xa,0
;
