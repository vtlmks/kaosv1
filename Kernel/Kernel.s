;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Kernel.s V1.0.0
;
;     The KAOS kernel.
;
;
;


	%Include	"Includes\TypeDef.I"
	%Include	"Includes\IO.I"
	%Include	"Includes\Libraries.I"
	%Include	"Includes\Lists.I"
	%Include	"Includes\Macros.I"
	%Include	"Includes\Nodes.I"
	%Include	"Includes\Ports.I"
	%Include	"Includes\SysBase.I"
	%Include	"Includes\TagList.I"
	%Include	"Includes\Dos\Dos.I"
	%Include	"Includes\Dos\Hunks.I"
	%Include	"Includes\Drivers\Drivers.I"
	%Include	"Includes\Drivers\Graphics\Graphics.I"
	%Include	"Includes\Exec\Hooks.I"
	%Include	"Includes\Exec\IO.I"
	%Include	"Includes\Exec\LowLevel.I"
	%Include	"Includes\Exec\Memory.I"
	%Include	"Includes\Exec\Process.I"
	%Include	"Includes\FileSystems\Partition.I"
	%Include	"Includes\FileSystems\Fat\Fat.I"
	%Include	"Includes\Graphics\Graphics.I"
	%Include	"Includes\Hardware\DMA.I"
	%Include	"Includes\Hardware\EISA.I"
	%Include	"Includes\Hardware\Floppy.I"
	%Include	"Includes\Hardware\IDE.I"
	%Include	"Includes\Hardware\Keyboard.I"
	%Include	"Includes\Hardware\PCI.I"
	%Include	"Includes\Hardware\PIC.I"
	%Include	"Includes\Hardware\PnP.I"
	%Include	"Includes\Hardware\RTC.I"
	%Include	"Includes\Hardware\Serial.I"
	%Include	"Includes\Hardware\Timer.I"
	%Include	"Includes\Hardware\VGA.I"
	%Include	"Includes\Libraries\Timer.I"
	%Include	"Includes\LVO\DOS.I"
	%Include	"Includes\LVO\Exec.I"
	%Include	"Includes\LVO\Graphics.I"
	%Include	"Includes\LVO\Timer.I"
	%Include	"Includes\LVO\UserInterface.I"
	%Include	"Includes\LVO\Utility.I"
	%Include	"Includes\UserInterface\Classes.I"
	%Include	"Includes\UserInterface\InputEvent.I"
	%Include	"Includes\UserInterface\Pens.I"
	%Include	"Includes\Classes\Window.I"

	Bits	32
	Org	0xffe00000
	Section	.text


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
Kernel	LGDT	[GDTLimit]
	Mov	ax,SYSDATA_SEL
	Mov	ds,ax
	Mov	es,ax
	Mov	fs,ax
	Mov	gs,ax
	Mov	ss,ax
	Mov	esp,[SysBaseTemp+SB_KernelStack]	; Set kernel stack...
	;
	Push dword	0x2000		; Clears #NT, #IF etc. and sets IOPL = Ring 2.
	PopFD			; Interrupts will be enabled when the first task is dispatched
	;
	Mov	eax,cr3
	Mov	[KernelCR3],eax
	Lea	eax,[KernelTSS]		; Move the pointer to the "scratch" TSS into the
	Mov	[TSS_DESC+2],ax		; TSS-descriptor, we will only use one.
	Shr	eax,16
	Mov	[TSS_DESC+4],al
	Mov	[TSS_DESC+7],ah
	Mov	ax,TSS_SEL
	LTr	ax		; Load the Task Register (TR)
	;
	Call	ProbeCPU
	Call	SetupIDT
	Call	SetupV86		; Initialize V86 descriptor
;;;	Call	SetupIRQs		; Don't enable this yet
	Call	InitSysBase

	Call	InitProcessList
	Call	InitDeviceList
	Call	InitLibraryList
	Call	InitDrivers
	;

;	Mov	eax,[SysBase+SB_VESA+VESA_MEMPTR]	; perhaps this shouldn't be here? its of no harm, just that we waste memory
;	Mov	ebx,0x800000		; that will be mapped again when we start the mga driver.
;	LIBCALL	MapMemory,ExecBase

;	Mov	eax,0xfee00000		; Map the local APic, needed for InitSMP
;	Mov	ebx,0x1000
;	LIBCALL	MapMemory,ExecBase

	;
	Call	ClearScreen
	Call	DebuggerInit
	;
;	Call	InitSMP
	;
	; New additions
	Call	InitScreenStruct
	;
