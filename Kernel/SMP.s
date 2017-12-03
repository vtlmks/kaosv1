;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     InitSMP.S V1.0.0
;
;     SMP Initializers.
;


APIC	Equ	0xfee00000

APIC_SPIV	Equ	0xf0
APIC_ESR	Equ	0x280
APIC_ICR	Equ	0x300
APIC_ICR2	Equ	0x310
APIC_TMICT	Equ	0x380
APIC_TMCCT	Equ	0x390
APIC_TDCR	Equ	0x3e0	; Timer divide configuration register

APIC_DEST_FIELD	Equ	0x0
APIC_DEST_DM_INIT	Equ	0x500
APIC_DEST_DM_STARTUP Equ	0x600
APIC_DEST_ASSERT	Equ	0x4000
APIC_DEST_LEVELTRIG Equ	0x8000

APIC_TDCR_MASK	Equ	0xf
APIC_TDR_DIV_1	Equ	0xb

PIT_TICKS_PER_SEC	Equ	0x1234dd

MSG_ALL_BUT_SELF	Equ	0x8000
MSG_ALL	Equ	0x8001

	Struc	MPFPS
.Signature	ResD	1	; "_MP_"
.PhysAddress	ResD	1	; Address to the "MP Configuration Table" structure, zero if non existant
.Length	ResB	1	; Length of the structure in Paragraphs (16 byte) units..  should be 1.
.Spec_Rev	ResB	1	; MP Specification version, 0x1 or 0x4, 1.1 or 1.4 respectively.
.Checksum	ResB	1	; Checksum.
.MPFeatureByte1	ResB	1	; MP System configuration type, if not MP Configuration Table is present.
.MPFeatureByte2	ResB	1	; Bit 7 - IMCRP, 1 = PIC mode; 0 = Virtual Wire mode.
.MPFeatureByteRes	ResB	3	; Reserved.
.Size	EndStruc

	Struc	MPCT
.Signature	ResD	1	; "PCMP"
.BaseTableSize	ResW	1	; Length of Base configuration Table in bytes.
.Spec_Rev	ResB	1	; The version number of the MP specification. 0x1 or 0x4, look above.
.Checksum	ResB	1	; Checksum.
.OEMID	ResB	8	; A string that identifies the manufacturer of the system hardware.
.ProductID	ResB	12	; A string that identifies the product family.
.OEMTablePointer	ResD	1	; Physical address pointer to an OEM-defined configuration table.
.OEMTableSize	ResW	1	; The size of the base OEM table in bytes.
.EntryCount	ResW	1	; Number of entrys in the variable portion of the Base Table.
.LocalAPICAddress	ResD	1	; The base address by which each processor accesses it's local apic.
.ExtTableLength	ResW	1	; Length in bytes of the extended entries taht are located in memory at the end of the base configuration table.
.ExtTableChecksum	ResB	1	; Checksum...
	ResB	1	; Reserved
.Size	EndStruc

	Struc	PE
.Entry_Type	ResB	1
.LocalAPICID	ResB	1
.LocalAPICVersion	ResB	1
.CPUFlags	ResB	1
.CPUSignature	ResD	1
.Features	ResD	1
.Reserved	ResD	2
.Size	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
InitSMP	Call	smp_Probe
	Test	eax,eax
	Jz	.NoSMP
	Call	smp_ReadConfig
	Call	smp_SetupAPics

	Call	smp_StartAPs
.NoSMP	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
smp_Probe	Lea	edx,[SMPAreas]
.Loop	Mov	esi,[edx]
	Cmp	esi,-1
	Je	.NotFound
	Mov	ecx,[edx+4]

.MPLoop	Lodsd
	Cmp	eax,"_MP_"
	Je	.Found
	Dec	ecx
	Jne	.MPLoop

	Lea	edx,[edx+8]
	Jmp	.Loop

.Found	Lea	eax,[esi-4]
	Mov	[SysBase+SB_SMPPointer],eax
	Ret

.NotFound	XOr	eax,eax
	Mov dword	[SysBase+SB_SMPPointer],eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
smp_ReadConfig	Mov	eax,[SysBase+SB_SMPPointer]
	Mov	eax,[eax+MPFPS.PhysAddress]
	Mov	ecx,[eax+MPCT.EntryCount]
	Lea	esi,[eax+MPCT.Size]

	PushAD
	Mov	eax,[eax+MPCT.LocalAPICAddress]
	Int	0xfe
	PopAD

.Loop	Movzx	eax,byte [esi]
	Cmp	eax,4
	Ja	.Mo
	Mov	ebx,[CallTable+eax*4]
	Call	ebx

.Mo	Dec	ecx
	Jnz	.Loop
	Ret

CallTable	Dd	ProcessorConfig
	Dd	BusConfig
	Dd	APICConfig
	Dd	IRQConfig
	Dd	LocalIrqConfig

ProcessorConfig	Push	eax
	Lea	eax,[ProcessorN]
	Int	0xff
	Movzx	eax,byte [esi+PE.LocalAPICID]
	Int	0xfe
	Lea	eax,[APicVersionN]
	Int	0xff
	Movzx	eax,byte [esi+PE.LocalAPICVersion]
	Int	0xfe
	Lea	eax,[ProcessorSignN]
	Int	0xff
	Mov	eax,[esi+PE.CPUFlags]
	Int	0xfe

	Movzx	eax,byte [esi+PE.CPUFlags]
	Bt	eax,0
	Jnc	.NotUnusable

