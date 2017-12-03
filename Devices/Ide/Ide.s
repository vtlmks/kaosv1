;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     IDE.s V1.0.0
;
;     Ide.device with LBA translation, compatible with
;     sectorsizes at 512 bytes using PIO-X transfers.
;


	%Include	"Includes\Devices\Ide.I"


IdeDevVersion	Equ	1
IdeDevRevision	Equ	1

	XOr	eax,eax
	Ret

IdeDevTag	Dd	LT_FLAGS,0
	Dd	LT_VERSION,IdeDevVersion
	Dd	LT_REVISION,IdeDevRevision
	Dd	LT_TYPE,NT_DEVICE
	Dd	LT_PRIORITY,0
	Dd	LT_NAME,IdeDevName
	Dd	LT_IDSTRING,IdeDevIDString
	Dd	LT_INIT,IdeDevInitTable
	Dd	TAG_DONE

IdeDevInitTable	Dd	ided_SIZE
	Dd	IdeDevTag
	Dd	IdeDevFuncTable
	Dd	IdeDevInit
	;
	Dd	IdeDevTable
	Dd	-1

IdeDevName	Db	"ide.device",0
IdeDevIDString	Db	"ide.device 1.1 (2000-09-22)",0

IdeDevTable	Dd	0	; Pointer to devicememory


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevice	Mov	ebp,[IdeDevFuncTable+edi]
	Call	ebp
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Dd	-1		; -36
	;
	Dd	IdeAbortIO		; -32
	Dd	IdeBeginIO		; -28
	;
	Dd	IdeDevNull		; -24
	Dd	IdeDevNull		; -20
	Dd	IdeDevNull		; -16
	Dd	IdeDevExpunge		; -12
	Dd	IdeDevClose		; -8
	Dd	IdeDevOpen		; -4
IdeDevFuncTable:

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevCommands	Dd	IdeDevCmdInvalid		; CMD_INVALID
	Dd	IdeDevCmdReset		; CMD_RESET
	Dd	IdeDevCmdRead		; CMD_READ
	Dd	IdeDevCmdWrite		; CMD_WRITE
	Dd	IdeDevCmdUpdate		; CMD_UPDATE
	Dd	IdeDevCmdClear		; CMD_CLEAR
	Dd	IdeDevCmdStop		; CMD_STOP
	Dd	IdeDevCmdStart		; CMD_START
	Dd	IdeDevCmdFlush		; CMD_FLUSH
	Dd	-1


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeLibOpenCount	Dd	0


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevInit	Call	IdeMountPCIDevs
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevOpen	Cmp dword	[IdeLibOpenCount],0	; *OBS** Enable these later on!!
	Jne	.AlreadyOpened
	;
	Push	ebx
	Mov	eax,ided_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	edx,eax
	Pop	ebx
	Mov	[IdeDevTable],eax
	Mov	[edx+ided_IORequest],ebx	; User IORequest (ebx from OpenDevice()).
	;
	XOr	eax,eax
	LIBCALL	FindProcess,ExecBase
	Mov	[edx+ided_UserProc],eax
	;
	Bts dword	[ebx+IO_FLAGS],IOB_WAITREQUIRED
	;
	Lea	eax,[IdeDevProcTags]
	LIBCALL	CloneTaglist,UteBase
	Push	eax
	Mov	[eax+4],edx		; Device memorypointer as userdata
	Mov	ecx,eax
	LIBCALL	AddProcess,ExecBase
	Pop	eax
	LIBCALL	FreeTaglist,UteBase

	LIBCALL	Sleep,ExecBase
	;-
.AlreadyOpened	Inc dword	[IdeLibOpenCount]
	Ret


IdeDevProcTags	Dd	AP_USERDATA,0
	Dd	AP_PROCESSPOINTER,IdeDevDaemon
	Dd	AP_PRIORITY,0
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,1024
	Dd	AP_RING,2
	Dd	AP_QUANTUM,2
	Dd	AP_NAME,IdeDevName
	Dd	TAG_DONE

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevClose	Mov dword	[ebx+IO_DEVICE],0
	Dec dword	[IdeLibOpenCount]
	Jz	IdeDevExpunge
	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	; send KILL to the daemon
	; free up some memory etc..
	; return -1 to eax so the CloseDevice() can unlink us from the devicelist.
	;