;	Call	InitPCIList
;	Call	InitPNPList
;	Call	InitESCDList
;	Call	InitDMA
	;
	Call	KeybInit
	Call	PS2MouseInit
	Call	RTCInit
	Call	TimerInit
	Call	MountPartitions
	Call	InitTimer
	;
;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
	Mov	ebx,[SysBase+SB_CurrentProcess]
	Lea	ebx,[ebx+PC_Registers]
	Mov	[KernelTSSStack],esp
	Lea	esp,[ebx]
	PopAD
	POPX	ds,es,fs,gs		; getting ready to wave that chicken...
	IRetD			; waving the chicken....

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
InitSysBase	INITLIST	[SysBase+SB_IRQ3]
	INITLIST	[SysBase+SB_IRQ4]
	INITLIST	[SysBase+SB_IRQ5]
	INITLIST	[SysBase+SB_IRQ6]
	INITLIST	[SysBase+SB_IRQ7]
	INITLIST	[SysBase+SB_IRQ9]
	INITLIST	[SysBase+SB_IRQ10]
	INITLIST	[SysBase+SB_IRQ11]
	INITLIST	[SysBase+SB_IRQ12]
	INITLIST	[SysBase+SB_IRQ13]
	INITLIST	[SysBase+SB_IRQ14]
	INITLIST	[SysBase+SB_IRQ15]
	;
	INITLIST	[SysBase+SB_AllocatedMemList]
	INITLIST	[SysBase+SB_AssignList]
	INITLIST	[SysBase+SB_ClassList]
	INITLIST	[SysBase+SB_DeviceList]
	INITLIST	[SysBase+SB_DosList]
	INITLIST	[SysBase+SB_GfxDriverList]
	INITLIST	[SysBase+SB_LibraryList]
	INITLIST	[SysBase+SB_LockList]
	INITLIST	[SysBase+SB_MemoryFreeList]
	INITLIST	[SysBase+SB_PortList]
	INITLIST	[SysBase+SB_ResourceList]
	INITLIST	[SysBase+SB_ScreenList]
	INITLIST	[SysBase+SB_SegmentLoaders]
	INITLIST	[SysBase+SB_SemaphoreList]
	INITLIST	[SysBase+SB_TimerEventList]
	INITLIST	[SysBase+SB_TimerDeadList]
	INITLIST	[SysBase+SB_TimerServiceList]
	INITLIST	[SysBase+SB_FontList]
	INITLIST	[SysBase+SB_DMAList]
	;
	INITLIST	[SysBase+SB_DeadProcList]	; This has to change when we add support for several
	INITLIST	[SysBase+SB_ProcWaitList]	; processors, this has to be dynamically updated (Linked lists).
	INITLIST	[SysBase+SB_ReadyList]
	INITLIST	[SysBase+SB_TempList]
	;
	Lea	eax,[SysBase+SB_ReadyList]
	Lea	ebx,[SysBase+SB_TempList]
	Mov	[SysBase+SB_ProcReadyList],eax
	Mov	[SysBase+SB_ProcTempList],ebx
	;--
	Lea	eax,[SysBase+SB_MemoryFreeList]
	Lea	ebx,[0x100000]
	Mov dword	[ebx+ME_LENGTH],0x7f30000	; change this!!
	Mov dword	[ebx+ME_POINTER],0x100000
	ADDTAIL
	Mov dword	[SysBase+SB_MemoryFree],0x07fc0000	; change this!!
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ProbeCPU	Mov	eax,1
	CPUID
	Mov	[SysBase+SB_CPUID+CPUID_VERSION],eax
	Mov	[SysBase+SB_CPUID+CPUID_FEATURE],edx
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
InitPNPList	INITLIST	[SysBase+SB_PNPList]
	Lea	esi,[PNPTempBase]
	Mov	edx,[SysBase+SB_PNPNumNodes]
	Cld
	;
.L	Test	edx,edx
	Jz	.Done

	Mov	eax,1000
	Mov	ebx,MEMF_NOKEY
	LIBCALL	AllocMem,ExecBase
	Mov	edi,eax
	Push	edi
	Lea	edi,[edi+LN_SIZE]
	Push	esi
	Movzx	ecx,word [esi+PNPDN_LENGTH]
	Rep Movsb
	Pop	esi
	Add	esi,256
	Lea	eax,[SysBase+SB_PNPList]
	Pop	edi
	Mov	ebx,edi
	ADDTAIL
	Dec	edx
	Jmp	.L