.NotUnusable	Bt	eax,1
	Jnc	.NotBSP
	Push	eax
	Lea	eax,[BSPN]
	Int	0xff
	Pop	eax

.NotBSP	Pop	eax
	Lea	esi,[esi+0x14]
	Ret

BusConfig	Lea	esi,[esi+0x8]
	Ret

APICConfig	Lea	esi,[esi+0x8]
	Ret

IRQConfig	Lea	esi,[esi+0x8]
	Ret

LocalIrqConfig	Lea	esi,[esi+0x8]
	Ret

ProcessorN	Db	0xa,0xa,'Found processor:              APIC ID 0x',0
APicVersionN	Db	'                         APIC Version 0x',0
ProcessorSignN	Db	'                  Processor signature 0x',0
BSPN	Db	' This processor is the BootStrapProcessor.',0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
smp_SetupAPics	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
smp_StartAPs	Lea	esi,[Ko80000]
	Lea	edi,[0x80000]
	Mov	ecx,(koend-Ko80000+3)/4
	Mov	ecx,400
	Rep Movsd
	Mov dword	[0x70000],0

	; jump to symetric mode.
	Mov	al,0x70
	Out	0x22,al
	Mov	al,0x01
	Out	0x23,al
	; Initialize local APIC
	;
	Mov	eax,[APIC+APIC_SPIV]
	Or	eax,0x100
	Mov	[APIC+APIC_SPIV],eax
	; Clearing APIC errors
	;
	Mov dword	[APIC+APIC_ESR],0
	Mov	eax,[APIC+APIC_ESR]

	Mov	eax,1
	Mov	ebx,APIC_DEST_LEVELTRIG
	Mov	ecx,APIC_DEST_ASSERT|APIC_DEST_DM_INIT
	Call	smp_SendIPI

;	udelay(200);
	Mov	edi,0x2000
.L3	nop
	nop
	nop
	nop
	Dec	edi
	Jnz	.L3

	Mov	eax,1
	Mov	ebx,APIC_DEST_LEVELTRIG
	Mov	ecx,APIC_DEST_DM_INIT
	Call	smp_SendIPI

	Mov	edx,2
.InitLoop	Mov dword	[APIC+APIC_ESR],0

	Mov	eax,1
	Mov	ebx,0
	Mov	ecx,APIC_DEST_DM_STARTUP+0x80
	Call	smp_SendIPI

	Mov	ecx,1000
.Loop	Mov	edi,0x100	; uDelay(10)
.L	nop
	nop
	nop
	nop
	Dec	edi
	Jnz	.L

	Mov	eax,[APIC+APIC_ICR]
	Bt	eax,12
	Jnc	.Exit
	Dec	ecx
	jnz	.Loop
.Exit	Mov	edi,0x2000	; uDelay(200);
.L2	nop
	nop
	nop
	nop
	Dec	edi
	Jnz	.L2

	; check that the destination processor got the message
	Mov	eax,[APIC+APIC_ESR]
	Test	eax,eax
	Jz	.Started
	Dec	edx
	Jnz	.InitLoop

	Ret

.Started	Lea	eax,[ApStarted]
	Int	0xff
	Ret

ApStarted	Db	'AP #0x01 started...',0xa,0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;

	Struc IPIStruct
ipi_Target	ResD	1	; Target processor
ipi_DeliverMode	ResD	1	; Delivermode
ipi_IntNum	ResD	1	; What??
ipi_SIZE	Endstruc

smp_SendIPI	PushAD
	LINK	ipi_SIZE

	Mov	[ebp+ipi_Target],eax
	Mov	[ebp+ipi_DeliverMode],ebx
	Mov	[ebp+ipi_IntNum],ecx

	; Wait for APIC to become ready
	Mov	ecx,10000
.Loop	Mov	edi,0x10	; uDelay(10)
.L	nop
	nop
	nop
	nop
	Dec	edi
	Jnz	.L

	Mov	eax,[APIC+APIC_ICR]
	Bt	eax,12
	Jnc	.ApicReady
	Dec	ecx
	jnz	.Loop
	Lea	eax,[APICErrorN]
	Int	0xff
	Stc
	Jmp	.Exit

.ApicReady	Mov	eax,[APIC+APIC_ICR2]
	And	eax,0xffffff
	Mov	ebx,[ebp+ipi_Target]
	Shl	ebx,24
	Or	eax,ebx
	Mov	[APIC+APIC_ICR2],eax

	Mov	eax,[APIC+APIC_ICR]
	And	eax,~0xfdfff
	Or	eax,APIC_DEST_FIELD
	Or	eax,[ebp+ipi_DeliverMode]	; Delivermode
	Or	eax,[ebp+ipi_IntNum]	; Interrupt Number
	Mov	[APIC+APIC_ICR],eax	; check if we are to send to all processors or not.

.Exit	UNLINK	ipi_SIZE
	PopAD
	Ret

APICErrorN	Db	'APIC was not ready when sending STARTUP_IPI....',0xa,0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
smp_Syncronize	Ret

Ko80000	Incbin	"kernel\SMPInit.bin"
koend:

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SMPAreas	Dd	0,255	; offset, NumLongs(1kb)
	Dd	639*1024,255	; last KB in system base memory (640kb)
	Dd	0xf0000,16383	; BIOS Read-Only memory space, 0xF0000->0xFFFFF.
	Dd	-1


