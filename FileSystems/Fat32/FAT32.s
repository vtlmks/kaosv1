;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     FAT32.s V1.0.0
;
;     FAT 32 FileSystem handler.
;
;
;
; - The filesystem-handler must be spawned for each new partition/media that is using it, the handler
;   will gain the name of the partition as it's processname; if we are mounting i.e. "Asm:" the handler
;   will be spawned as "Asm". Atm this seems to be a good solution..
;
; - Once the handler is started it should at Init time (except everything else) create a messageport,
;   which is used to communicate with dos.library and add it's DOSEntry in the DOSList. It will, ofcourse,
;   also need a second port for communication between the fs-handler and the device, we may use only one
;   port but it will be easier to filter out requests using two ports.
;
;
; Things that need to be in the DOSlist required by the handler..
; -=============================================================-
; DeviceName	- ide.device, scsi.device
; MessagePort	- long word
; Partitionstart	- long containg partition start sector
; Unit	- device unit
;



	Struc F32FS
F32FS_DosMsgPort	ResD	1	; Messageport, used for dos.library
F32FS_IOMsgPort	ResD	1	; Messageport, used for device I/O requests
F32FS_IORequest	ResD	1	; I/O request
	;
F32FS_SPerFAT	ResD	1	; Sectors per FAT
F32FS_Reserved	ResD	1	; Reserved sectors
F32FS_NumFats	ResB	1	; Number of FAT's
F32FS_Unit	ResD	1	; Device unit
	;
F32FS_DataSector	ResD	1	; First Datasector, returned by GetDataSector()
F32FS_FirstSector	ResD	1	; First sector of partition, obtained from doslist
F32FS_ClusterSize	ResD	1	; Size of one cluster, in bytes
F32FS_ClusterScts	ResD	1	; Number of sectors per cluster
	;
	;
F32FS_TempBuffer	ResB	320
F32FS_SectorData	ResB	512+2	; Tempbuffer
	;
F32FS_Cache	ResB	MLH_SIZE	; LRU Cache memory
F32FS_SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	; edx (userdata) contains DosEntry pointer at startup

F32FSStart	Push	edx

	Mov	eax,F32FS_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	esi,eax
	LIBCALL	CreateMsgPort,ExecBase
	Mov	[esi+F32FS_DosMsgPort],eax	; Dos request port
	Pop	edx
	Mov	[edx+DE_PORT],eax		; DosEntry port
	;
	LIBCALL	CreateMsgPort,ExecBase
	Mov	[esi+F32FS_IOMsgPort],eax	; Device port
	Mov	ebx,eax
	Mov	eax,IO_SIZE
	LIBCALL	AllocIORequest,ExecBase
	Mov	[esi+F32FS_IORequest],eax

	Call	F32FSInit
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.Main	LIBCALL	Wait,ExecBase
.L	LIBCALL	GetMsg,ExecBase
	Test	eax,eax
	Jz	.Main
	Push	eax
	Mov	edx,eax

	Mov	ebx,[edx+MN_PORTID]
	Mov	ecx,[esi+F32FS_IOMsgPort]
	Cmp	ebx,[ecx+MP_ID]
	Jne	.NoIOMsg
	Call	F32PollIOPort
	Jmp	.Done
	;
.NoIOMsg	Mov	ecx,[esi+F32FS_DosMsgPort]
	Cmp	ebx,[ecx+MP_ID]
	Jne	.Done
	Call	F32PollDosPort

.Done	Pop	eax
	LIBCALL	ReplyMsg,ExecBase
	Jmp	.L

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.F32FSExit	Call	F32FSFreeCache
	Mov	eax,[esi+F32FS_IORequest]
	LIBCALL	CloseDevice,ExecBase
	Mov	eax,[esi+F32FS_IORequest]
	LIBCALL	FreeIORequest,ExecBase
	Mov	eax,[esi+F32FS_IOMsgPort]
	LIBCALL	DeleteMsgPort,ExecBase
	Mov	eax,[esi+F32FS_DosMsgPort]
	LIBCALL	DeleteMsgPort,ExecBase
	Mov	eax,esi
	LIBCALL	FreeMem,ExecBase
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
F32PollSysPort	Ret	; add later..

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
F32PollDosPort	Mov	eax,[edx+DP_TYPE]		; Get packettype-1
	Dec	eax
	Mov	eax,[F32FunctionTable+eax*4]
	Call	eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
