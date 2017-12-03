

	%Include	"..\Includes\TypeDef.I"
	%Include	"..\Includes\TagList.I"
	%Include	"..\Includes\Nodes.I"
	%Include	"..\Includes\Lists.I"
	%Include	"..\Includes\Exec\Memory.I"
	%Include	"..\Includes\Libraries.I"
	%Include	"..\Includes\Macros.I"
	%Include	"..\Includes\LVO\Exec.I"

	Bits	32
	Section	.text

	Struc	Fart
_SysBase	ResD	1
_SIZE	EndStruc

Start	LINK	_SIZE
	Mov	[ebp+_SysBase],eax
	Lea	esi,[AllocSize]
.Loop	Mov	eax,[esi]
	XOr	ebx,ebx
	LIB	AllocMem,[ebp+_SysBase]
	LIB	FreeMem
	Lea	esi,[esi+4]
	Cmp dword	[esi],0
	Jne	.Loop
	Lea	esi,[AllocSize]
	Jmp	.Loop
	UNLINK	_SIZE
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
AllocSize	Dd	1024
	Dd	2048
	Dd	4096
	Dd	8192
	Dd	16384
	Dd	32768
	Dd	65536
	Dd	0
