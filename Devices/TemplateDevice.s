;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     TemplateDevice.s V1.0.0
;
;

	%Include	"Z:\Includes\Macros.I"
	%Include	"Z:\Includes\TypeDef.I"
	%Include	"Z:\Includes\Lists.I"
	%Include	"Z:\Includes\Nodes.I"
	%Include	"Z:\Includes\TagList.I"
	%Include	"Z:\Includes\Ports.I"
	%Include	"Z:\Includes\Libraries.I"
	%Include	"Z:\Includes\IO.I"

	%Include	"Z:\Includes\Exec\IO.I"
	%Include	"Z:\Includes\Exec\LowLevel.I"
	%Include	"Z:\Includes\Exec\Memory.I"

	%Include	"Z:\Includes\LVO\Exec.I"
	%Include	"Z:\Includes\LVO\Utility.I"


	LIBINIT
	LIBDEF	LVOBeginIO
	LIBDEF	LVOAbortIO


DevVersion	Equ	1
DevRevision	Equ	0

	Lea	eax,[DevTags]
	Ret

DevTags	Dd	LT_FLAGS,0
	Dd	LT_VERSION,DevVersion
	Dd	LT_REVISION,DevRevision
	Dd	LT_TYPE,NT_DEVICE
	Dd	LT_PRIORITY,0
	Dd	LT_NAME,DevName
	Dd	LT_IDSTRING,DevIDString
	Dd	LT_INIT,DevInitTable
	Dd	TAG_DONE

DevInitTable	Dd	_SIZE
	Dd	DevFuncTable
	Dd	DevInit
	;
	Dd	DevTable
	Dd	-1

DevName	Db	"template.device",0
DevIDString	Db	"template.device 1.0 (2000-11-15)",0

DevTable	Dd	0	; Pointer to devicememory


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DevFuncTable	Dd	DevOpen		; 0
	Dd	DevClose		; 4
	Dd	DevExpunge		; 8
	Dd	DevNull		; 12
	Dd	DevNull		; 16
	Dd	DevNull		; 20
	;
	Dd	BeginIO		; 24
	Dd	AbortIO		; 28
	Dd	-1		; 32


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DevCommands	Dd	DevCmdInvalid		; CMD_INVALID
	Dd	DevCmdReset		; CMD_RESET
	Dd	DevCmdRead		; CMD_READ
	Dd	DevCmdWrite		; CMD_WRITE
	Dd	DevCmdUpdate		; CMD_UPDATE
	Dd	DevCmdClear		; CMD_CLEAR
	Dd	DevCmdStop		; CMD_STOP
	Dd	DevCmdStart		; CMD_START
	Dd	DevCmdFlush		; CMD_FLUSH
	Dd	-1


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DevOpenCount	Dd	0


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DevInit	XOr	eax,eax
	Ret


	Struc DevOpenMem
DO_SysBase	ResD	1
DO_UteBase	ResD	1
DO_DevMem	ResD	1
DO_TagList	ResD	1
DO_IORequest	ResD	1
DO_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DevOpen	Cmp dword	[DevOpenCount],0
	Jne near	.AlreadyOpened

	LINK	DO_SIZE
	Mov	[ebp+DO_IORequest],ebx
	Mov	[ebp+DO_SysBase],ecx

	Lea	eax,[UteN]
	XOr	ebx,ebx
	LIB	OpenLibrary,[ebp+DO_SysBase]
	Mov	[ebp+DO_UteBase],eax
	;
	Mov	eax,_SIZE
	Mov	ebx,MEMF_NOKEY
	LIB	AllocMem
	Mov	[ebp+DO_DevMem],eax
	Mov	[DevTable],eax
	Mov	ebx,[ebp+DO_IORequest]
	Mov	edi,[ebp+DO_DevMem]
	Mov	[edi+_IORequest],ebx	; User IORequest
	;
	Bts dword	[ebx+IO_FLAGS],IOB_WAITREQUIRED
	;
	Lea	eax,[DevProcTags]
	LIB	CloneTaglist,[ebp+DO_UteBase]
	Mov	[ebp+DO_TagList],eax
	Mov	[eax+4],edi		; Device memorypointer as userdata
	Mov	ecx,eax
	LIB	AddProcess,[ebp+DO_SysBase]

	Mov	eax,[ebp+DO_TagList]
	LIB	FreeTaglist,[ebp+DO_UteBase]
	;-
	Mov	eax,[ebp+DO_UteBase]
	LIB	CloseLibrary,[ebp+DO_SysBase]

	UNLINK	DO_SIZE
	;
.AlreadyOpened	Inc dword	[DevOpenCount]
	Ret


UteN	Db	"utility.library",0

DevProcTags	Dd	AP_USERDATA,0
	Dd	AP_PROCESSPOINTER,DevDaemon
	Dd	AP_STACKSIZE,1024
	Dd	AP_RING,2
	Dd	AP_QUANTUM,2
	Dd	AP_NAME,DevName
	Dd	TAG_DONE

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DevClose	Mov dword	[ebx+IO_DEVICE],0
	Dec dword	[DevOpenCount]
	Jz	DevExpunge
	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DevExpunge
	; send KILL to the daemon
	; free up some memory etc..
	; return -1 to eax so the CloseDevice() can unlink us from the devicelist.

	;
	Mov	eax,-1
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DevNull	XOr	eax,eax
	Ret


	Struc TemplateDevice
_MsgPort	ResD	1	; Messageport of the device
_IORequest	ResD	1	; Current I/O request structure
_SysBase	ResD	1	; SysBase
_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DevDaemon	Mov	ebp,edx
	Mov	[ebp+_SysBase],eax
	LIB	CreateMsgPort,[ebp+_SysBase]
	Mov	[ebp+_MsgPort],eax
	Mov	ebx,[ebp+_IORequest]
	Mov	eax,[ebx+MN_REPLYPORT]
	Mov dword	[ebx+IO_DATA],DEV_READY	; Device-Ready identifier
	LIB	PutMsg
	;
.Main	LIB	Wait,[ebp+_SysBase]
.L	LIB	GetMsg,[ebp+_SysBase]
	Test	eax,eax
	Jz	.Main
	Mov	ebx,[eax+MN_PORTID]
	Mov	ecx,[ebp+_MsgPort]
	Cmp	ebx,[ecx+MP_ID]
	Jne	.NoMessage
	;
	Mov	[ebp+_IORequest],eax	; ebp holds pointer to device memory
	;			; don't trash it..
	Mov	ebx,[eax+IO_COMMAND]
	Mov	ebx,[DevCommands+ebx*4]
	Push	ebp
	Call	ebx
	Pop	ebp
	;
.NoMessage	Mov	eax,[ebp+_IORequest]
	LIB	ReplyMsg,[ebp+_SysBase]
	Jmp	.L



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
BeginIO	PUSHX	ebx,ebp,edx
	Push	eax
	Mov	ebp,[DevTable]
	Mov	eax,[ebp+_MsgPort]	; Device messageport
	Pop	ebx		; Message containing I/O structure
	LIB	PutMsg,[ebp+_SysBase]
	POPX	ebx,ebp,edx
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
AbortIO
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DevCmdInvalid
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DevCmdReset
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DevCmdRead
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DevCmdWrite
	Ret
DevCmdUpdate
	Ret
DevCmdClear
	Ret
DevCmdStop
	Ret
DevCmdStart
	Ret
DevCmdFlush
	Ret