F32PollIOPort	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
F32FunctionTable	Dd	F32PktKill
	Dd	F32PktOpen
	Dd	F32PktClose
	Dd	F32PktRead
	Dd	F32PktWrite
	Dd	F32PktRename
	Dd	F32PktDelete
	Dd	F32PktSeek
	Dd	F32PktFormat
	Dd	F32PktLock
	Dd	F32PktUnlock


	%Include	"FileSystems\FAT32\Kill.s"
	%Include	"FileSystems\FAT32\Open.s"
	%Include	"FileSystems\FAT32\Close.s"
	%Include	"FileSystems\FAT32\Read.s"
	%Include	"FileSystems\FAT32\Write.s"
	%Include	"FileSystems\FAT32\Rename.s"
	%Include	"FileSystems\FAT32\Delete.s"
	%Include	"FileSystems\FAT32\Seek.s"
	%Include	"FileSystems\FAT32\Format.s"
	%Include	"FileSystems\FAT32\Lock.s"
	%Include	"FileSystems\FAT32\Unlock.s"

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Convert short FAT filenames to 8+3 names.
;
; Input:
;  eax - source
;  ebx - destination
;
;
; Output:
;  Carry clear - Name was short
;  Carry set   - Name was long (no conversion is done)


F32ConvShortName	PushAD
	;
	Cld
	Mov	esi,eax
	Mov	edi,ebx
	LIBCALL	StrLen,UteBase
	Cmp	eax,13	; Check for longfilenames
	Jb near	.ShortName
	Stc
	Jmp	.LongName
	;
.ShortName	Cmp	eax,12	; Check if the filename is 12 bytes and without a dot
	Jne	.NoCheckDot
	Push	esi
.Ld	Lodsb
	Cmp	al,"."
	Je	.FoundDot
	Test	al,al
	Jnz	.Ld
	Pop	esi
	Stc
	Jmp	.LongName

.FoundDot	Pop	esi

.NoCheckDot	Call	.LengthOfDot	; Specialcase, if the dot name is >3 bytes then treat as LFN
	Jc	.LongName

	Mov	edx,esi
	Mov	ebp,edi
	XOr	ecx,ecx
.CopyName	Lodsb
	Inc	ecx
	Cmp	al,"."
	Je	.Pad
	Test	al,al
	Jz	.Null
	Stosb
	Jmp	.CopyName
	;--
.Pad	Dec	cl
	Cmp	cl,8
	Jae	.CopyExtension
	Sub	cl,8
	Neg	cl
	Mov	al," "
	Rep Stosb
	;
.CopyExtension	XOr	ecx,ecx
.L	Lodsb
	Inc	ecx
	Test	al,al
	Jz	.Null
	Stosb
	Jmp	.L
	;
.Null	Mov	esi,edx
	Mov	ecx,12
.Lx	Dec	ecx
	Jz	.Full
	Lodsb
	Test	al,al
	Jnz	.Lx
	Mov	al," "
	Rep Stosb
.Full	Mov byte	[ebp+11],0
	Clc
.LongName	PopAD
	Ret
	;

.LengthOfDot	PUSHX	eax,esi,ecx
	Mov	ecx,8
.LL	Lodsb
	Cmp	al,"."
	Je	.LFound
	Loop	.LL
	Jmp	.LFail
.LFound	XOr	ecx,ecx
.LL1	Lodsb
	Test	al,al
	Jz	.LDone
	Inc	ecx
	Jmp	.LL1
	;
.LDone	Cmp	cl,3
	Jbe	.LFail
	POPX	eax,esi,ecx
	Stc
	Ret
	;
