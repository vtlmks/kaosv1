;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Init.s V1.0.0
;
;     Initialization routines.
;
;

	%Include	"Includes\Lists.I"
	%Include	"Includes\Nodes.I"
	%Include	"Includes\SysBase.I"
	%Include	"Includes\Hardware\Keyboard.I"
	%Include	"Includes\Hardware\Pic.I"
	%Include	"Includes\Hardware\PnP.I"
	%Include	"Includes\Hardware\VESA.I"
	%Include	"Includes\Hardware\VGA.I"

	Org	0x100
	Bits	16
	Section	.text

ChunkSize	Equ	2048	; Chunksize for loader
PNP_MAXSIZE	Equ	256*40

	Struc InitStruc
INIT_CardInfoBuf	ResB	VBEInfoB_Size+1	; VESA cardinformation buffer
INIT_ModeInfoBuf	ResB	VBEModeB_Size+1	; VESA modeinformation buffer
INIT_ChunkBuffer	ResB	ChunkSize+2	; Chunkbuffer for loader
INIT_PNPIStruct	ResB	PNP_SIZE	; PnP infostructure
INIT_PNPNodeSize	ResD	1	; Nodesize (max)
INIT_PNPNumNodes	ResD	1	; Number of nodes
INIT_PNPNode	ResD	1	; Nodecounter
INIT_PNPDevBuffer	ResB	PNP_MAXSIZE	; Devnode buffers
	;
INIT_NVStorage	ResD	1	; ESCD
INIT_ESCDSize	ResD	1	; ESCD
INIT_MinESCDSize	ResD	1	; ESCD
INIT_ESCDBuffer	ResB	8192
INIT_SIZE	EndStruc




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
Start	Mov	ax,cs
	Mov	ds,ax
	Mov	es,ax
;;;	Call	SetupPNP
	Call	SetupVESA

	Mov	eax,[InitBase+INIT_ModeInfoBuf+MD_PhyBasePtr]
	Push	eax
	;
	Push dword	0		; Clear EFlags, #NT, #IF and IOPL=0
	PopFD
	;
	XOr	ebx,ebx
	Mov	bx,cs
	Shl	ebx,4
	Lea	eax,[GDTTable+ebx]
	Mov	[GDTLimit+2],eax
	LGDT	[cs:GDTLimit]
	;
	;--
	Mov	ecx,cr0
	Or	cl,1
	Mov	cr0,ecx
	Mov	ax,SYSDATA_SEL
	Mov	ds,ax
	Mov	es,ax
	Mov	fs,ax
	Call	EnableA20
	Call	InitEarlySysBase
	Call	ProbeMemory
;;;	Call	InitPNPBase
	Call	LoadKernel
	;
	Call	GetEquipment
	;
	Mov	eax,0x10000
	Mov	ebx,SysBaseTemp+SB_KernelSize
	Mov	[fs:ebx],eax
	;
	Call	InitPaging
	;
	Pop	ecx
	Call	InitVesa
	;
	Call	SetupPIC
	Call	MoveSysBase
	;
	Jmp dword	SYSCODE_SEL:0xffe00000	; Here all fun begins..


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Enables the A20 gate.
;
EnableA20	Cli
.L	In	al,KEYBP_STAT
	Test	al,2
	Jnz	.L
	Mov	al,KCMD_SetWPort
	Out	KEYBP_STAT,al
.L1	In	al,KEYBP_STAT
	Test	al,2
	Jnz	.L1
	Mov	al,KCMD_SetA20
	Out	KEYBP_DATA,al
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Direct-probe the memory w/out BIOS calls, returns amount of bytes in eax.
;
ProbeMemory	Mov	eax,0x80000
.L	Mov dword	[fs:eax],0xDEADBEEF
	Cmp dword	[fs:eax],0XDEADBEEF
	Jne	.Done
	Lea	eax,[eax+0x100000]
	Jmp	.L
.Done	Sub	eax,0x100000
	Mov	ebx,SysBaseTemp+SB_MemoryTotal
	Mov	[fs:ebx],eax
	Add dword	[fs:ebx],0x80000
	;
	Mov	ebx,KernelEntry			; Entrypoint for kernel
	Mov	[fs:ebx],eax
	Mov	ebx,KernelSize
	Mov dword	[fs:ebx],64*1024			; Size of kernel in bytes
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Clear and initialize temporary sysbase.
;
InitEarlySysBase	Mov	edi,SysBaseTemp
	Mov	ecx,(SB_SIZE/4)+1
.L	Mov dword	[fs:edi],0
	Lea	edi,[edi+4]
	Dec	ecx
	Jnz	.L
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
InitPNPBase	Mov	ecx,cr0
	Or	cl,1
	Mov	cr0,ecx
	;
	XOr	ebx,ebx
	Mov	bx,cs
	Shl	ebx,4
	Lea	esi,[InitBase+INIT_PNPDevBuffer+ebx]
	Mov	edi,PNPTempBase
	Mov	ecx,PNP_MAXSIZE
	Cld
.L	Mov	al,[fs:esi]
	Mov	[fs:edi],al
	Inc	esi
	Inc	edi
	Dec	ecx
	Jnz	.L
	;
	Mov	edi,SysBaseTemp+SB_PNPNumNodes
	XOr	eax,eax
	Mov	ax,[InitBase+INIT_PNPNumNodes+ebx]
	Mov	[fs:edi],eax

	;
	; Copy ESCD data to temp space
	;
	Lea	esi,[InitBase+INIT_ESCDBuffer+ebx]
	Mov	edi,PNPESCDBase
	Mov	ecx,PNP_MAXSIZE
