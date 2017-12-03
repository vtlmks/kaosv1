;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     NE2000 PCI ethernet driver
;



	%Include	"Z:\Includes\Macros.I"
	%Include	"Z:\Includes\TypeDef.I"
	%Include	"Z:\Includes\Lists.I"
	%Include	"Z:\Includes\Nodes.I"
	%Include	"Z:\Includes\TagList.I"
	%Include	"Z:\Includes\Ports.I"
	%Include	"Z:\Includes\Libraries.I"
	%Include	"Z:\Includes\IO.I"
	%Include	"Z:\Includes\SysBase.I"

	%Include	"Z:\Includes\Exec\IO.I"
	%Include	"Z:\Includes\Exec\LowLevel.I"
	%Include	"Z:\Includes\Exec\Memory.I"

	%Include	"Z:\Includes\Hardware\EISA.I"
	%Include	"Z:\Includes\Hardware\PCI.I"

	%Include	"Z:\Includes\LVO\Exec.I"
	%Include	"Z:\Includes\LVO\Utility.I"

	%Include	"Z:\Includes\Network\ARP.I"
	%Include	"Z:\Includes\Network\Ethernet.I"

	%Include	"Z:\Includes\Devices\NE2000.I"


%Macro	NICOUTB	1-2
	Mov	edx,[edi+DU_IOAddress]
	Add	edx,%1
	%IF %0 = 2
	Mov	al,%2
	%ENDIF
	Out	dx,al
%EndMacro


DevVersion	Equ	1
DevRevision	Equ	0


	Lea	eax,[DevTaglist]
	Ret


	Struc DevMemory
_ExecBase	ResD	1	; Exec.library base
_UteBase	ResD	1	; Utility.library base
_NumUnits	ResD	1	; Number of units, temporary
_UnitMemory	ResD	1	; Allocated unit structures, see below
_TempMem	ResD	20	; Temp mem
_SIZE	EndStruc

	Struc DevUnit
DU_UnitNumber	ResD	1	; Unit number
DU_MsgPort	ResD	1	; Unit msgport
DU_IORequest	ResD	1	; Userside I/O request, used first time unit is opened
DU_OpenCount	ResD	1	; Opencount for the unit
DU_DevMemory	ResD	1	; Pointer to devicebase
DU_IOAddress	ResD	1	; NIC I/O address
DU_IRQ	ResD	1	; NIC IRQ line
DU_EEPROM	ResB	NE2000EEPROM.SIZE	; NIC EPROM data buffer (1kbit long)
DU_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevTaglist	Dd	LT_FLAGS,0
	Dd	LT_VERSION,DevVersion
	Dd	LT_REVISION,DevRevision
	Dd	LT_TYPE,NT_DEVICE
	Dd	LT_PRIORITY,0
	Dd	LT_NAME,DevName
	Dd	LT_IDSTRING,DevIDString
	Dd	LT_INIT,DevInitTable
	Dd	TAG_DONE

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevInitTable	Dd	_SIZE
	Dd	DevFuncTable
	Dd	DevInit
	;
	Dd	-1

DevName	Db	"ne2k.device",0
DevIDString	Db	"ne2k.device 1.0 (2001-01-07)",0


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevFuncTable	Dd	DevOpen
	Dd	DevClose
	Dd	DevExpunge
	Dd	DevNull
	Dd	DevNull
	Dd	DevNull
	;-
	Dd	BeginIO
	Dd	AbortIO
	;-
	Dd	-1

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevCommands	Dd	DevCmdInvalid
	Dd	DevCmdReset
	Dd	DevCmdRead
	Dd	DevCmdWrite
	Dd	DevCmdUpdate
	Dd	DevCmdClear
	Dd	DevCmdStop
	Dd	DevCmdStart
	Dd	DevCmdFlush
	Dd	-1


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevInit	; ecx=execbase
	; edx=libbase

	Mov	ebp,edx
	Mov	[ebp+_ExecBase],ecx
	Lea	eax,[UteN]
	XOr	ebx,ebx
	LIB	OpenLibrary,[ebp+_ExecBase]
	Mov	[ebp+_UteBase],eax
	;
	Call	.GetNumUnits
	Call	.AllocateUnits
	Call	.InitUnits
	XOr	eax,eax
	Ret

	;--
.GetNumUnits	Lea	ebx,[SysBase+SB_ESCDList]
	XOr	edx,edx
	Cld

.GetNumUnitsL2	NEXTNODE	ebx,.GetUnitsDone
	Lea	esi,[NE2000NICList]