.LFail	POPX	eax,esi,ecx
	Clc
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Init FS-handler
;
; - Get first partitionsector, devicename from doslist
; - Open device driver
; - Get BPB data and store it
; - Get first datasector
; - Init cache
;
F32FSInit	Call	F32FSGetDLData
	Call	F32FSOpenDevice
	Test	eax,eax
	Jnz	.Failure
	Call	F32FSGetBPBData
	Call	F32FSInitCache
	XOr	eax,eax
	Ret
	;
.Failure	Mov	eax,-1
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
F32FSOpenDevice	Lea	eax,[F32FSDevTags]
	LIBCALL	CloneTaglist,UteBase
	Push	eax
	Mov	ebx,[esi+F32FS_IORequest]
	Mov	[eax+4],ebx
	Lea	ebx,[F32FSDevN]		; Replace with name from DOSentry
	Mov	[eax+12],ebx
	;
	Mov	ecx,eax
	LIBCALL	OpenDevice,ExecBase
	Mov	ebx,eax
	;
	Pop	eax
	LIBCALL	FreeTaglist,UteBase
	Test	ebx,ebx
	Jz near	.NoDevice
	;
	PRINTTEXT	F32FSMsgDeviceOk
	XOr	eax,eax
	Ret
	;
.NoDevice	PRINTTEXT	F32FSMsgDeviceErr
	Mov	eax,-1
	Ret

F32FSDevTags	Dd	OD_IOREQUEST,0
	Dd	OD_NAME,0
	Dd	OD_UNIT,0
	Dd	OD_FLAGS,0
	Dd	TAG_DONE

F32FSDevN	Db	"ide.device",0		; ** REMOVE

F32FSMsgDeviceErr	Db	0xa,"** FAT32-FS status: Could not open device",0
F32FSMsgDeviceOk	Db	0xa,"** FAT32-FS status: Device opened successfully",0


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Obtain various doslist data
;
; - Name of device name
; - Extract partition startsector
; - Extract device unit
;
F32FSGetDLData	Mov dword	[esi+F32FS_Unit],0		; REMOVE later
	Mov dword	[esi+F32FS_FirstSector],63 	; REMOVE later
; F32FS_Unit
; F32FS_FirstSector
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc F32CacheEntry
	ResB	LN_SIZE
F32CE_SECTOR	ResD	1
F32CE_DATA	ResB	512
F32CE_SIZE	EndStruc

F32CACHEENTRYS	Equ	1000
F32CACHEENTRYSIZE	Equ	F32CE_SIZE

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
F32FSInitCache	INITLIST	[esi+F32FS_Cache]
	Mov	eax,F32CACHEENTRYS*F32CE_SIZE	; Entry = 512, Header = 4
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	ebx,eax
	Mov	edx,F32CACHEENTRYS
.Loop	Lea	eax,[esi+F32FS_Cache]
	Push	ebx
	ADDTAIL
	Pop	ebx
	Lea	ebx,[ebx+F32CE_SIZE]
	Dec	edx
	Jnz	.Loop
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
F32FSFreeCache	Ret	; free the memory within..

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	; ecx = sector
F32CacheLookup	PUSHX	eax,ebx,ecx,edx,esi
	Lea	eax,[esi+F32FS_Cache]
.L	NEXTNODE	eax,.NoMatch
	Cmp	[eax+F32CE_SECTOR],ecx
	Jne	.L

.Found	Push	eax
	REMOVE
	Pop	ebx
	Lea	eax,[esi+F32FS_Cache]
	ADDHEAD
	Lea	edi,[ebx+F32CE_DATA]
	POPX	eax,ebx,ecx,edx,esi
	Stc
	Ret
	;
.NoMatch	POPX	eax,ebx,ecx,edx,esi
	Clc
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; eax - sectornumber, F32FS_SectorData = data
;

