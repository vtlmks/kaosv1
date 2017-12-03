;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Generic Floppy device.
;
;     Supports upto two Intel 8272/82077/82078 based
;     3,5"/5,25" floppy devices (or compatibles).
;     Read and write operations are DMA based.
;


	%Include	"z:\Includes\Macros.I"
	%Include	"z:\Includes\TypeDef.I"
	%Include	"z:\Includes\Lists.I"
	%Include	"z:\Includes\Nodes.I"
	%Include	"z:\Includes\TagList.I"
	%Include	"z:\Includes\Ports.I"
	%Include	"z:\Includes\Libraries.I"
	%Include	"z:\Includes\IO.I"
	%Include	"z:\Includes\SysBase.I"

	%Include	"z:\Includes\Exec\IO.I"
	%Include	"z:\Includes\Exec\LowLevel.I"
	%Include	"z:\Includes\Exec\Memory.I"

	%Include	"z:\Includes\Hardware\Floppy.I"
	%Include	"z:\Includes\Hardware\PIC.I"

	%Include	"z:\Includes\LVO\Exec.I"
	%Include	"z:\Includes\LVO\Utility.I"


DevVersion	Equ	1
DevRevision	Equ	0

	Lea	eax,[DevTaglist]
	Ret

	Struc DevMemory
_ExecBase	ResD	1	; Exec.library base
_UteBase	ResD	1	; Utility.library base
_NumUnits	ResD	1	; Number of units, temporary
_UnitMemory	ResD	1	; Allocated unit structures, see below
_SIZE	EndStruc

	Struc DevUnit
DU_UnitNumber	ResD	1	; Unit number
DU_MsgPort	ResD	1	; Unit msgport
DU_IORequest	ResD	1	; Userside I/O request, used first time unit is opened
DU_OpenCount	ResD	1	; Opencount for the unit
DU_DevMemory	ResD	1	; Pointer to devicebase
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

DevName	Db	"floppy.device",0
DevIDString	Db	"floppy.device 1.0 (2001-05-17)",0


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
	Jc	.Failure
	Call	.AllocateUnits
	Call	.InitUnits
	XOr	eax,eax
	Ret
.Failure	Mov	eax,-1
	Ret

	;--
.GetNumUnits	Mov	eax,[SysBase+SB_BIOSEquipment]
	Bt	eax,SBBEB_Floppy
	Jnc	.NoFloppy
	Movzx	eax,al
	Shr	eax,6
	Inc	eax		; Number of floppys, 1 - 2 supported..
	Mov	[ebp+_NumUnits],eax	; Number of units
	Clc
	Ret
.NoFloppy	Mov dword	[ebp+_NumUnits],0		; Number of units
	Stc
	Ret

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
DevCmdReset	Call	MotorOn
	Call	Recalibrate
	Call	MotorOff
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
DevCmdStop	Call	MotorOff
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevCmdStart	Call	MotorOn
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DevCmdFlush
	Ret



	Struc DevMem
dev_ExecBase	ResD	1
dev_UnitMemory	ResD	1
dev_MsgPort	ResD	1
dev_IORequest	ResD	1
dev_DevPort	ResD	1	; Hardware port
dev_UnitNumber	ResD	1
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
	Mov dword	[ebp+dev_DevPort],0x3f0	; Baseport for floppys
	Mov	eax,[edi+DU_UnitNumber]
	Mov	[ebp+dev_UnitNumber],eax
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
FloppyIRQ	PushAD
	PushFD

	;
	; Awake(FloppyUnitProcess);
	;

	Mov	al,PIC_EOI
	Out	PIC_M,al
	PopAD
	PopFD
	IRetd





;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
MotorOn	Cmp dword	[ebp+dev_UnitNumber],0
	Jne	.Drive1
	Mov	al,FDCDORF_FDCRESET|FDCDORF_DMA|FDCDORF_DRIVE0	; Turn on drive 0
	Jmp	.MotorOn
.Drive1	Mov	al,FDCDORF_FDCRESET|FDCDORF_DMA|FDCDORF_DRIVE1	; Turn on drive 1
	;
.MotorOn	Mov	edx,[ebp+dev_DevPort]
	Lea	edx,[edx+FDCPORT_DOR]
	Out	dx,al
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
MotorOff	Cmp dword	[ebp+dev_UnitNumber],0
	Jne	.Drive1
	Mov	al,0			; Turn off drive 0
	Jmp	.MotorOff
.Drive1	Mov	al,FDCDORF_DRSEL0			; Turn off drive 1
	;
.MotorOff	Mov	edx,[ebp+dev_DevPort]
	Lea	edx,[edx+FDCPORT_DOR]
	Out	dx,al
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Send floppy command/parameter to host controller
;
; Inputs:
;
;  al = command
;
;
SendCmd	PushAD
	Push	ax
	; delay 1ms here
.L	; Call delay
	;
	Mov	edx,[ebp+dev_DevPort]
	Lea	edx,[edx+FDCPORT_MSR]	; MainStatusRegister
	In	al,dx
	And	al,0x80
	Cmp	al,0x80
	Je	.Ready
	Jmp	.L