.Done	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
InitESCDList	INITLIST	[SysBase+SB_ESCDList]
	Lea	esi,[PNPESCDBase]
	Movzx	edx,byte [esi+EISA_CFGHDR.BoardCount]		; Number of ESCD entrys
	Lea	esi,[esi+EISA_CFGHDR.SIZE]
	Cld
.L	Mov	eax,1000
	Mov	ebx,MEMF_NOKEY
	LIBCALL	AllocMem,ExecBase
	Mov	edi,eax
	Push	eax
	Lea	edi,[edi+LN_SIZE]
	Movzx	ecx,word [esi+EISA_FUNCTIONENTRY.Length]
	Rep Movsb
	Lea	eax,[SysBase+SB_ESCDList]
	Pop	ebx
	ADDTAIL
	Dec	edx
	Jnz	.L
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
MountPartitions	Lea	eax,[SysBase+SB_DosList]
	Lea	ebx,[BogusDosEntry]
	Lea	ecx,[PartitionN]
	Mov	[ebx+LN_NAME],ecx		; Partition name
	ADDTAIL
	;
	Lea	ecx,[F32FSProcTags]
	Lea	eax,[BogusDosEntry]	; Userdata=dosentry.. change this later..
	Mov	[ecx+4],eax
	LIBCALL	AddProcess,ExecBase
	;
	Call	IdeDevInit
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
BogusDosEntry	Times DE_SIZE Db	0
	Dd	DL_DEVNAME,DeviceN	; Devicename pointer
	Dd	DL_PARTITIONSTART,63	; Sector start that is.
	Dd	DL_PARTITIONEND,0		; Not used as of yet.
	Dd	DL_DEVUNIT,0
	Dd	DL_FLAGS,0
	Dd	TAG_DONE

DeviceN	Db	"ide.device",0
PartitionN	Db	"System",0

F32FSProcTags	Dd	AP_USERDATA,0
	Dd	AP_PROCESSPOINTER,F32FSStart
	Dd	AP_PRIORITY,0
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,4000
	Dd	AP_RING,2
	Dd	AP_QUANTUM,2
	Dd	AP_NAME,F32FSProcN
	Dd	TAG_DONE

F32FSProcN	Db	"FAT-32 FS Handler",0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Add internal devices to the device list.
;
InitDeviceList	Mov	eax,DEV_SIZE
	Mov	ebx,MEMF_NOKEY
	LIBCALL	AllocMem,ExecBase
	Mov	edx,eax
	Mov byte	[edx+LN_PRI],0
	Mov dword	[edx+LN_NAME],IdeDevName
	Mov byte	[edx+LN_TYPE],NT_DEVICE
	Mov dword	[edx+DEV_LIBTABLE],IdeDevFuncTable		;;;IdeDevInitTable
	Lea	eax,[SysBase+SB_DeviceList]
	Mov	ebx,edx
	ADDTAIL
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Add internal libraries to the library list
;

InitLibraryList	Lea	edi,[InitLibTable]
	XOr	esi,esi
.L	Cmp dword	[edi+esi],0
	Je	.Done
	;
	Mov	eax,LE_SIZE
	Mov	ebx,MEMF_NOKEY
	LIBCALL	AllocMem,ExecBase
	Mov	edx,eax
	Mov byte	[edx+LN_PRI],0
	Mov byte	[edx+LN_TYPE],NT_LIBRARY
	Mov	eax,[edi+esi]
	Mov	[edx+LN_NAME],eax
	Mov	eax,[edi+esi+4]
	Mov	[edx+LE_LIBVERSION],eax
	Mov	eax,[edi+esi+8]
	Mov	[edx+LE_LIBTABLE],eax
;	Call	[eax-4]	; open() the library
	Lea	eax,[SysBase+SB_LibraryList]
	Mov	ebx,edx
	ADDTAIL
	Lea	esi,[esi+12]
	Jmp	.L
.Done	Call	UIInit
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
InitLibTable	Dd	DosName,DosVersion,DosBase
	Dd	GfxName,GfxVersion,GfxBase
	Dd	UtilName,UtilVersion,UteBase
	Dd	UIName,UIVersion,UIBase
	Dd	TimerName,TimerVersion,TimerBase
	Dd	0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