F32CacheAdd	PushAD
	Mov	edx,eax
	Lea	eax,[esi+F32FS_Cache]

	Mov	eax,[eax+LH_TAILPRED]
	Test	eax,eax
	Jz	.Evil

	Push	eax
	REMOVE
	Pop	ebx
	Lea	eax,[esi+F32FS_Cache]
	ADDHEAD
	;
	Mov	[ebx+F32CE_SECTOR],edx
	Lea	edi,[ebx+F32CE_DATA]
	Lea	esi,[esi+F32FS_SectorData]
	Mov	ecx,512/4
	Cld
	Rep Movsd
.Evil	PopAD
	Ret




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; The datasector or atleast the datasector should be available from the DOSList.
; This is the first sector of partition, usually 63/0x3f for the first partition
; on a disk..
;
; FirstDataSector==Reserved+(NumFATs*SectorsPerFat32)+PartitionOffset
;
; Inputs : -
; Output : eax = FirstDataSector, aka the rootdir
;
F32FSGetBPBData	Mov	eax,[esi+F32FS_FirstSector]
	PRINTLONGSTR	FatFirstSectorTxt,eax
	Call	ReadSector
	Lea	ebx,[esi+F32FS_SectorData]
	;
	Mov	al,[ebx+FAT32BPB.NumFats]	; Extract Number of FAT's
	Mov	[esi+F32FS_NumFats],al
	Movzx	eax,word [ebx+FAT32BPB.ReservedSectors]	; Extract Reserved Sectors
	PRINTLONGSTR	FatReservedTxt,eax
	Mov	[esi+F32FS_Reserved],eax
	Mov	eax,[ebx+FAT32BPB.SectorsPerFat32]	; Extract Sectors per FAT
	PRINTLONGSTR	FatSecsPerFAT,eax
	Mov	[esi+F32FS_SPerFAT],eax
	;
	Movzx	eax,byte [ebx+FAT32BPB.SectorsPerClust]
	PRINTLONGSTR	FatSecsPerCluster,eax
	Mov	[esi+F32FS_ClusterScts],eax
	Shl	eax,9
	Mov	[esi+F32FS_ClusterSize],eax
	;
	Movzx	ecx,byte [esi+F32FS_NumFats]
	Mov	eax,[esi+F32FS_SPerFAT]
	Mul	ecx
	Mov	ecx,[esi+F32FS_Reserved]
	Add	eax,ecx
	Add	eax,[esi+F32FS_FirstSector]	; First sector of partition..
	Mov	[esi+F32FS_DataSector],eax	; First datasector, aka the rootdir of the FAT volume
	PRINTLONGSTR	FatFirstDSSector,eax
	Ret



FatFirstSectorTxt	Db	"First sector : ",0
FatReservedTxt	Db	"Reserved secs: ",0
FatSecsPerFAT	Db	"Secs per FAT : ",0
FatSecsPerCluster	Db	"Secs per CLST: ",0
FatFirstDSSector	Db	"First dsector: ",0



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Returns next cluster number or -1 if this is the last cluster.
; If the cluster isn't found in cache, it will read it from the media and
; add it to the cache tail and remove the head.
;
; Inputs: eax - Current cluster
; Output: eax - Next cluster
;
GetNextCluster	Mov	ebx,eax		; Current cluster
	Shr	ebx,7		; Sector that contains the FAT entry
	Push	ebx
	Shl	ebx,7
	Sub	eax,ebx
	Shl	eax,2
	Pop	ecx
	Add	ecx,[esi+F32FS_Reserved]	; Reserved sectors
	Add	ecx,[esi+F32FS_FirstSector]	; First sector of partition.. obtain from doslist
	; don't trash eax, ecx