.Ready	; delay 1ms here
	Mov	edx,[ebp+dev_DevPort]
	Lea	edx,[edx+FDCPORT_ST0]
	Pop	ax
	Out	dx,al
	PopAD
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Read host controller output
;
;
; Output:
;
;  al = result
;
ReadHost	PUSHX	ecx,edx
	; delay 1ms here
.L	; call delay
	;
	Mov	edx,[ebp+dev_DevPort]
	Lea	edx,[edx+FDCPORT_MSR]	; MainStatusRegister
	In	al,dx
	And	al,0x80
	Cmp	al,0x80
	Je	.Ready
	Jmp	.L
.Ready	; delay 1ms here
	Mov	edx,[ebp+dev_DevPort]
	Lea	edx,[edx+FDCPORT_ST0]
	In	al,dx
	POPX	ecx,edx
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
Recalibrate	Mov	al,FDCCMD_RECALIBRATE
	Call	SendCmd
	Mov	eax,[ebp+dev_UnitNumber]	; Unit select, 0 or 1
	Call	SendCmd
	Mov	al,FDCCMD_SENSEINT	; Sense interrupt
	Call	SendCmd
	Call	ReadHost
	And	al,0x80
	Cmp	al,0x80
	Je	.Done
	Jmp	Recalibrate
.Done	Call	ReadHost
	Test	al,al
	Jz	.Exit
	Jmp	Recalibrate
.Exit	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Seek track/side
;
; Inputs:
;
;  eax = Side (head)
;  ebx = Track

Seek	Mov	esi,eax
	Mov	edi,ebx
.L	Mov	al,FDCCMD_SEEK
	Call	SendCmd
	;
	Mov	eax,[ebp+dev_UnitNumber]
	Inc	eax		; Bit 0-1: Unit 0=1, 1=2
	Mov	ebx,esi
	Shl	ebx,2
	Add	eax,ebx		; Bit 2: Side/Head number select, 0/1
	Call	SendCmd
	;
	Mov	eax,edi
	Call	SendCmd
	Mov	al,FDCCMD_SENSEINT
	Call	SendCmd
	Call	ReadHost
	And	al,0x80
	Cmp	al,0x80
	Je	.Done
	Jmp	.L
.Done	Call	ReadHost
	Mov	ebx,edi
	Cmp	al,bl		; Check if this is the correct track
	Je	.Exit
	Jmp	.L
.Exit	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Read data from host controller using DMA
;
; Inputs:
;
;  eax - Head (Side)
;  ebx - Cylinder (Track)
;  ecx - Sector
;
ReadData	Mov	esi,eax
	Mov	edi,ebx

	Mov	al,FDCCMD_DMAREAD
	Call	SendCmd		; Byte #0
	;
	Mov	eax,[ebp+dev_UnitNumber]
	Inc	eax		; Bit 0-1: Unit 0=1, 1=2
	Mov	ebx,esi
	Shl	ebx,2
	Add	eax,ebx		; Bit 2: Side/Head number select, 0/1
	Call	SendCmd		; Byte #1
	;
	Mov	eax,edi
	Call	SendCmd		; Byte #2: Cylinder/track number
	;
	Mov	eax,esi		;
	Call	SendCmd		; Byte #3: Head number
        	;
	Mov	al,cl		;
	Call	SendCmd		; Byte #4: Sector number
	;
	Mov	al,2
	Call	SendCmd		; Byte #5: Bytes per sector, 2=512
	;
	Mov	al,18
	Call	SendCmd		; Byte #6: End of track (last sector in track)
	;
	Mov	al,0x1b
	Call	SendCmd		; Byte #7: 3,5" read/write gap
	;
	Mov	al,0
	Call	SendCmd		; Byte #8: data length, if byte #5 = 0 or 0xff
	;
	Mov	ecx,7
.L	Call	ReadHost
	Dec	ecx
	Jnz	.L
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Write data to host controller using DMA
;
; Inputs:
;
;  eax - Side
;  ebx - Track
;  ecx - Sector

WriteData	Mov	esi,eax
	Mov	edi,ebx

	Mov	al,FDCCMD_DMAWRITE
	Call	SendCmd		; Byte #0
	;
	Mov	eax,[ebp+dev_UnitNumber]
	Inc	eax		; Bit 0-1: Unit 0=1, 1=2
	Mov	ebx,esi
	Shl	ebx,2
	Add	eax,ebx		; Bit 2: Side/Head number select, 0/1
	Call	SendCmd		; Byte #1
	;
	Mov	eax,edi
	Call	SendCmd		; Byte #2: Cylinder/track number
	;
	Mov	eax,esi		;
	Call	SendCmd		; Byte #3: Head number
        	;
	Mov	al,cl		;
	Call	SendCmd		; Byte #4: Sector number
	;
	Mov	al,2
	Call	SendCmd		; Byte #5: Bytes per sector
	;
	Mov	al,18
	Call	SendCmd		; Byte #6: End of track (last sector in track)
	;
	Mov	al,0x1b
	Call	SendCmd		; Byte #7: 3,5" read/write gap
	;
	Mov	al,0
	Call	SendCmd		; Byte #8: data length, 0 or 0xff
	;
	Mov	ecx,7
