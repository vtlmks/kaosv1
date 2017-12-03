

	%Include	"..\Includes\TypeDef.I"
	%Include	"..\Includes\Lists.I"
	%include	"..\Includes\Nodes.I"
	%include	"..\Includes\TagList.I"
	%include	"..\Includes\Libraries.I"
	%include	"..\Includes\Macros.I"
	%Include	"..\Includes\Ports.I"
	%include	"..\Includes\LVO\Exec.I"
	%include	"..\Includes\LVO\Font.I"
	%Include	"..\includes\LVO\graphics.i"
	%include	"..\Includes\LVO\UserInterface.I"
	%Include	"..\Includes\Libraries\Font.I"
	%include	"..\Includes\UserInterface\Classes.I"
	%Include	"..\Includes\Classes\Group.I"
	%Include	"..\Includes\Classes\Window.I"

	Bits	32
	Section	.text

	Struc	Fart
_SysBase	ResD	1
_MsgPort	ResD	1
_SIZE	EndStruc

Start	LINK	_SIZE
	Mov	[ebp+_SysBase],eax

	Mov dword	[0x400000],0

	LIB	CreateMsgPort,[ebp+_SysBase]
	Mov	[ebp+_MsgPort],eax
	Lea	ebx,[PortN]
	Int	0xfe
	LIB	AddPort

.Main	LIB	Wait
.L	LIB	GetMsg
	Test	eax,eax
	Jz	.Main

	Inc dword	[0x400000]
	LIB	FreeMem
	Jmp	.L

	UNLINK	_SIZE
	Ret

PortN	Db	'master.port',0