.GetNumL	Lodsd
	Test	eax,eax
	Jz	.GetNumUnitsL2

	Movzx	eax,word [ebx+EISA_CFG.SlotNumber]
	Int	0xfe

	Cmp word	[ebx+EISA_CFG.SlotNumber],0x10	; Search for virtual adapter
	Jb	.GetNumUnitsL2

	Mov	eax,.VirtualTxt
	Int	0xff

	Movzx	eax,word [ebx+EISA_CFG.Length]
	Cmp dword	[ebx+eax+ECD_FREEFORMBRDHDR.Signature],"ACFG"
	Jne	.GetNumL

	Mov	eax,"ACFG"
	Int	0xfe


	Jmp	.GetNumUnitsL2

.GetUnitsDone	Mov	edx,1		; ** REMOVE
	Mov dword	[ebp+_NumUnits],edx	; Number of units, this needs to be calculated ofcourse
	Ret

.VirtualTxt	Db	"Found virtual adapter",0xa,0


	;--
.AllocateUnits	Mov	eax,DU_SIZE
	XOr	edx,edx
	Mul dword	[ebp+_NumUnits]		; Get length of unit structure
	Mov	ebx,MEMF_NOKEY
	LIB	AllocMem,[ebp+_ExecBase]
	Mov	[ebp+_UnitMemory],eax
	Ret

	;--
.InitUnits	Mov	edx,[ebp+_NumUnits]
	Mov	esi,[ebp+_UnitMemory]
	XOr	ecx,ecx
.L	Mov	[esi+DU_UnitNumber],ecx
	Mov	[esi+DU_DevMemory],ebp
	Inc	ecx
	Dec	edx
	Jnz	.L
	Ret

UteN	Db	"utility.library",0

NE2000NICList	Dw	0x10ec,0x8029		; RealTek RTL-8029 10mbit
	Dw	0x10ec,0x8139		; RealTek RTL-8139 10/100
	Dw	0x10bd,0x0e34		; SureCom NE34
	Dw	0x1050,0x0940		; Winbond 89C940
	Dw	0x11f6,0x1401		; Compex RL2000
	Dw	0x8e2e,0x3000		; KTI ET32P2
	Dw	0x4a14,0x5000		; NetVin NV5000SC
	Dw	0x1050,0x5a5a		; WinBond
	Dd	0

NE2000NICNames	Dd	NIC01Txt
	Dd	NIC02Txt
	Dd	NIC03Txt
	Dd	NIC04Txt
	Dd	NIC05Txt
	Dd	NIC06Txt

NIC01Txt	Db	"RealTek RTL-8029",0xa,0
NIC02Txt	Db	"RealTek RTL-8319",0xa,0
NIC03Txt	Db	"SureCom NE34",0xa,0
NIC04Txt	Db	"Winbond 89C940",0xa,0
NIC05Txt	Db	"Compex RL2000",0xa,0
NIC06Txt	Db	"KTI ET32P2",0xa,0
NIC07Txt	Db	"NetVin NV5000SC",0xa,0
NIC08Txt	Db	"Winbond",0xa,0


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevOpen	; ebx=IORequest
	; edx=LibBase
	;
	Mov	edi,ebx
	Mov	ebp,edx
	Mov	eax,DU_SIZE
	XOr	edx,edx
	Mul dword	[edi+IO_UNIT]
	Mov	ebx,[ebp+_UnitMemory]
	Lea	esi,[ebx+eax]		; esi=ptr to Unitmemory
	Cmp dword	[esi+DU_OpenCount],0
	Jne	.AlreadyOpen
	;
	Bts dword	[edi+IO_FLAGS],IOB_WAITREQUIRED
	;
	Mov	[esi+DU_IORequest],edi
	;
	Lea	eax,[DevProcTags]
	LIB	CloneTaglist,[ebp+_UteBase]
	Push	eax
	Mov	[eax+4],esi		; Send unit memory as userdata
	Mov	ecx,eax
	LIB	AddProcess,[ebp+_ExecBase]
	Pop	eax
	LIB	FreeTaglist,[ebp+_UteBase]
	;
.AlreadyOpen	Inc dword	[esi+DU_OpenCount]
	XOr	eax,eax
	Ret


DevProcTags	Dd	AP_USERDATA,0
	Dd	AP_PROCESSPOINTER,DevDaemon
	Dd	AP_STACKSIZE,1024
	Dd	AP_RING,2
	Dd	AP_QUANTUM,2
	Dd	AP_NAME,DevName
	Dd	TAG_DONE

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevClose	; ebx=IORequest

	Mov	ebp,ebx
	Mov	edi,[ebp+IO_DEVICE]

	Mov	eax,DU_SIZE
	XOr	edx,edx
	Mul dword	[ebp+IO_UNIT]
	Mov	ebx,[edi+_UnitMemory]
	Lea	esi,[eax+ebx]

	Dec dword	[esi+DU_OpenCount]
	Jz	DevExpunge
	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevExpunge	; send kill to the unit daemon
	; free memory
	; return 0 if there are still units opened
	; return -1 if closedevice() should unlink us from the devicelist

	XOr	eax,eax
	Ret