IdeDevExpunge	Mov	eax,-1
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevNull	XOr	eax,eax
	Ret


	Struc IDEDevice
ided_MsgPort	ResD	1	; Messageport of the device
ided_IORequest	ResD	1	; Current I/O request structure
ided_UserProc	ResD	1	; Userprocess to awake
ided_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevDaemon	LIBCALL	CreateMsgPort,ExecBase
	Mov	[edx+ided_MsgPort],eax

	Mov	eax,[edx+ided_UserProc]
	LIBCALL	Awake,ExecBase

	;
.Main	LIBCALL	Wait,ExecBase
.L	LIBCALL	GetMsg,ExecBase
	Test	eax,eax
	Jz	.Main
	Mov	ebx,[eax+MN_PORTID]
	Mov	ecx,[edx+ided_MsgPort]
	Cmp	ebx,[ecx+MP_ID]
	Jne	.NoIdeMessage

	Mov	[edx+ided_IORequest],eax	; edx holds pointer to device memory
	;			; don't trash it..
	Mov	ebx,[eax+IO_COMMAND]
	Mov	ebx,[IdeDevCommands+ebx*4]
	Push	edx
	Call	ebx
	Pop	edx
	;
.NoIdeMessage	Mov	eax,[edx+ided_IORequest]
	LIBCALL	ReplyMsg,ExecBase
	Jmp	.L


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevFunction1	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; BeginIO adds new I/O requests the list using a PutMsg() to the device "daemon"
; port. BeginIO will be called using SendIO() and should return at once.
;
; Input:
;  eax = I/O request structure
;
; Output:
;  None
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeBeginIO	PUSHX	ebx,edx
	Push	eax
	Mov	edx,[IdeDevTable]
	Mov	eax,[edx+ided_MsgPort]	; Device messageport
	Pop	ebx		; Message containing I/O structure
	LIBCALL	PutMsg,ExecBase
	POPX	ebx,edx
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeAbortIO	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevCmdInvalid	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevCmdReset	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; CMD_READ: Read requested sector(s) with LBA translation.
;
; Input:
;  IO_OFFSET = Sector number to read
;  IO_LENGTH = Number of sectors to read (0-255), where 0 will give 256 sectors
;  IO_DATA   = Pointer to buffer
;  IO_UNIT   = Unit number (0-3)
;
; Output:
;  IO_DATA   = Filled
;  IO_ERROR  = Null or error code
;  IO_LENGTH = Amount of bytes read
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevCmdRead	Mov	ebx,[edx+ided_IORequest]	; Pointer to I/O Request, *don't trash it*
	Call	ider_ReadInit
	Push	edx
	Mov	edx,[ebx+IO_UNIT]
	Mov	edx,[IdeDevPortTable+esi*4]
	Lea	edx,[edx+IDEP_Command]
	Mov	al,IDEC_RSWOR		; Read sector(s) with retry
	Out	dx,al
	Pop	edx
	;
	Call	ider_WaitReady		; Wait for DRQ
	Jc	.Failed
	;
	;
	PushAD
	Mov	esi,[ebx+IO_UNIT]
	Mov	esi,[IdeDevPortTable+esi*4]	; Get IDE dataport, i.e. 0x1f0
	Mov	edi,[ebx+IO_DATA]
	Mov	ebp,[ebx+IO_LENGTH]
	Test	ebp,ebp		; A length 0f null is translated to 256 sectors
	Jnz	.ReadL
	Mov	ebp,256
.ReadL	Mov	ecx,512/4
	Push	edx
	Mov	edx,esi
	Rep Insd			; Read sector data into IO_DATA buffer
	Pop	edx
	Call	ider_WaitReady
	Dec	ebp
	Jnz	.ReadL
	PopAD
	;
	Mov	ecx,[ebx+IO_LENGTH]
	Shl	ecx,9
	Mov	[ebx+IO_LENGTH],ecx	; Return amount of bytes read IO_Length*512
	Mov dword	[ebx+IO_ERROR],0
	Ret

.Failed	Mov dword	[ebx+IO_LENGTH],0
	Ret

