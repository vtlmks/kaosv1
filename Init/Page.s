;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Page.I V1.0.0
;
;     Page Directory and Page Table setup routines.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
InitPaging	Mov	ax,SYSDATA_SEL
	Mov	ds,ax
	Mov	es,ax
	Cld		; Paranoia...

	Call	Init
	Call	InitPD
	Call	InitPT
	Call	InitKernelPT
	;-

	;- setting up MTRR ----

;	0x200+2*reg	; base
;	0x200+2*reg+1	; mask

;#define MTRRcap_MSR     0x0fe
;#define MTRRdefType_MSR 0x2ff
;
;#define MTRRphysBase_MSR(reg) (0x200 + 2 * (reg))
;#define MTRRphysMask_MSR(reg) (0x200 + 2 * (reg) + 1)
;
;#define NUM_FIXED_RANGES 88
;#define MTRRfix64K_00000_MSR 0x250
;#define MTRRfix16K_80000_MSR 0x258
;#define MTRRfix16K_A0000_MSR 0x259
;#define MTRRfix4K_C0000_MSR 0x268
;#define MTRRfix4K_C8000_MSR 0x269
;#define MTRRfix4K_D0000_MSR 0x26a
;#define MTRRfix4K_D8000_MSR 0x26b
;#define MTRRfix4K_E0000_MSR 0x26c
;#define MTRRfix4K_E8000_MSR 0x26d
;#define MTRRfix4K_F0000_MSR 0x26e
;#define MTRRfix4K_F8000_MSR 0x26f

	Mov	eax,cr0	; fuck caches...
	Or	eax,0x40000000
	Wbinvd
	Mov	cr0,eax
	Wbinvd

	XOr	edx,edx
	Mov	eax,0xe8000001
	Mov	ecx,0x200
	WRMSR

	Mov	edx,0x0000000f
	Mov	eax,0xff800800
	Mov	ecx,0x201
	WRMSR

	XOr	edx,edx
	XOr	eax,eax
	Or	eax,100000000110b
	Mov	ecx,0x2ff
	WRMSR

	Mov	eax,cr0	; gimme cache
	And	eax,0xbfffffff
	Mov	cr0,eax

	;-
	Mov	eax,PDPointer
	Mov	eax,[ds:eax]
	Mov	cr3,eax
	Mov	eax,cr0
	Or	eax,1<<31
	Mov	cr0,eax
	;

	XOr	eax,eax
	CPUId
	bt	edx,CPUIDB_PGE
	Jz	.NoGlobal
	Mov	eax,cr4
	Or	eax,10000000b	; enable Global pages....
	Mov	cr4,eax
.NoGlobal	Ret


	align	16
PhysBase	Dd	0x00000000,0xe8000001
PhysMask	Dd	0x0000000f,0xff800800

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
;0. Make sure we have enough memory for the PD and PT's
;
;1. number of PD entrys, entire memory-512kb
;2. Create pointers to enough PT's
;
;3. Create the last PD entry to point to one PT.
;
; . Save pointers for the PT setup routines.
;

PBT	Equ	0x80000	; Temporary space for misc page pointers..


NumberOfPDE	Equ	PBT+0
NumberOfPTE	Equ	PBT+4
PDPointer	Equ	PBT+8
PTPointer	Equ	PBT+12
KernelPTPointer	Equ	PBT+16
VesaPTPointer	Equ	PBT+20
KernelEntry	Equ	PBT+24
KernelSize	Equ	PBT+28
VesaEntry	Equ	PBT+32

	; Calculate the number of tables and directory entries to be used...
	;
Init	Mov	eax,SysBaseTemp+SB_MemoryTotal
	Mov	eax,[ds:eax]
	Shr	eax,12
	Mov	edx,NumberOfPTE
	Mov	[ds:edx],eax
	;-
	Shr	eax,10
	Mov	edx,NumberOfPDE
	Mov	[ds:edx],eax
	;
	; Calculate the start offset for the kernelstack and the page directory/tables
	;
	Inc	eax	; Add one 4kb entry for the PD
	Shl	eax,12
	And	eax,0xffff0000	; Round it off to a 64k boundary
	Add	eax,0x10000	; to have at least 64kb for pages & pagedirectory
	;-
	Mov	ecx,KernelEntry	;
	Mov	ecx,[ds:ecx]	; Fetch Kernel start pointer
	Mov	edx,SysBaseTemp+SB_KernelStack
	Mov	[ds:edx],ecx
	Sub	ecx,8192	; The kernelstack is 8kb; before fucking up any PT's...
	;-
	Sub	ecx,eax	; To get the PD pointer.
	Mov	edx,PDPointer	;
	Mov	ebx,SysBaseTemp+SB_PDPointer
	Mov	[ds:edx],ecx	; Save the PDPointer
	Mov	[ds:ebx],ecx	; Save the PDPointer to the SysBase [ For MapMemory() etc.]
	Add	ecx,0x1000	; Add to get the first Pagetable
	Mov	edx,PTPointer	;
	Mov	[ds:edx],ecx	; Save the PTPointer
	;-
	Mov	edx,NumberOfPDE	;
	Mov	edx,[ds:edx]	;
	Inc	edx	; add two(?) 4kb blocks for the PD and Kernel-PT.
	Shl	edx,12	;
	Add	ecx,edx	;
	Mov	edx,KernelPTPointer
	Mov	[ds:edx],ecx	;
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
InitPD	Mov	edi,PDPointer
	Mov	edi,[ds:edi]
	Mov	ecx,NumberOfPDE
	Mov	ecx,[ds:ecx]
	Inc	ecx
	Mov	eax,PTPointer
	Mov	eax,[ds:eax]
	Or	eax,111b	; User/Supervisor, Read/Write, Present
.Loop	A32 Stosd
	Lea	eax,[eax+0x1000]
	Dec	ecx
	Jnz	.Loop
	;
	Mov	edi,PDPointer
	Mov	edi,[ds:edi]
	Lea	edi,[edi+0xffc]	; 0x3ff<<2
	Mov	eax,KernelPTPointer
	Mov	eax,[ds:eax]
	Or	eax,111b	; User/Supervisor, Read/Write, Present
	Mov	[ds:edi],eax
	;
	Mov	edi,PDPointer
	Mov	edi,[ds:edi]
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
InitPT	Mov	edi,PTPointer
	Mov	edi,[ds:edi]
	Mov	ecx,NumberOfPTE
	Mov	ecx,[ds:ecx]
	Mov	eax,100000111b	; Global, User/Supervisor, Read/Write, Present
.Loop	A32 Stosd
	Lea	eax,[eax+0x1000]
	Dec	ecx
	Jnz	.Loop
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
InitKernelPT	Mov	edi,KernelPTPointer
	Mov	edi,[ds:edi]
	Lea	edi,[edi+0x800]		; was 0xe00
	Mov	ecx,128
	Mov	eax,KernelEntry
	Mov	eax,[ds:eax]
	And	eax,0xffff0000
	Or	eax,100000111b	; Global, User/Supervisor, Read/Write, Present
.Loop	A32 Stosd
	Lea	eax,[eax+0x1000]
	Dec	ecx
	Jnz	.Loop
	Ret