.Unlink	Mov	eax,-1
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevNull	XOr	eax,eax
	Ret



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
BeginIO	Mov	ebp,eax
	Mov	eax,DU_SIZE
	XOr	edx,edx
	Mul dword	[ebp+IO_UNIT]
	Mov	edi,[ebp+IO_DEVICE]
	Mov	ebx,[edi+_UnitMemory]
	Mov	eax,[ebx+eax+DU_MsgPort]
	Mov	ebx,ebp
	LIB	PutMsg,[edi+_ExecBase]
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; AbortIO should be used to remove specific requests, it is not mandatory
; to support this function.
;

AbortIO
	Ret


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevCmdInvalid
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevCmdReset
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevCmdRead
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevCmdWrite
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevCmdUpdate
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevCmdClear
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevCmdStop
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevCmdStart
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevCmdFlush
	Ret



	Struc DevMem
dev_ExecBase	ResD	1
dev_UnitMemory	ResD	1
dev_MsgPort	ResD	1
dev_IORequest	ResD	1
dev_SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
	; eax=execbase
	; edx=userdata (unitmem)

DevDaemon	Mov	edi,edx
	Mov	edx,eax

	Mov	eax,dev_SIZE
	XOr	ebx,ebx
	LIB	AllocMem
	Mov	ebp,eax
	Mov	[ebp+dev_UnitMemory],edi
	Mov	[ebp+dev_ExecBase],edx
	;-
	LIB	CreateMsgPort,[ebp+dev_ExecBase]
	Mov	[ebp+dev_MsgPort],eax
	Mov	[edi+DU_MsgPort],eax
	;-
	Mov	ebx,[edi+DU_IORequest]
	Mov	eax,[ebx+MN_REPLYPORT]
	Mov dword	[ebx+IO_DATA],DEV_READY
	LIB	PutMsg,[ebp+dev_ExecBase]
	;--
.Main	LIB	Wait,[ebp+dev_ExecBase]
.L	LIB	GetMsg,[ebp+dev_ExecBase]
	Test	eax,eax
	Jz	.Main

	Mov	ebx,[eax+MN_PORTID]
	Mov	ecx,[ebp+dev_MsgPort]
	Cmp	ebx,[ecx+MP_ID]
	Jne	.NoDevMessage
	Mov	[ebp+dev_IORequest],eax	; edx holds pointer to device memory
	;			; don't trash it..
	Mov	ebx,[eax+IO_COMMAND]
	Mov	ebx,[DevCommands+ebx*4]
	Push	ebp
	Call	ebx
	Pop	ebp
	;
.NoDevMessage	Mov	eax,[ebp+dev_IORequest]
	LIB	ReplyMsg,[ebp+dev_ExecBase]
	Jmp	.L



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
Reset8390	Mov	edx,[edi+DU_IOAddress]
	Add	edx,NE_RESET
	In	al,dx
	; a delay should be made here..
	Out	dx,al

	NICOUTB	EN_CCMD,ENC_STOP|ENC_NODMA
	;
	Mov	edx,[edi+DU_IOAddress]
	Add	edx,EN0_ISR
.L	In	al,dx
	And	al,ENISRF_RESET
	Jnz	.Done
	Jne	.L
.Done	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
Init8390	NICOUTB	EN0_DCFG,ENDCFGF_LS|ENDCFGF_FT1	; Init data config registers
	;
	NICOUTB	EN0_RCNTLO,0		; Clear remote bytecount
	NICOUTB	EN0_RCNTHI
	NICOUTB	EN0_RXCR,ENRXCR_MON	; Set receiver to monitor mode
	NICOUTB	EN0_TXCR,ENTXCR_LOOP	; Loopback mode #1
	;
	Call	InitNIC
	;
	NICOUTB	EN0_DCFG,ENDCFGF_LS|ENDCFGF_FT1
	NICOUTB	EN0_STARTPG,SM_RSTART_PG
	NICOUTB	EN0_BOUNDARY,SM_RSTART_PG
	NICOUTB	EN0_STOPPG

	NICOUTB	EN0_ISR,0xff		; Clear any pending interrupts
	NICOUTB	EN0_IMR,ENISR_ALL

	Call	Init8390MAC
	;
	NICOUTB	EN_CCMD,ENC_PAGE1|ENC_NODMA|ENC_STOP
	NICOUTB	EN1_CURPAG,SM_RSTART_PG
	NICOUTB	EN_CCMD,ENC_NODMA|ENC_START
	NICOUTB	EN0_TXCR,0		; Transmitter mode to normal
	NICOUTB	EN0_RXCR,0
	;
	Call	InitNICIRQ
	;
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Set NIC's ethernet address to EEPROM etherid.
;