.L1	Mov	al,[fs:esi]
	Mov	[fs:edi],al
	Inc	esi
	Inc	edi
	Dec	ecx
	Jnz	.L1
	Ret


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Get BIOS equipment bitfield
;
GetEquipment	Mov	ecx,cr0
	And	cl,0xfe
	Mov	cr0,ecx
	Int	0x11
	Mov	ecx,cr0
	Or	cl,1
	Mov	cr0,ecx
	Mov	ebx,SysBaseTemp+SB_BIOSEquipment
	Mov	[fs:ebx],eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
InitVesa	Mov	ebx,SysBaseTemp+SB_VESA
	Mov	[fs:ebx],ecx
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Move the temporary sysbase, to the new.
;
MoveSysBase	Mov	esi,SysBaseTemp
	Mov	edi,SysBase
	Mov	ecx,(SB_SIZE/4)+1
.L	Mov	eax,[fs:esi]
	Mov	[fs:edi],eax
	Lea	esi,[esi+4]
	Lea	edi,[edi+4]
	Dec	ecx
	Jnz	.L
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Initiates the PICs and moves the PIC vectors to 0x20-0x2f for IRQ 0-15.
;
SetupPIC	Mov	al,ICW1	;Start 8259 initialization, ICW1
	Out	PIC_M,al
	Out	PIC_S,al
	Mov	al,0x20	;Base interrupt vector, INTA @ 0x20
	Out	PIC_M+1,al
	Mov	al,0x28	;Base interrupt vector, INTB @ 0x28
	Out	PIC_S+1,al
	Mov	al,1<<2	;Bitmask for cascade on IRQ 2
	Out	PIC_M+1,al
	Mov	al,2	;Cascade on IRQ 2
	Out	PIC_S+1,al
	Mov	al,0x01	;Finish 8259 initialization, ICW4
	Out	PIC_M+1,al
	Out	PIC_S+1,al
	Mov	al,0xFB	;Mask all interrupts but the Slave pic (IRQ2).
	Out	PIC_M+1,al
	Out	PIC_S+1,al
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Loads the kernel to the given offset. This uses BIOS/DOS interrupt calls, and
; should be replaced with the real code later..
;
LoadKernel	Mov	ecx,cr0
	And	cl,0xfe
	Mov	cr0,ecx
	Mov	ax,cs
	Mov	ds,ax
	Mov	es,ax
	Mov	ax,0x3d00	; Dos Open(), read only
	Mov	dx,KernelFileN	; Filename of kernel, read at ds:dx
	XOr	cx,cx
	Int	0x21
	Jc near	.Failure
	Mov	[FileHD],ax
	;
	Mov	ecx,cr0
	Or	cl,1
	Mov	cr0,ecx

	Mov	edi,KernelEntry
	Mov	edi,[fs:edi]

.Loop	Mov	ecx,cr0
	And	cl,0xfe
	Mov	cr0,ecx
	;
	Mov	ax,0x3f00
	Mov	bx,[FileHD]
	Mov	cx,ChunkSize	; Number of bytes to read
	Lea	dx,[InitBase+INIT_ChunkBuffer]
	Push	edi
	Int	0x21
	Pop	edi
	Test	ax,ax
	Jz	.Done
	;
	Mov	ecx,cr0
	Or	cl,1
	Mov	cr0,ecx
	XOr	ebx,ebx
	Mov	bx,cs
	Shl	ebx,4
	Lea	esi,[InitBase+INIT_ChunkBuffer+ebx]
	Lea	ecx,[ChunkSize]
	Cld

.L	Mov	al,[fs:esi]
	Mov	[fs:edi],al
	Inc	esi
	Inc	edi
	Dec	ecx
	Jnz	.L


	Jmp	.Loop
.Done	Mov	ecx,cr0
	Or	cl,1
	Mov	cr0,ecx
	Ret

.Failure	Mov	ax,0x900
	Mov	dx,FailureTxt
	Int	0x21
	Jmp	$



	%Include	"Init\Page.s"
	%Include	"Init\PnP.s"
	%Include	"Init\Vesa.s"

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SYSCODE_SEL	EQU	8	; Kernel code selector
SYSDATA_SEL	EQU	16	; Kernel data selector, temporary

GDTLimit	Dw	GDTLength-GDTTable-1
	Dd	GDTTable

GDTTable	Dd	0,0	; Null descriptor

GDTSysCode	Dw	0xFFFF,0
	Db	0,0x9A	; Present, Ring0-Code, Non-conforming, Readable
	Db	0xCF,0

GDTSysData	Dw	0xFFFF,0
	Db	0,0x92	; Present, Ring0-Data, Expand-up, Writeable
	Db	0xCF,0

GDTLength:	; counter, don't remove..


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

KernelStack	Dd	0	; Kernel stack pointer
FileHD	Dw	0	; Kernel.bin filehandler


FailureTxt	Db	"Failed to open kernel.bin!",0xd,0xa,"$"
KernelFileN	Db	"kernel.bin",0




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
InitBase:	; the INIT struct must be offseted from here, and must be at the end..


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