InitDrivers	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
InitScreenStruct	Lea	eax,[ScreenStruct]
	INITLIST	[eax+SC_WindowList]

	Lea	eax,[SysBase+SB_ScreenList]
	Lea	ebx,[ScreenStruct]
	ADDTAIL
	Lea	eax,[ScreenStruct]
	Mov dword	[eax+SC_Width],1024
	Mov dword	[eax+SC_Height],768
	Mov dword	[eax+SC_Depth],1		; 8-bit's.
	Mov	ebx,[SysBase+SB_VESA+VESA_MEMPTR]
	Mov	[eax+SC_Address],ebx
	Lea	ebx,[ScreenColors]
	Mov	[eax+SC_Colors],ebx
	Lea	ebx,[ScreenPens]
	Mov	[eax+SC_Pens],ebx

	Lea	ebx,[WindowStruct]
	Mov	[ebx+WC_Screen],eax
	Bts dword	[ebx+WC_Flags],WCB_ROOT
	Mov dword	[ebx+CD_Width],1024
	Mov dword	[ebx+CD_Height],768

	Lea	eax,[eax+SC_WindowList]
	ADDTAIL
	Ret

ScreenStruct	Times SC_SIZE Db	0
WindowStruct	Times WC_SIZE Db	0

ScreenPens	Dd	PEN_WINDOW_BACKGROUND,0
	Dd	PEN_WINDOW_TEXT,1
	Dd	PEN_WINDOW_DARKSHADOW,2
	Dd	PEN_WINDOW_LIGHTSHADOW,3
	Dd	PEN_WINDOW_HIGHLIGHT,4
	Dd	PEN_WINDOW_ACTIVE,5
	Dd	PEN_WINDOW_ACTIVE2,6
	Dd	PEN_WINDOW_INACTIVE,7
	Dd	PEN_WINDOW_INACTIVE2,6
	Dd	PEN_MENU_BACKGROUND,5
	Dd	PEN_MENU_TEXT,4
	Dd	PEN_MENU_DARKSHADOW,3
	Dd	PEN_MENU_LIGHTSHADOW,2
	Dd	PEN_MENU_HIGHLIGHT,1
	Dd	PEN_MENU_SELECT,0
	Dd	PEN_OBJECT_HIGHLIGHT,2
	Dd	PEN_OBJECT_DARKSHADOW,2
	Dd	PEN_OBJECT_LIGHTSHADOW,3
	Dd	PEN_OBJECT_BACKGROUND,4
	Dd	PEN_OBJECT_SELECT,0
	Dd	PEN_OBJECT_TEXT,5
	Dd	-1

ScreenColors	Db	0,105,125,166	; Desktopbackground
	Db	0,  0,  0, 57	; Darkpen
	Db	0,227,227,255	; Highlightpen
	Db	0,117,117,162	; Windowbackground
	Db	0,178,178,202	; Objectbackground
	Db	0, 85,121,190	; Titlebarbackground
	Db	0,223,223,223	; Menubackground
	Db	0,142,138,182	; Buttonbackground
	Times 248 Dd	-1

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Add some test processes to the processlist.
;

InitProcessList:
;	Lea	ecx,[IdleProcTags]
;	LIBCALL	AddProcess,ExecBase

	Lea	ecx,[DebuggerProcTags]
	LIBCALL	AddProcess,ExecBase
	Mov	[SysBase+SB_FocusProcess],eax	; REMOVE THIS LATER



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Below this comment we can remove everything... Except for some taglists

	Lea	ecx,[TestProc1Tags]
	LIBCALL	AddProcess,ExecBase
	;
	Mov	ebx,[SysBase+SB_ProcReadyList]
	SUCC	ebx
	Mov	[SysBase+SB_CurrentProcess],ebx
	;
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Misc processes... Do NOT remove...
;

IdleProcTags	Dd	AP_PROCESSPOINTER,IdleProcess
	Dd	AP_PRIORITY,20
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,4000
	Dd	AP_RING,-1
	Dd	AP_QUANTUM,2
	Dd	AP_NAME,IdleProcN
	Dd	TAG_DONE
IdleProcN	Db	"idle",0

DebuggerProcTags	Dd	AP_PROCESSPOINTER,Debugger
	Dd	AP_PRIORITY,20
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,4000
	Dd	AP_RING,1
	Dd	AP_QUANTUM,2
	Dd	AP_NAME,DebuggerProcN
	Dd	TAG_DONE
DebuggerProcN	Db	"Debugger",0

TestProc1Tags	Dd	AP_PROCESSPOINTER,Task1
	Dd	AP_PRIORITY,0
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,4000
	Dd	AP_RING,3
	Dd	AP_QUANTUM,2
	Dd	AP_NAME,TestProc1N
	Dd	TAG_DONE
