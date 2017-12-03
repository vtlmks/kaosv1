;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Serial device.
;
;     Device driver for motherboard based serial units.
;     Supports upto 4 units.
;

	%Include	"c:\Kaos\Includes\Macros.I"
	%Include	"c:\Kaos\Includes\TypeDef.I"
	%Include	"c:\Kaos\Includes\Lists.I"
	%Include	"c:\Kaos\Includes\Nodes.I"
	%Include	"c:\Kaos\Includes\TagList.I"
	%Include	"c:\Kaos\Includes\Ports.I"
	%Include	"c:\Kaos\Includes\Libraries.I"
	%Include	"c:\Kaos\Includes\IO.I"
	%Include	"c:\Kaos\Includes\SysBase.I"

	%Include	"c:\Kaos\Includes\Exec\IO.I"
	%Include	"c:\Kaos\Includes\Exec\LowLevel.I"
	%Include	"c:\Kaos\Includes\Exec\Memory.I"

	%Include	"c:\Kaos\Includes\Hardware\PIC.I"
	%Include	"c:\Kaos\Includes\Hardware\Serial.I"

	%Include	"c:\Kaos\Includes\LVO\Exec.I"
	%Include	"c:\Kaos\Includes\LVO\Utility.I"


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

DevName	Db	"serial.device",0
DevIDString	Db	"serial.device 1.0 (2001-03-07)",0


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
	Movzx	eax,ax
	Shr	eax,9
	Test	eax,eax
	Jz	.NoPorts
	Mov	[ebp+_NumUnits],eax	; Number of units
	Clc
	Ret
.NoPorts	Stc
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
dev_UnitPort	ResD	1	; Unit hardware baseport
dev_UnitNumber	ResD	1	; Unit number, 0 - 3
dev_UnitIRQ	ResD	1	; Unit IRQ, 3 or 4
dev_SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
	; eax=execbase
	; edx=userdata (unitmem)

DevDaemon	Mov	edi,edx
	Mov	edx,eax
	Push	ebx
	Mov	eax,dev_SIZE
	XOr	ebx,ebx
	LIB	AllocMem
	Pop	ebx
	Mov	ebp,eax
	Mov	[ebp+dev_UnitMemory],edi
	Mov	[ebp+dev_ExecBase],edx
	Mov	eax,[edi+DU_UnitNumber]
	Mov	ebx,[DeviceUnits+eax*4]
	Mov	[ebp+dev_UnitPort],ebx
	Mov	ebx,[DeviceIrqs+eax*4]
	Mov	[ebp+dev_UnitIRQ],ebx
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
OpenPort	Mov	edi,[ebp+dev_UnitNumber]
	Mov	edi,[DeviceUnits+edi*4]
	Lea	edx,[edi+UART_LSR]	; Line status, wait for it to line to be empty
.L	In	al,dx
	And	al,UARTLSRF_EMPTYTHR|UARTLSRF_EMPTYDHR
	Cmp	al,UARTLSRF_EMPTYTHR|UARTLSRF_EMPTYDHR
	Jne	.L
	;
	Lea	edx,[edi+UART_LCR]	; Line control
	Mov	al,UARTLCRF_DLAB		; Divisor latch access
	Out	dx,al
	;
	Mov	eax,12		; 115200
	Mov	bx,[DeviceLatches+eax*2]
	Mov	al,bh
	Lea	edx,[edi+UART_DLH]	; Divisor latch high byte
	Out	dx,al
	;
	Mov	al,bl
	Lea	edx,[edi+UART_DLL]	; Divisor latch low byte
	Out	dx,al
	;
	Mov	al,UARTLCRF_STOPBITWLEN1|UARTLCRF_STOPBITWLEN2	; 8n1?
	Lea	edx,[edi+UART_LCR]	; Line control
	Out	dx,al
	;
	XOr	al,al
	Lea	edx,[edi+UART_MCR]	; Modem control
	Out	dx,al
	;
	XOr	al,al
	Lea	edx,[edi+UART_IER]	; Interrupt enable
	Out	dx,al
	;
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClosePort	Mov	edi,[ebp+dev_UnitNumber]
	Mov	edi,[DeviceUnits+edi*4]
	Lea	edx,[edi+UART_IER]
	XOr	al,al
	Out	dx,al
	Lea	edx,[edi+UART_MCR]
	Out	dx,al
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SerialTx	Mov	edi,[ebp+dev_UnitNumber]
	Mov	edi,[DeviceUnits+edi*4]
	Lea	edx,[edi+UART_LSR]
