%ifndef Includes_SysBase_I
%define Includes_SysBase_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     SysBase.I V1.0.0
;
;     SysBase information.
;

%ifndef Includes_TypeDef_I
%include "Includes\TypeDef.I"
%endif

SysBase	Equ	0x404
SysBaseTemp	Equ	0x90000

PNPTempBase	Equ	0x200000	; Tempspace for PnP, should be safe
PNPESCDBase	Equ	0x210000	; Tempspace for PnP ESCD data

	Struc VESA
VESA_MEMPTR	ResD	1	; Pointer to VESA memory.
VESA_SIZE	EndStruc

	Struc Screen
	ResB	LN_SIZE
SC_WindowList	ResB	LH_SIZE	; List of windows
SC_Driver	ResD	1	; Driver for this screen
SC_Address	ResD	1	; Screen Memory address
SC_Pens	ResD	1	; Pointer to array of pens or null
SC_Colors	ResD	1	; Pointer to array of colors..
SC_Width	ResD	1	; Dimension
SC_Height	ResD	1	; Dimension
SC_Flags	ResD	1	; Flagset, see below
SC_Depth	ResD	1	; Screen depth 1,2 or 4 (8, 16 or 32 bits)
SC_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc CPUIDInfo
CPUID_VERSION	ResD	1	; CPU Version information
CPUID_FEATURE	ResD	1	; CPU Feature Flagset, see below
CPUID_SIZE	EndStruc

	;
	; CPUID_FEATURE flagset
	;

	BITDEF	CPUID,FPU,0	; Floating Point Unit on Chip
	BITDEF	CPUID,VME,1	; Virtual 8086 Mode Enhancements
	BITDEF	CPUID,DE,2	; Debugging Extensions
	BITDEF	CPUID,PSE,3	; Page Size Extensions
	BITDEF	CPUID,TSC,4	; Time Stamp Counter
	BITDEF	CPUID,MSR,5	; Model Specific Registers
	BITDEF	CPUID,PAE,6	; Physical Address Extension
	BITDEF	CPUID,MCE,7	; Machine Check Exception
	BITDEF	CPUID,CX8,8	; CMPXCHG8B Instruction Support
	BITDEF	CPUID,APIC,9	; Processor contains an on-chip APIC
	BITDEF	CPUID,SEP,11	; Fast System Call, support for SYSENTER and SYSEXIT
	BITDEF	CPUID,MTRR,12	; Memory Type Range Registers
	BITDEF	CPUID,PGE,13	; PTE Global Flag (CR4.PGE flag)
	BITDEF	CPUID,MCA,14	; Machine Check Architecture
	BITDEF	CPUID,CMOV,15	; Conditional Move and Compare Instructions
	BITDEF	CPUID,FGPAT,16	; Page Attribute Table
	BITDEF	CPUID,PSE36,17	; 36-bit Page Size Extension
	BITDEF	CPUID,PN,18	; Processor Number
	BITDEF	CPUID,MMX,23	; MMX Technology
	BITDEF	CPUID,FXSR,24	; Fast FP/MMX Technology/Streaming SIMD Extensions save/restore
	BITDEF	CPUID,XMM,25	; Streaming SIMD Extensions support


	;
	; x86 EFlags flags
	;
	BITDEF	EFLAG,C,0
	; 1
	BITDEF	EFLAG,PF,2
	; 3
	BITDEF	EFLAG,AF,4
	; 5
	BITDEF	EFLAG,Z,6
	BITDEF	EFLAG,N,7
	BITDEF	EFLAG,T,8
	BITDEF	EFLAG,I,9
	BITDEF	EFLAG,D,10
	BITDEF	EFLAG,V,11
;	BITDEF	EFLAG,IOPL,12	; eh? 3000??
	; 12
	; 13
	BITDEF	EFLAG,NT,14
	; 15
	BITDEF	EFLAG,RF,16
	BITDEF	EFLAG,VM,17
	BITDEF	EFLAG,AC,18
	BITDEF	EFLAG,VIF,19
	BITDEF	EFLAG,VIP,20
	BITDEF	EFLAG,ID,21

EFDF_C	Equ	0x1	; carry flag
EFDF_PF	Equ	0x4	; parity flag
EFDF_AF	Equ	0x10	; auxiliary carry flag
EFDF_Z	Equ	0x40	; zero flag
EFDF_N	Equ	0x80	; sign flag
EFDF_T	Equ	0x100	; trap flag
EFDF_I	Equ	0x200	; interrupt enable flag
EFDF_D	Equ	0x400	; direction flag
EFDF_V	Equ	0x800	; overflow flag
EFDF_IOPL	Equ	0x3000	; i/o privilege level
EFDF_NT	Equ	0x4000	; nested task
EFDF_RF	Equ	0x10000	; resume flag
EFDF_VM	Equ	0x20000	; virtual 8086 mode
EFDF_AC	Equ	0x40000	; alignment check flag
EFDF_VIF	Equ	0x80000	; virtual interrupt enable flag
EFDF_VIP	Equ	0x100000	; virtual interrupt pending flag
EFDF_ID	Equ	0x200000	; identification flag




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc SysBaseStruct
;;	ResB	1024	; BIOS Interrupt table
	ResD	1
SB_IntTable	ResB	2048	; Interrupt Table
	;-- System Lists