.Fail2	Mov dword	[ebx+IO_LENGTH],0
	Ret




;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; Initialize read request.
;
; - Set device
; - Translate LBA address
; - Set sector count
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ider_ReadInit	PUSHX	eax,edx,esi
	Mov	esi,[ebx+IO_UNIT]
	Mov	esi,[IdeDevPortTable+esi*4]	; Base port
	;
	Mov	eax,[ebx+IO_OFFSET]	; Sector number
	;
	Rol	eax,8		;
	Or	al,0x40		; Set Device, LBA 27:24

	Lea	edx,[esi+IDEP_Head]
	Out	dx,al
	Lea	edx,[esi+IDEP_Status]
	In	al,dx		; Read Status
	Cmp	al,0xff		; Floating bus?
	Je	.Exit
	Cmp	al,0x7f		; Floating bus in disguise?
	Je	.Exit
	Rol	eax,8		; Set LBA 23:16

	Lea	edx,[esi+IDEP_CylHigh]
	Out	dx,al
	Rol	eax,8		; Set LBA 15:08
	Lea	edx,[esi+IDEP_CylLow]
	Out	dx,al
	Rol	eax,8		; Set LBA 07:00
	Lea	edx,[esi+IDEP_SectNumb]
	Out	dx,al
	Mov	ecx,[ebx+IO_LENGTH]	; Number of sectors to read (0-255), 0=max (256)
	Mov	al,cl		; Set Sector Count
	Lea	edx,[esi+IDEP_SectCnt]
	Out	dx,al
.Exit	POPX	eax,edx,esi

	PRINTLONGSTR	IdeDebugTxt,[ebx+IO_OFFSET]
	Ret

IdeDebugTxt	Db	"ide.device - Request to read sector 0x",0


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Wait for drive to be ready.
;
; Checks that the Busy, Error and DRQ flags in the Status field are
; all cleared.
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ider_WaitReady	PUSHX	ebx,edx,esi
	;
	Mov	ebx,[edx+ided_IORequest]	; Pointer to I/O Request, *don't trash it*
	Mov	esi,[ebx+IO_UNIT]
	Mov	esi,[IdeDevPortTable+esi*4]	; Base port
	Lea	edx,[esi+IDEP_Status]
	;
.L	In	al,dx
	Test	al,IDEF_Busy		; Loop until IDEF_Busy is cleared, ignore other bits
	Jnz	.L
	Test	al,IDEF_Error		; Fail if error
	Jnz	.Error
	Test	al,IDEF_DRQ		; If not IDEF_Busy is set, IDEF_DRQ should be set
	Jz	.DRQ
	Clc
	POPX	ebx,edx,esi
	Ret
	;
.Error	Mov dword	[ebx+IO_ERROR],IDEIOERR_ERROR
	Stc
	POPX	ebx,edx,esi
	Ret
	;
.DRQ	Mov dword	[ebx+IO_ERROR],IDEIOERR_DRQ
	Stc
	POPX	ebx,edx,esi
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevCmdWrite	Ret
IdeDevCmdUpdate	Ret
IdeDevCmdClear	Ret
IdeDevCmdStop	Ret
IdeDevCmdStart	Ret
IdeDevCmdFlush	Ret


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
IdeMountPCIDevs	Cld
	XOr	ecx,ecx		; Device count
	Lea	edi,[SysBase+SB_PCIList]
.L	NEXTNODE	edi,.NoMore
	;
	Lea	esi,[IdePCIDevices]
.NoMatch	Lodsd
	Test	eax,eax
	Jz	.L
	Cmp	[edi+PCI_VendorID],eax
	Jne	.NoMatch
	;
	;---REMOVE A.S.A.P
	Push	eax
	Lea	eax,[IdeMatchTxt]
	Int	0xff
	Pop	eax
	Int	0xfe
	;---REMOVE A.S.A.P
	Mov	ecx,6
	XOr	edx,edx