Init8390MAC	NICOUTB	EN_CCMD,ENC_NODMA|ENC_PAGE1
	Lea	esi,[edi+DU_EEPROM+NE2000EEPROM.EthernetID]
	Mov	ecx,6		; Length of ethernet address
.L	Lodsb
	Out	dx,al
	Inc	dx
	Dec	ecx
	Jnz	.L
	;
	NICOUTB	EN_CCMD,ENC_NODMA|ENC_PAGE0
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Setup registers to default values etc and read ethernet address
; off the EEPROM and save it in our unit memory.
;

InitNIC	NICOUTB	EN0_DCFG,ENDCFGF_WTS|ENDCFGF_LS|ENDCFGF_FT1	; Init data config registers
	NICOUTB	EN_CCMD,ENC_NODMA|ENC_PAGE0|ENC_START
	NICOUTB	EN0_RCNTLO,0x20
	NICOUTB	EN0_RCNTHI,0
	NICOUTB	EN0_RSARLO		; start address
	NICOUTB	EN0_RSARHI
	NICOUTB	EN_CCMD,ENC_RREAD|ENC_START
	Lea	ebx,[edi+DU_EEPROM]
	Mov	edx,[edi+DU_IOAddress]
	Add	edx,NE_DATAPORT
	Mov	ecx,10
.L	In	al,dx		; Read CONFIG and MAC address from EEPROM
	Mov	[ebx],al
	Inc	ebx
	Dec	ecx
	Jnz	.L
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
InitNICIRQ	Mov	eax,[edi+DU_IRQ]
	Lea	ebx,[NE2000IRQHandler]
	LIB	AddIRQHandler,[ebp+dev_ExecBase]
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -


NE2000Tx	Mov	ecx,1000

	Mov	edx,[edi+DU_IOAddress]
.L	In	al,dx
	Test	al,ENC_TRANS
	Jz	.Idle
	Jmp	.L
.Idle	Cmp	ecx,1518
	Ja	.InvalidPacket
	Cmp	ecx,60
	Jnb	.PacketOk
	Mov	ecx,60
.PacketOk	NICOUTB	EN0_ISR,ENISRF_RDC		; Clear remote interrupt
	NICOUTB	EN0_TCNTLO,cl		; Set packet size (low/high byte)
	NICOUTB	EN0_TCNTHI,ch
	XOr	eax,eax
	Mov	ah,SM_TSTART_PG
	;
	Call	NE2000StartTx

	NICOUTB	EN0_TPSR,SM_TSTART_PG	; Start transmission
	NICOUTB	EN_CCMD,ENC_TRANS|ENC_NODMA|ENC_START
.InvalidPacket	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Block Tx
;	; ecx=byte count
;	; esi=buffer
;

NE2000StartTx	;;
	Lea	esi,[TestPacket]
	Mov	ecx,TestPacketLen+8
	;;

	Inc	ecx
	And	ecx,0xfffffffe
	Push	ax
	NICOUTB	EN_CCMD,ENC_NODMA|ENC_START
	NICOUTB	EN0_RCNTLO,cl
	NICOUTB	EN0_RCNTHI,ch
	Pop	ax		; Page buffer
	NICOUTB	EN0_RSARLO,al		; Set lo/hi byte of page buffer
	NICOUTB	EN0_RSARHI,ah
	NICOUTB	EN_CCMD,ENC_RWRITE|ENC_START	; Start tx
	Shr	cx,1
	Mov	edx,[edi+DU_IOAddress]
	Add	edx,NE_DATAPORT
	Rep Outsw
	Mov	edx,[edi+DU_IOAddress]
	Add	edx,EN0_ISR
	Mov	ecx,0xffff
.L	In	al,dx
	Test	al,ENISRF_RDC		; Check if DMA has finished
	Jnz	.Done
	Loop	.L
.Done	Ret


TestPacket	Dw	-1,-1,-1
	Db	0x0,0xe0,0x7d,0x71,0xa7,0xff
	Dw	ETHERTYPE_ARP
	Db	"Det e g0tt.."

TestPacketLen	Equ	$-TestPacket



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; This is the IRQ handler for the device units
;
;

NE2000IRQHandler	PushFD
	PushAD

	;... remember this shit..
	;Cmp	IRQ,8
	; jg	eoimaster/slave

	PopAD
	PopFD
	IRetd