SB_AllocatedMemList ResB	MLH_SIZE	; Allocated Memory Listheader
SB_AssignList	ResB	MLH_SIZE	; List of assigns
SB_ClassList	ResB	MLH_SIZE	; List of open Classes
SB_DeviceList	ResB	MLH_SIZE	; List of open Devices
SB_DosList	ResB	MLH_SIZE	; List of mounted devices
SB_LockList	ResB	MLH_SIZE	; List of locked files/directories
SB_GfxDriverList	ResB	MLH_SIZE	; List of graphicsdrivers
SB_LibraryList	ResB	MLH_SIZE	; List of open Libraries
SB_MemoryFreeList	ResB	MLH_SIZE	; Memory listheader
SB_PortList	ResB	MLH_SIZE	; List of public ports
SB_ResourceList	ResB	MLH_SIZE	; List of resources
SB_ScreenList	ResB	MLH_SIZE	; List of opened Screens
SB_SemaphoreList	ResB	MLH_SIZE	; List of Public Semaphores
SB_TimerEventList	ResB	MLH_SIZE	; List of pending timer events
SB_TimerDeadList	ResB	MLH_SIZE	; List of dead timer events (timed out)
SB_TimerServiceList ResB	MLH_SIZE	; List of timer service requests
SB_FontList	ResB	MLH_SIZE	; List of open fonts
SB_DMAList	ResB	MLH_SIZE	; List of DMA channels
	;--
SB_DeadProcList	ResB	MLH_SIZE	; List of processes to be removed.
SB_ProcWaitList	ResB	MLH_SIZE	; List of waiting Processes
SB_ReadyList	ResB	MLH_SIZE	; List of ready Processes
SB_TempList	ResB	MLH_SIZE	; List of temporary Processes
	;--
SB_IRQ3	ResB	MLH_SIZE	; List of IRQ3 handlers
SB_IRQ4	ResB	MLH_SIZE	; List of IRQ4 handlers
SB_IRQ5	ResB	MLH_SIZE	; List of IRQ5 handlers
SB_IRQ6	ResB	MLH_SIZE	; List of IRQ6 handlers
SB_IRQ7	ResB	MLH_SIZE	; List of IRQ7 handlers
SB_IRQ9	ResB	MLH_SIZE	; List of IRQ9 handlers
SB_IRQ10	ResB	MLH_SIZE	; List of IRQ10 handlers
SB_IRQ11	ResB	MLH_SIZE	; List of IRQ11 handlers
SB_IRQ12	ResB	MLH_SIZE	; List of IRQ12 handlers
SB_IRQ13	ResB	MLH_SIZE	; List of IRQ13 handlers
SB_IRQ14	ResB	MLH_SIZE	; List of IRQ14 handlers
SB_IRQ15	ResB	MLH_SIZE	; List of IRQ15 handlers
	;--
SB_PCIList	ResB	MLH_SIZE	; List of PCI peripherals
	;--
SB_SpinLock	ResD	1	;
SB_DisableTemp	ResD	1	; Disable counter
SB_PIDCount	ResD	1	; PID wrap counter
	;--
SB_ProcReadyList	ResD	1	; Pointer to list of ready processes
SB_ProcTempList	ResD	1	; Pointer to list of temporary processes
	;--
SB_KernelSize	ResD	1	; Size of Kernel rounded to 64kb
SB_KernelStack	ResD	1	; Kernel stack pointer
SB_PDPointer	ResD	1	; PageDirectory pointer
SB_BIOSEquipment	ResD	1	; BIOS equipment bitfield, see below
SB_CPUID	ResB	CPUID_SIZE
SB_MemoryTotal	ResD	1	; Total memory in bytes
SB_MemoryFree	ResD	1	; Total free memory in bytes
SB_CurrentProcess	ResD	1	; Pointer to current process
SB_FocusProcess	ResD	1	; Pointer to the process in focus.
SB_FocusWindow	ResD	1	; Pointer to the window in focus
	;--
SB_CheckSum	ResD	1
SB_Uptime	ResD	2	; Uptime in seconds, second long contains internal count for RTC
SB_Load	ResD	3	; Load 5/15/60 Minutes
SB_IdleCount	ResD	1
SB_DispatchCount	ResD	2	; Increased by scheduler with one, quadword
SB_ProcessCount	ResD	1	; Number of processes running/waiting
	;--
SB_SMPPointer	ResD	1	; Pointer to _MP_ structure, or zero if none found.
	;--
SB_SegmentLoaders	ResB	MLH_SIZE	; List of Segmentloaders
	;--
SB_VESA	ResB	VESA_SIZE
SB_PNPNumNodes	ResD	1	; PNP Number of Nodes
SB_PNPList	ResB	MLH_SIZE	; PNP Configuration List
SB_ESCDList	ResB	MLH_SIZE	; PNP ESCD configuration
SB_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; BIOS equipment bitfield

 BITDEF	SBBE,Floppy,	0	; Floppy disks installed, number in bits 6-7
 BITDEF	SBBE,FPU,	1	; 80x87 FPU coprocessor installed
 BITDEF	SBBE,PS2Mouse,	2	; PS/2 mouse installed
 BITDEF	SBBE,InitialVM1,	4	; Initial videomode (lsb)
 BITDEF	SBBE,InitialVM2,	5	; Initial videomode (msb)
 BITDEF	SBBE,Floppys1,	6	; Number of floppys (lsb)
 BITDEF	SBBE,Floppys2,	7	; Number of floppys (msb)
 BITDEF	SBBE,SerPorts1,	9	; Number of serialports (lsb)
 BITDEF	SBBE,SerPorts2,	10	; Number of serialports
 BITDEF	SBBE,SerPorts3,	11	; Number of serialports (msb)
 BITDEF	SBBE,ParPorts1,	14	; Number of parallellports (lsb)
 BITDEF	SBBE,ParPorts2,	15	; Number of parallellports (msb)

 BITDEF	SL,AllocMem,0

 BITDEF	LH,SLOCK,0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%endif