.NextAddress	Mov	eax,[edi+PCI_SIZE+PCIN_BaseAddress0+edx*4]	; Check BaseAddress0-5
	Test	eax,eax
	Jz	.InvalidAddress
	; make some checks, perhaps send a device identify and check if this is hd or so..
	;
	Bt	eax,0			; Bit 0 is set if this is an I/O address
	Jnc	.InvalidAddress
	Shr	eax,2			; I/O address is bit 2-31
	Mov	ebx,[PortIndex]
	Mov	[IdePortList+ebx*4],eax		; Add the port we found
	Inc dword	[PortIndex]

	;----REMOVE A.S.A.P
	Push	eax
	Lea	eax,[IdePortTxt]
	Int	0xff
	Pop	eax
	Int	0xfe
	;----REMOVE A.S.A.P

	; check if addresslength <>7 bytes
	; save address in list if valid
.InvalidAddress	Inc	edx
	Dec	ecx
	Jnz	.NextAddress
	Jmp	.L

	;--
.NoMore	Cmp dword	[IdePortList],0
	Jne	.Done
	;----REMOVE A.S.A.P
	Lea	eax,[IdeNoPortsTxt]
	Int	0xff
	;----REMOVE A.S.A.P
	Mov dword	[IdePortList],0x1f0
	Mov dword	[IdePortList+4],0x170
.Done	Call	IdeSetMaxUnits
	Ret

PortIndex	Dd	0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeSetMaxUnits	Lea	esi,[IdePortList]
	Mov	ecx,-1
.L	Lodsd
	Test	eax,eax
	Jz	.Done
	Inc	ecx
	Jmp	.L
.Done	Mov	[IdeMaxUnits],ecx
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -


	; if match
	; skip if BaseAdd = 0
	; skip if BaseAddLength <> 7 bytes	i.e. atleast 0x1f0-0x1f7 / 0x170-0x177
	; else add master and slave to devicelist
	;	i.e. if we find 0x1f0/0x170, add
	;		0x1f0 as unit 0, dword #0
	;		0x170 as unit 2, dword #1
	;	 if unit #0 is requested, we set 0x1f0 master
	;	 if unit #1 is requested, we set 0x1f0 slave and so on...

	; add new devicecommand, Ident:
	; 	returns device identifyblock (512bytes) for probing etc..
	;
	; for sanity:
	; 	add 0x1f0 and 0x170 if they were not added in the probe
	;
	; update maxunits to devicelist entrys * 2 (for master/slave units..)
	;


