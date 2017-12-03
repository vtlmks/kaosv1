;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Template device.
;
;     This can be used as a template to create new devices,
;     it's prepared to use a dynamic number of units, where
;     each unit has it's own process.
;



	%Include	"Z:\Kaos\Includes\Macros.I"
	%Include	"Z:\Kaos\Includes\TypeDef.I"
	%Include	"Z:\Kaos\Includes\Lists.I"
	%Include	"Z:\Kaos\Includes\Nodes.I"
	%Include	"Z:\Kaos\Includes\TagList.I"
	%Include	"Z:\Kaos\Includes\Ports.I"
	%Include	"Z:\Kaos\Includes\Libraries.I"
	%Include	"Z:\Kaos\Includes\IO.I"

	%Include	"Z:\Kaos\Includes\Exec\IO.I"
	%Include	"Z:\Kaos\Includes\Exec\LowLevel.I"
	%Include	"Z:\Kaos\Includes\Exec\Memory.I"

	%Include	"Z:\Kaos\Includes\LVO\Exec.I"
	%Include	"Z:\Kaos\Includes\LVO\Utility.I"


	LIBINIT
	LIBDEF	LVOBeginIO
	LIBDEF	LVORemoveIO



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

DevName	Db	"xxx.device",0
DevIDString	Db	"xxx.device 1.0 (2000-12-12)",0


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
.GetNumUnits	Mov dword	[ebp+_NumUnits],4		; Number of units, this needs to be calculated ofcourse
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
	Lea	ecx,[DevProcMemTags]
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

DevProcMemTags	Dd	MMA_SIZE,dev_SIZE
	Dd	TAG_DONE