.L	Call	ReadHost
	Dec	ecx
	Jnz	.L
	Ret




; 80 tracks
;  2 sides/heads
; 18 sectors per track
;
; 2880 sectors total

;
;
; FirstDataSector==Reserved+(NumFATs*SectorsPerFat)+PartitionOffset

;  19=1+(2*9)+0
; sectors per fat = 0x009
; numfats = 2
; reserved = 1
; partitionoffset = 0
;
; sector #19...
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
;     LBA = ( (cylinder * heads_per_cylinder + heads )
;             * sectors_per_track ) + sector - 1
;
;     where heads_per_cylinder and sectors_per_track are the current
;     translation mode values.
;
;This algorithm can also be used by a BIOS or an OS to convert
;a L-CHS to an LBA as we'll see below.
;
;This algorithm can be reversed such that an LBA can be
;converted to a CHS:
;
;    cylinder = LBA / (heads_per_cylinder * sectors_per_track)
;        temp = LBA % (heads_per_cylinder * sectors_per_track)
;        head = temp / sectors_per_track
;      sector = temp % sectors_per_track + 1
;
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -



;	Struc	FAT12BPB
;.BSJMPBoot	ResB	3	; Jump instruction to bootcode
;.BSOEMName	ResB	8	; OEM name
;	;
;.BytesPerSector	ResW	1	; Bytes per sector
;.SectorsPerClust	ResB	1	; Sectors per cluster
;.ReservedSectors	ResW	1	; Reserved sectors
;.NumFats	ResB	1	; Number of Fats
;.RootEntries	ResW	1	; Root entries
;.TotalSectors	ResW	1	; Total sectors
;.Media	ResB	1	; Media type
;.SectorsPerFat	ResW	1	; Sectors per Fat
;.SectorsPerTrack	ResW	1	; Sectors per track
;.HeadsPerCyl	ResW	1	; Heads per cylinder
;.HiddenSectors	ResD	1	; Hidden sectors
;.TotalSectorsBig	ResD	1	; Total sectors
;	;
;.DriveNumber	ResB	1	; Drive number, e.g. 0x80 to be used with BIOS Int 0x13
;.Reserved	ResB	1	; Reserved, set to null
;.BootSig	ResB	1	; Extended boot signature (0x29). Indicates that the following three fields are available
;.VolumeID	ResD	1	; Volume serial number
;.VolumeLabel	ResB	11	; Volume label, matches the 11-byte volume label in the root directory
;.FileSystemType	ResB	8	; Usually contains FAT12, FAT16 or FAT with trailing spaces
;.SIZE	EndStruc

;  2465 00000000 <res 00000003>      <1> .BSJMPBoot	ResB	3	; Jump instruction to bootcode
;  2466 00000003 <res 00000008>      <1> .BSOEMName	ResB	8	; OEM name
;  2467                              <1> 	;
;  2468 0000000B <res 00000002>      <1> .BytesPerSector	ResW	1	; Bytes per sector
;  2469 0000000D <res 00000001>      <1> .SectorsPerClust	ResB	1	; Sectors per cluster
;  2470 0000000E <res 00000002>      <1> .ReservedSectors	ResW	1	; Reserved sectors
;  2471 00000010 <res 00000001>      <1> .NumFats	ResB	1	; Number of Fats
;  2472 00000011 <res 00000002>      <1> .RootEntries	ResW	1	; Root entries
;  2473 00000013 <res 00000002>      <1> .TotalSectors	ResW	1	; Total sectors
;  2474 00000015 <res 00000001>      <1> .Media	ResB	1	; Media type
;  2475 00000016 <res 00000002>      <1> .SectorsPerFat	ResW	1	; Sectors per Fat
;  2476 00000018 <res 00000002>      <1> .SectorsPerTrack	ResW	1	; Sectors per track
;  2477 0000001A <res 00000002>      <1> .HeadsPerCyl	ResW	1	; Heads per cylinder
;  2478 0000001C <res 00000004>      <1> .HiddenSectors	ResD	1	; Hidden sectors
;  2479 00000020 <res 00000004>      <1> .TotalSectorsBig	ResD	1	; Total sectors
;  2480                              <1> 	;
;  2481 00000024 <res 00000001>      <1> .DriveNumber	ResB	1	; Drive number, e.g. 0x80 to be used with BIOS Int 0x13
;  2482 00000025 <res 00000001>      <1> .Reserved	ResB	1	; Reserved, set to null
;  2483 00000026 <res 00000001>      <1> .BootSig	ResB	1	; Extended boot signature (0x29). Indicates that the following three fields are available
;  2484 00000027 <res 00000004>      <1> .VolumeID	ResD	1	; Volume serial number
;  2485 0000002B <res 0000000B>      <1> .VolumeLabel	ResB	11	; Volume label, matches the 11-byte volume label in the root directory
;  2486 00000036 <res 00000008>      <1> .FileSystemType	ResB	8	; Usually contains FAT12, FAT16 or FAT with trailing spaces
;  2487                              <1> .SIZE	EndStruc
