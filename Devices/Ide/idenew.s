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


	LIBINIT
	LIBDEF	LVOBeginIO
	LIBDEF	LVORemoveIO


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
IdeDevFuncTable

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
IdeDevInit
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
IdeDevExpunge
	; send KILL to the daemon
	; free up some memory etc..
	; return -1 to eax so the CloseDevice() can unlink us from the devicelist.

	;
	Mov	eax,-1
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevNull	XOr	eax,eax
	Ret


	Struc IDEDevice
ided_MsgPort	ResD	1	; Messageport of the device
ided_IORequest	ResD	1	; Current I/O request structure
ided_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevDaemon	LIBCALL	CreateMsgPort,ExecBase
	Mov	[edx+ided_MsgPort],eax
	Mov	ebx,[edx+ided_IORequest]
	Mov	eax,[ebx+MN_REPLYPORT]
	Mov dword	[ebx+IO_DATA],DEV_READY	; Device-Ready identifier
	LIBCALL	PutMsg,ExecBase		; Send acknowledge
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
IdeDevFunction1
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
IdeBeginIO	PUSHX	ebx,edx
	Push	eax
	Mov	edx,[IdeDevTable]
	Mov	eax,[edx+ided_MsgPort]	; Device messageport
	Pop	ebx		; Message containing I/O structure
	LIBCALL	PutMsg,ExecBase
	POPX	ebx,edx
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeAbortIO
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevCmdInvalid
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevCmdReset
	Ret


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
	Test	ebp,ebp
	Jnz	.ReadL
	Mov	ebp,0x100
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
	Ret



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
IdeDevCmdWrite
	Ret
IdeDevCmdUpdate
	Ret
IdeDevCmdClear
	Ret
IdeDevCmdStop
	Ret
IdeDevCmdStart
	Ret
IdeDevCmdFlush
	Ret







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
	Cmp	[edi+LN_SIZE],eax
	Jne	.NoMatch
	;

;PCIN_BaseAddress0	ResD	1
;PCIN_BaseAddress1	ResD	1
;PCIN_BaseAddress2	ResD	1
;PCIN_BaseAddress3	ResD	1
;PCIN_BaseAddress4	ResD	1
;PCIN_BaseAddress5	ResD	1

	Jmp	.L


.NoMore

	Ret



;IdeGeneralPorts	Dd	0x1f0,0xa0
;	Dd	0x1f0,0xb0
;	Dd	0x170,0xa0
;	Dd	0x170,0xb0

;
; OpenList:
;
;





;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
IdePCIDevices
	;
	; Intel Corporation
	;

	Dw	0x8086,0x1222	; 82092AA EIDE Controller
	Dw	0x8086,0x1230	; 82338/82371FB PIIX PCI EIDE Controller
	Dw	0x8086,0x1239	; 828371FB 430FX PCI EIDE Controller
	Dw	0x8086,0x2411	; 82801AA 8xx Chipset IDE Controller
	Dw	0x8086,0x2421	; 82801AB 8xx Chipset IDE Controller
	Dw	0x8086,0x7010	; 82371SB PIIX3 EIDE Controller
	Dw	0x8086,0x7111     ; 82371AB/EB/MB PIIX4 EIDE Controller
	Dw	0x8086,0x7199	; 82440MX EIDE Controller
	Dw	0x8086,0x7601	; 82372FB IDE Controller

	;
	; High Point Technologies Inc.
	;

	Dw	0x1103,0x0003	; HPT343/345 UDMA EIDE Controller
	Dw	0x1103,0x0004	; HPT366 UDMA66 EIDE Controller, HPT370 UDMA100 EIDE RAID Controller

	;
	; VIA Technologies Inc.
	;
	Dw	0x1106,0x0571	; VT82C586B EIDE Controller
	;--
	Dd	0




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IdeDevPortTable	Dd	0x1f0	;d400	;1f0		; Unit 0
	Dd	0x170		; Unit 1
	Dd	0x1e8		; Unit 2
	Dd	0x168		; Unit 3
