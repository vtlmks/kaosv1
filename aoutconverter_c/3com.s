
	%Include	"z:\kaos\Includes\TypeDef.I"
	%Include	"z:\kaos\Includes\Lists.I"
	%include	"z:\kaos\Includes\Nodes.I"
	%include	"z:\kaos\Includes\TagList.I"
	%include	"z:\kaos\Includes\Libraries.I"
	%include	"z:\kaos\Includes\Macros.I"
	%include	"z:\kaos\Includes\Lvo\Exec.I"
	%include	"z:\kaos\Includes\Lvo\Font.I"
	%include	"z:\kaos\Includes\Lvo\UserInterface.I"
	%include	"z:\kaos\Includes\UserInterface\Classes.I"
	%Include	"Z:\kaos\Includes\Classes\Group.I"
	%Include	"Z:\kaos\Includes\Devices\3c90x.I"

	Bits	32
	Section	.text

	Struc	Fart
_ExecBase	ResD	1
_SIZE	EndStruc

IOMEMBASE	Equ	0xf4101000
IOBASE	Equ	0x1080


CMD_IN_PROGRESS	Equ	4096

%Macro	WINSELECT	1
	Mov	dx,IOBASE+NIC3C90XCMD
	Mov	ax,NIC3C90XCMD_SelectRegisterWindow+%1
	Out	dx,ax
%EndMacro

%Macro	NICCMD	1
	Mov	dx,IOBASE+NIC3C90XCMD
	Mov	ax,%1
	Out	dx,ax
%EndMacro


; f4101000 - f410107f
; 1080 - 10ff
; iRQ7

Start	LINK	_SIZE
	Mov	[ebp+_ExecBase],eax

	Lea	eax,[HelloTxt]
	Int	0xff


	Mov	eax,0xf4101000
	Mov	ebx,0x1000		; 0x80
	LIB	MapMemory,[ebp+_ExecBase]

	Lea	eax,[IOMacAddressTxt]
	Int	0xff
	Call	GetMacAddress


	;---
	Lea	eax,[NodeAddressTxt]
	Int	0xff

	Movzx	eax,word [IOMEMBASE+NIC3C90XBEEPROM.3COMNodeAddress0]
	Int	0xfe
	Movzx	eax,word [IOMEMBASE+NIC3C90XBEEPROM.3COMNodeAddress1]
	Int	0xfe
	Movzx	eax,word [IOMEMBASE+NIC3C90XBEEPROM.3COMNodeAddress2]
	Int	0xfe

	;----
	Lea	eax,[Node3COMAddrTxt]
	Int	0xff

	Movzx	eax,word [IOMEMBASE+NIC3C90XBEEPROM.3COMNodeAddress0]
	Int	0xfe
	Movzx	eax,word [IOMEMBASE+NIC3C90XBEEPROM.3COMNodeAddress1]
	Int	0xfe
	Movzx	eax,word [IOMEMBASE+NIC3C90XBEEPROM.3COMNodeAddress2]
	Int	0xfe


	Lea	eax,[EEPROMTxt]
	Int	0xff
	Call	GetEEPROMData




;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
Exit	UNLINK	_SIZE
	Ret

HelloTxt	Db	"Hello!",0xa,0


IOMacAddressTxt	Db	"IO port mac addresses : ",0xa,0xa,0
NodeAddressTxt	Db	"EEPROM node addresses : ",0xa,0xa,0
Node3COMAddrTxt	Db	"EEPROM 3comnode addresses :",0xa,0xa,0
EEPROMTxt	Db	"EEPROM extracted data : ",0xa,0xa,0

GetEEPROMData	WINSELECT	0

.L1	Mov	dx,IOBASE+NIC3C90XWIN0.EepromCommand
	In	ax,dx
	Movzx	eax,ax
	Int	0xfe
	Bt	ax,15
	Jnc	.NotBusy
	Mov	ecx,10000
.L	Dec	ecx
	Jnz	.L
	Jmp	.L1


.NotBusy	Mov	dx,IOBASE+NIC3C90XWIN0.EepromCommand
	Mov	ax,0xa		; OEM Node Address (word 0)
	Out	dx,ax
	Mov	dx,IOBASE+NIC3C90XWIN0.EepromData
	In	ax,dx

	Movzx	eax,ax
	Int	0xfe


	Mov	dx,IOBASE+NIC3C90XWIN0.EepromCommand
	Mov	ax,0xb		; OEM Node Address (word 0)
	Out	dx,ax
	Mov	dx,IOBASE+NIC3C90XWIN0.EepromData
	In	ax,dx


	Movzx	eax,ax
	Int	0xfe

	Mov	dx,IOBASE+NIC3C90XWIN0.EepromCommand
	Mov	ax,0xc		; OEM Node Address (word 0)
	Out	dx,ax
	Mov	dx,IOBASE+NIC3C90XWIN0.EepromData
	In	ax,dx

	Movzx	eax,ax
	Int	0xfe

	Ret



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
GetMacAddress	WINSELECT	2
	Mov	dx,IOBASE
	In	ax,dx
	Movzx	eax,ax
	Int	0xfe		; printsheit
	Mov	dx,IOBASE+2
	In	ax,dx
	Movzx	eax,ax
	Int	0xfe		; printsheit
	Mov	dx,IOBASE+4
	In	ax,dx
	Movzx	eax,ax
	Int	0xfe		; printsheit
	Ret



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
Mo	Dd	Mo		; remove when Aoutconverter is fixed..