.L	In	al,dx
	And	al,UARTLSRF_EMPTYDHR
	Jz	.L

	Mov	al,"Z"		; byte to send

	Lea	edx,[edi+UART_TX]
	Out	dx,al		; Send byte
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SerialRx	Mov	edi,[ebp+dev_UnitNumber]
	Mov	edi,[DeviceUnits+edi*4]
	Lea	edx,[edi+UART_LSR]
.L	In	al,dx
	Test	al,UARTLSRF_DRDY		; Data ready
	Jz	.L
	;
	Lea	edx,[edi+UART_RX]
	In	al,dx		; Receive byte
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SerialIRQ_IRQ3	PushAD
	PushFD


	; unit 1
	Mov	edi,[DeviceUnits+1*4]
	Lea	edx,[edi+UART_LSR]
.WaitUnit1	In	al,dx
	Test	al,UARTLSRF_DRDY
	Jz	.WaitUnit1

	Lea	edx,[edi+UART_RX]
	In	al,dx		; Receive shit..



	; unit 3
	Mov	edi,[DeviceUnits+3*4]
	Lea	edx,[edi+UART_LSR]
.WaitUnit3	In	al,dx
	Test	al,UARTLSRF_DRDY
	Jz	.WaitUnit3

	Lea	edx,[edi+UART_RX]
	In	al,dx		; Receive shit..


	;---
	Mov	al,PIC_EOI
	Out	PIC_M,al
	PopFD
	PopAD
	IRetd



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SerialIRQ_IRQ4	PushAD
	PushFD


	; unit 0

	Mov	edi,[DeviceUnits+0*4]
	Lea	edx,[edi+UART_LSR]
.WaitUnit0	In	al,dx
	Test	al,UARTLSRF_DRDY
	Jz	.WaitUnit0


	Lea	edx,[edi+UART_RX]
	In	al,dx		; Receive shit..


	; unit 2

	Mov	edi,[DeviceUnits+2*4]
	Lea	edx,[edi+UART_LSR]
.WaitUnit2	In	al,dx
	Test	al,UARTLSRF_DRDY
	Jz	.WaitUnit2

	Lea	edx,[edi+UART_RX]
	In	al,dx		; Receive shit..




	;---
	Mov	al,PIC_EOI
	Out	PIC_M,al
	PopFD
	PopAD
	IRetd




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DeviceUnits	Dd	UART0_BASE	; SER0:
	Dd	UART1_BASE	; SER1:
	Dd	UART2_BASE	; SER2:
	Dd	UART3_BASE	; SER3:

DeviceIrqs	Dd	4
	Dd	3
	Dd	4
	Dd	3

DeviceBaudRates	Dd	50	; 0
	Dd	75	; 1
	Dd	110	; 2
	Dd	300	; 3
	Dd	600	; 4
	Dd	1200	; 5
	Dd	2400	; 6
	Dd	4800	; 7
	Dd	9600	; 8
	Dd	19200	; 9
	Dd	38400	; 10
	Dd	57600	; 11
	Dd	115200	; 12


; divisor = 1843200 / (BaudRate * 16);
;
%DEFINE	DVIS(a)	1843200/(a*16)

DeviceLatches	Db	DVIS(50)>>8,	DVIS(50)&0xff
	Db	DVIS(75)>>8,	DVIS(75)&0xff
	Db	DVIS(110)>>8,	DVIS(110)&0xff
	Db	DVIS(300)>>8,	DVIS(300)&0xff
	Db	DVIS(600)>>8,	DVIS(600)&0xff
	Db	DVIS(1200)>>8,	DVIS(1200)&0xff
	Db	DVIS(2400)>>8,	DVIS(2400)&0xff
	Db	DVIS(4800)>>8,	DVIS(4800)&0xff
	Db	DVIS(9600)>>8,	DVIS(9600)&0xff
	Db	DVIS(19200)>>8,	DVIS(19200)&0xff
	Db	DVIS(38400)>>8,	DVIS(38400)&0xff
	Db	DVIS(57600)>>8,	DVIS(57600)&0xff
	Db	DVIS(115200)>>8,	DVIS(115200)&0xff