IdeMatchTxt	Db	"Found EIDE host adapter, PCI-ID = ",0
IdePortTxt	Db	"Found controller port = ",0
IdeNoPortsTxt	Db	"No ports or controllers found, autoadding baseports 0x1f0,0x170",0xa,0



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
IdePCIDevices:	; High Point Technologies Inc
	Dw	0x1103,0x0003	; HPT343/345 UDMA EIDE controller
	Dw	0x1103,0x0004	; HPT366/370 UDMA66/UDMA100 EIDE controller
	; Promise Technology
	Dw	0x105a,0x4d33	; PDC20246 UltraATA Controller
	Dw	0x105a,0x4d38	; PDC20262 UltraDMA66 EIDE Controller
	Dw	0x105a,0x5300	; DC5030 EIDE Controller
	; Intel Corporation
	Dw	0x8086,0x244A	; 82801BAM (ICH2) UltraDMA/100 IDE Controller
	Dw	0x8086,0x244B	; 82801BA (ICH2) UltraDMA/100 IDE Controller
	Dw	0x8086,0x1222	; 82092AA EIDE Controller
	Dw	0x8086,0x1230	; 82338/82371FB PIIX PCI EIDE Controller
	Dw	0x8086,0x1239	; 82371FB 430FX PCI EIDE Controller
	Dw	0x8086,0x2411	; 82801AA 8xx Chipset IDE Controller
	Dw	0x8086,0x2421	; 82801AB 8xx Chipset IDE Controller
	Dw	0x8086,0x7010	; 82371SB PIIX3 EIDE Controller
	Dw	0x8086,0x7111	; 82371AB/EB/MB PIIX4 EIDE Controller
	Dw	0x8086,0x7199	; 82440MX EIDE Controller
	Dw	0x8086,0x7601	; 82372FB IDE Controller
	; Compaq
	Dw	0x0E11,0xae33	; Triflex Dual EIDE Controller
	; National Semiconductor
	Dw	0x100b,0xd001	; PC87410 PCI EIDE Controller (Single FIFO)
	; American Megatrends Inc
	Dw	0x101e,0x9030	; EIDE Controller
	Dw	0x101e,0x9031	; EIDE Controller
	; Acer Inc
	Dw	0x1025,0x5215	; ALI PCI EIDE Controller
	Dw	0x1025,0x5225	; ALI M5225 EIDE Controller
	Dw	0x1025,0x5229	; ALI M5229 EIDE Controller
	Dw	0x1025,0x5240	; EIDE Controller
	; Silicon Integrated Systems (SiS)
	Dw	0x1039,0x0597	; SiS5513 EIDE Controller (C step)
	Dw	0x1039,0x5513	; SiS5513 EIDE Controller (A,B step)
	; OPTi Inc
	Dw	0x1045,0xD568	; 82C825 FireBridge II PCI EIDE Controller
	; Data Technology Corp (DTC)
	Dw	0x107F,0x0803	; EIDE Bus Master Controller
	Dw	0x107F,0x0806	; EIDE Controller
	Dw	0x107F,0x2015	; EIDE Controller
	; CMD Technology Inc
	Dw	0x1095,0x0640	; PCI-0640 PCI EIDE Adapter (Single FIFO)
	Dw	0x1095,0x0641	; PCI-0640 PCI EIDE Adapter with RAID 1
	Dw	0x1095,0x0642	; EIDE Adapter with RAID 1
	Dw	0x1095,0x0643	; PCI-0643
	Dw	0x1095,0x0646	; PCI-0646 PCI EIDE Adapter (Single FIFO)
	Dw	0x1095,0x0647	; PCI-0647
	Dw	0x1095,0x0648	; PCI-0648 UDMA66 EIDE Controller
	; Appian Technology (ETMA)
	Dw	0x1097,0x0038	; EIDE Controller (Single FIFO)
	; Quantum Designs H.K. Ltd
	Dw	0x1098,0x0001	; QD8500 EIDE Controller
	Dw	0x1098,0x0002	; QD8580 EIDE Controller
	; Symphony Labs
	Dw	0x10AD,0x0001	; W83769F PCI EIDE Controller (Signle FIFO)
	Dw	0x10AD,0x0003	; SL82C103 EIDE Controller
	Dw	0x10AD,0x0005	; SL82C105 EIDE Busmaster Controller
	Dw	0x10AD,0x0103	; SL82C103 EIDE Controller
	Dw	0x10AD,0x0105	; SL82C105 EIDE Busmaster Controller
	Dw	0x10AD,0x0150	; EIDE Controller
	Dw	0x10AD,0x0565	; W83C553 PCI EIDE Controller?
	; VIA Technologies Inc.
	Dw	0x1106,0x0561	; VT82C570 MV IDE Controller (Single FIFO)
	Dw	0x1106,0x0571	; VT82C586B EIDE Controller
	Dw	0x1106,0x1106	; VT82C570 MV IDE Controller
	Dw	0x1106,0x1571	; VT82C416 IDE Controller
	; Infineon Technologies (Was Siemens Nixdorf AG)
	Dw	0x110A,0x0002	; Piranha PCI-EIDE-Adapter (2 Port)
	; Acard Technology Corp
	Dw	0x1191,0x0001	; EIDE Adapter
	Dw	0x1191,0x0002	; ATP850UF UltraDMA33 EIDE Controller (AEC6210UF)
	Dw	0x1191,0x0003	; SCSI Cache Host Adapter
	Dw	0x1191,0x0004	; ATP850UF UltraDMA33 EIDE (Cache??) Controller (AEC6210UF)
	Dw	0x1191,0x0005	; ATP850UF UltraDMA33 EIDE Controller (AEC6210UF)
	Dw	0x1191,0x0006	; ATP860A UltraDMA66 EIDE Controller, NO-BIOS (AEC6260)
	Dw	0x1191,0x0007	; ATP860A UltraDMA66 EIDE Controller (AEC6260)
	;---
	Dw	0,0

IdeMaxUnits	Dd	0
IdePortList	Times	64 Dd 0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevPortTable	Dd	0x1f0		; Unit 0
	Dd	0x170		; Unit 1
	Dd	0x1e8		; Unit 2
	Dd	0x168		; Unit 3

