

	%Include	"..\Includes\TypeDef.I"
	%Include	"..\Includes\Lists.I"
	%include	"..\Includes\Nodes.I"
	%include	"..\Includes\TagList.I"
	%include	"..\Includes\Libraries.I"
	%include	"..\Includes\Macros.I"
	%Include	"..\Includes\Ports.I"
	%Include	"..\includes\exec\memory.i"
	%include	"..\Includes\LVO\Exec.I"
	%include	"..\Includes\LVO\Font.I"
	%Include	"..\includes\LVO\graphics.i"
	%include	"..\Includes\LVO\UserInterface.I"
	%Include	"..\Includes\Libraries\Font.I"
	%include	"..\Includes\UserInterface\Classes.I"
	%Include	"..\Includes\Classes\Group.I"
	%Include	"..\Includes\Classes\Window.I"
	%Include	"..\Includes\Exec\Lowlevel.I"


	Bits	32
	Section	.text

	Struc SlaveStruc
_ExecBase	ResD	1
_Port	ResD	1
_Message	ResD	1
_SIZE	EndStruc


Start	Mov	ebx,eax

;	Mov	esi,0x3
;.L	Lea	ecx,[RunProcTags]
;	Mov	[ecx+4],eax
;	LIB	AddProcess,ebx
;	Dec	esi
;	Jnz	.L

	Mov	esi,0x20
.L	Lea	ecx,[RunProcTags]
	LIB	AddProcess,ebx
	Dec	esi
	Jnz	.L
	Ret

RunProcTags	Dd	AP_PROCESSPOINTER,Proceduren
	Dd	AP_PRIORITY,0
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,1024
	Dd	AP_RING,2
	Dd	AP_QUANTUM,4
	Dd	AP_NAME,RunPN
	Dd	TAG_DONE

RunPN	Db	"Storpotaten",0


Proceduren	LINK	_SIZE
	Mov	[ebp+_ExecBase],eax

;	Mov	eax,ebp
;	Int	0xfe
;	Mov	eax,esp
;	Int	0xfe
;	Jmp	$


	Lea	eax,[PortN]
	LIB	FindPort,[ebp+_ExecBase]
	Mov	[ebp+_Port],eax
	Test	eax,eax
	Jz	.Done

	Mov	edi,0x400
.L	Mov	eax,1024
	Mov	ebx,MEMF_NOCLEAR
	LIB	AllocMem
	Test	eax,eax
	Jz	.L
	Mov dword	[eax+MN_REPLYPORT],0
	Mov	[ebp+_Message],eax

	Mov	eax,[ebp+_Port]
	Mov	ebx,[ebp+_Message]
	LIB	PutMsg

	Dec	edi
	Jnz	.L

.Done	UNLINK	_SIZE
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PortN	Db	"master.port",0