;	Call	F32CacheLookup		; Enable these to enable cache
;	Jc	.CacheHit		; Enable these to enable cache

	Push	eax

	Mov	eax,[esi+F32FS_IORequest]
	Mov dword	[eax+IO_COMMAND],CMD_READ
	Mov dword	[eax+IO_OFFSET],ecx	; Sector
	Push	ecx
	Mov dword	[eax+IO_LENGTH],1
	Lea	ecx,[esi+F32FS_SectorData]
	Mov	[eax+IO_DATA],ecx
	Mov	ecx,[esi+F32FS_Unit]
	Mov	[eax+IO_UNIT],ecx
	LIBCALL	SendIO,ExecBase
	;

	Push	ebx
	Mov	eax,[esi+F32FS_IOMsgPort]
	Mov	ebx,MPSELECT_SYSTEMSET
	LIBCALL	SelectMsgPort,ExecBase
	LIBCALL	Wait,ExecBase
	LIBCALL	GetMsg,ExecBase
	Mov	ebx,MPSELECT_SYSTEMRESET
	LIBCALL	SelectMsgPort,ExecBase
	Pop	ebx

	Pop	eax		; Sector
;	Call	F32CacheAdd		; Enable these to enable cache
	;
	; Read/cache-lookup the sector number in ecx
	; and return a pointer to it in edi
	;
	Lea	edi,[esi+F32FS_SectorData]
	Pop	ebx
	Mov	eax,[edi+ebx]	; eax=now holds next cluster number
	Ret
	;
.CacheHit	Mov	eax,[edi+eax]
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; ReadSector -- read a sector
;
; Input: eax - Sector
;
ReadSector	PUSHX	ecx,ebp
	Mov	ecx,eax
	Mov	eax,[esi+F32FS_IORequest]
	Mov dword	[eax+IO_COMMAND],CMD_READ
	Mov	[eax+IO_OFFSET],ecx		; Sector
	Mov dword	[eax+IO_LENGTH],1
	Lea	ecx,[esi+F32FS_SectorData]
	Mov	[eax+IO_DATA],ecx
	Mov	ecx,[esi+F32FS_Unit]
	Mov	[eax+IO_UNIT],ecx
	LIBCALL	SendIO,ExecBase
	;
	PUSHX	eax,ebx
	Mov	eax,[esi+F32FS_IOMsgPort]
	Mov	ebx,MPSELECT_SYSTEMSET
	LIBCALL	SelectMsgPort,ExecBase
	LIBCALL	Wait,ExecBase
	LIBCALL	GetMsg,ExecBase
	Mov	ebx,MPSELECT_SYSTEMRESET
	LIBCALL	SelectMsgPort,ExecBase
	POPX	eax,ebx
	;
	POPX	ecx,ebp
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; ReadCluster -- read a cluster
;
; Input:
;  eax - Cluster number
;  ebx - Buffer
;
;
ReadCluster	PUSHX	ecx,ebp,edx
	Call	GetSector
	Mov	ecx,eax
	Mov	eax,[esi+F32FS_IORequest]
	Mov dword	[eax+IO_COMMAND],CMD_READ
	Mov	[eax+IO_OFFSET],ecx		; Sector
	Push dword	[esi+F32FS_ClusterScts]
	Pop dword	[eax+IO_LENGTH]			; Clustersize
	Mov	[eax+IO_DATA],ebx
	Mov	ecx,[esi+F32FS_Unit]
	Mov	[eax+IO_UNIT],ecx
	LIBCALL	SendIO,ExecBase
	;
	PUSHX	eax,ebx
	Mov	eax,[esi+F32FS_IOMsgPort]
	Mov	ebx,MPSELECT_SYSTEMSET
	LIBCALL	SelectMsgPort,ExecBase
	LIBCALL	Wait,ExecBase
	LIBCALL	GetMsg,ExecBase
	Mov	ebx,MPSELECT_SYSTEMRESET
	LIBCALL	SelectMsgPort,ExecBase
	POPX	eax,ebx
	;
	POPX	ecx,ebp,edx
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Calculates the sector number from the given cluster number.
; To get the sector number we need to calculate
; 8*(Cluster-2)+FirstDataSector ..
;
; Inputs: eax - Cluster
; Output: eax - Sector
;
GetSector	Lea	eax,[eax-2]
	Shl	eax,3
	Add	eax,[esi+F32FS_DataSector]
	Ret