TestProc1N	Db	"Process #1",0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
Shutdown	In	al,KEYBP_CTRL
	Test	al,2
	Jne	Shutdown
	Mov	al,0xfc
	Mov	ecx,0xffff
.L	Out	KEYBP_CTRL,al
	Dec	ecx
	Jnz	.L
	LIDT	[0x666]
	Int	0x20
	Jmp	Shutdown

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
	Align	16		; NOTE: Must be aligned!
;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
KernelTSS	Dw	0,0		; Backlink
KernelTSSStack	Dd	0		; Esp0
	Dw	SYSDATA_SEL,0		; Ss0
	Dd	0		; Esp1
	Dw	0,0		; Ss1
	Dd	0		; Esp2
	Dw	0,0		; Ss2
KernelCR3	Dd	0		; Cr3
	Dd	0,0x200		; Eip, EFlags (#IF enabled)
	Dd	0,0,0,0		; Eax, Ecx, Edx, Ebx
	Dd	0,0,0,0		; Esp, Ebp, Esi, Edi
	Dw	0,0		; Es
	Dw	0,0		; Cs
	Dw	0,0		; Ss
	Dw	0,0		; Ds
	Dw	0,0		; Fs
	Dw	0,0		; Gs
	Dw	0,0		; LDT
	Dw	0,0		; Debug, I/O bitmap

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

SYSCODE1_SEL	Equ	$-GDTTable+1
	Dw	0xFFFF,0
	Db	0,0xBA		; Present, Ring1-Code, Non-conforming, Readable
	Db	0xCF,0

SYSDATA1_SEL	Equ	$-GDTTable+1
	Dw	0xFFFF,0
	Db	0,0xB2		; Present, Ring1-Data, Expand-up, Writable
	Db	0xCF,0

SYSCODE2_SEL	Equ	$-GDTTable+2
	Dw	0xFFFF,0
	Db	0,0xDA		; Present, Ring2-Code, Non-conforming, Readable
	Db	0xCF,0

SYSDATA2_SEL	Equ	$-GDTTable+2
	Dw	0xFFFF,0
	Db	0,0xD2		; Present, Ring2-Data, Expand-up, Writable
	Db	0xCF,0

SYSCODE3_SEL	Equ	$-GDTTable+3
	Dw	0xFFFF,0
	Db	0,0xFA		; Present, Ring3-Code, Non-conforming, Readable
	Db	0xCF,0

SYSDATA3_SEL	Equ	$-GDTTable+3
	Dw	0xFFFF,0
	Db	0,0xF2		; Present, Ring3-Data, Expand-up, Writable
	Db	0xCF,0

TSS_SEL	Equ	$-GDTTable
TSS_DESC	Dw	103,0		; Must be atleast 103 bytes, != #TS failure
	Db	0,0xE9		; Present, Ring3, 32-bit available TSS
	Db	0,0

V86TSS_SEL	Equ	$-GDTTable
V86TSS_DESC	Dw	0xffff,0
	Db	0,0x89		;0xE9
	Db	0,0

REALMODE_CODE_SEL	Equ	$-GDTTable
REALMODE_CODE	Dw	0xffff,0
	Db	0,0x9a		; Present, Ring0-Code, Non-conforming, Readable
	Db	0,0

REALMODE_DATA_SEL	Equ	$-GDTTable
REALMODE_DATA	Dw	0xffff,0
	Db	0,0x92		; Present, Ring0-Data, Expand-up, Writable
	Db	0,0


GDTLength:	; counter, don't remove.




;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
	%Include	"Debugger\Debugger.s"

	%Include	"Drivers\Drivers.s"

	%Include	"Kernel\DMA.s"
	%Include	"Kernel\Interrupts.s"
	%Include	"Kernel\PCI.s"
	%Include	"Kernel\PIC.s"
	%Include	"Kernel\Keyboard.s"
	%Include	"Kernel\PS2Mouse.s"
	%Include	"Kernel\RTC.s"
	%Include	"Kernel\SMP.s"
	%Include	"Kernel\Stubs.s"
	%Include	"Kernel\Timer.s"
	%Include	"Kernel\V86.s"

	%Include	"Devices\Devices.s"
	%Include	"FileSystems\Filesystems.s"

	%Include	"Libraries\Dos\Dos.s"
	%Include	"Libraries\Exec\Exec.s"
	%Include	"Libraries\Graphics\Graphics.s"
	%Include	"Libraries\Utility\Utility.s"
	%Include	"Libraries\Timer\Timer.s"
	%Include	"UserInterface\UserInterface.s"

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
