;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     ListFunctions.s V1.0.0
;
;     Misc list functions for the debugger.
;





;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%Macro	NODEINFO	2
	PUSHX	esi,edi
	Mov	eax,%1
	Mov	edi,NBuffer
	Call	Hex2AscII
	Mov	esi,%2
	Call	DebWriteLines
	Lea	esi,[NBuffer]
	Call	DebWriteLines
	POPX	esi,edi
%Endm


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; ShowList -- Display a specific list, specified by absolute address.
;

MAXNODETYPES	Equ	14

ShowList	Call	DebGetParams
	Lea	esi,[ListTxt]
	Call	DebWriteLines
	Mov	eax,[DbgFuncArray]
	Call	AscII2Hex
ShowListI	LIBCALL	Disable,ExecBase
	;
.L	NEXTNODE	eax,near .Exit
	;
	PushAD
	Push	eax
	NODEINFO	eax,AlignLFTxt
	Mov	eax,[esp]
	NODEINFO	[eax+LN_SUCC],AlignTxt
	Mov	eax,[esp]
	NODEINFO	[eax+LN_PRED],AlignTxt
	;
	Mov	eax,[esp]
	XOr	ecx,ecx
	Mov	cl,[eax+LN_TYPE]
	Cmp	cl,MAXNODETYPES
	Jb	.Valid
	XOr	ecx,ecx
.Valid	Mov	esi,[TypeTable+ecx*4]
	Call	DebWriteLines
	;
	Pop	eax
	Mov	esi,[eax+LN_NAME]
	Test	esi,esi
	Jz	.NoName
	Call	DebWriteLines
	;
.NoName	PopAD
	Jmp	.L
.Exit	LIBCALL	Enable,ExecBase
	Ret

ListTxt	Db	10,10," Node       Succ       Pred       Type         Name",10
	Db	   "========== ========== ========== ============ ===============================",0

AlignLFTxt	Db	10,"0x",0
AlignTxt	Db	" 0x",0

NBuffer	Times 9 db	0

TypeTable	Dd	NTUnknownN
	Dd	NTProcessN
	Dd	NTInterruptN
	Dd	NTDeviceN
	Dd	NTLibraryN
	Dd	NTMsgPortN
	Dd	NTMessageN
	Dd	NTFreeMsgN
	Dd	NTReplyMsgN
	Dd	NTResourceN
	Dd	NTMemoryN
	Dd	NTThreadN
	Dd	NTSemaphoreN
	Dd	NTSignalSemN
	Dd	NTFontN
	Dd	NTSoftIntN
	Dd	NTGraphicsN
	Dd	NTDriverN

NTUnknownN	Db	" NT_UNKNOWN   ",0	;0
NTProcessN	Db	" NT_PROCESS   ",0	;1
NTInterruptN	Db	" NT_INTERRUPT ",0	;2
NTDeviceN	Db	" NT_DEVICE    ",0	;3
NTLibraryN	Db	" NT_LIBRARY   ",0	;4
NTMsgPortN	Db	" NT_MSGPORT   ",0	;5
NTMessageN	Db	" NT_MESSAGE   ",0	;6
NTFreeMsgN	Db	" NT_FREEMSG   ",0	;7
NTReplyMsgN	Db	" NT_REPLYMSG  ",0	;8
NTResourceN	Db	" NT_RESOURCE  ",0	;9
NTMemoryN	Db	" NT_MEMORY    ",0	;10
NTThreadN	Db	" NT_THREAD    ",0	;11
NTSemaphoreN	Db	" NT_SEMAPHORE ",0	;12
NTSignalSemN	Db	" NT_SIGNALSEM ",0	;13
NTFontN	Db	" NT_FONT      ",0	;14
NTSoftIntN	Db	" NT_SOFTINT   ",0	;15
NTGraphicsN	Db	" NT_GRAPHICS  ",0	;16
NTDriverN	Db	" NT_DRIVER    ",0	;17

MAXDEBUGGER_LISTS	Equ	0x1d

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DebuggerList	Call	DebGetParams
	Mov	eax,[DbgFuncArray]
	Call	AscII2Hex
	Mov	edx,eax
	Test	edx,edx
	Jz	.ShowListHelp
	Cmp	edx,MAXDEBUGGER_LISTS
	Jg	.ShowListHelp
	Dec	edx
	;
	Push	edx
	Mov	esi,[ListTable+edx*8]
	Call	DebWriteLines
	Lea	esi,[ListTxt]
	Call	DebWriteLines
	Pop	edx
	Mov	eax,[ListTable+4+edx*8]

	Test	edx,edx
	Jz	ShowMemFreeList
	Cmp	edx,1
	Je near	ShowMemAllocList

	Call	ShowListI
	Ret
	;
.ShowListHelp	Lea	esi,[LSHelpTxt]
	Call	DebWriteLines
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ShowMemFreeList	Lea	edi,[SysBase+SB_MemoryFreeList]
	SPINLOCK	edi
.L	NEXTNODE	edi,near .Done
	NODEINFO	edi,AlignLFTxt
	NODEINFO	[edi+LN_SUCC],AlignTxt
	NODEINFO	[edi+LN_PRED],AlignTxt
	NODEINFO	[edi+ME_LENGTH],AlignTxt
	NODEINFO	[edi+ME_POINTER],AlignTxt
	XOr	ecx,ecx
	Mov	cl,[edi+LN_TYPE]
	Cmp	cl,MAXNODETYPES
	Jb	.Valid
	XOr	ecx,ecx
.Valid	Mov	esi,[TypeTable+ecx*4]
	Call	DebWriteLines
	Jmp	.L
	;
.Done	Lea	edi,[SysBase+SB_MemoryFreeList]
	SPINUNLOCK	edi
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ShowMemAllocList	Lea	edi,[SysBase+SB_AllocatedMemList]
	SPINLOCK	edi
.L	NEXTNODE	edi,near .Done
	NODEINFO	edi,AlignLFTxt
	NODEINFO	[edi+LN_SUCC],AlignTxt
	NODEINFO	[edi+LN_PRED],AlignTxt
	NODEINFO	[edi+ME_LENGTH],AlignTxt
	NODEINFO	[edi+ME_POINTER],AlignTxt
	NODEINFO	[edi+ME_PID],AlignTxt
	XOr	ecx,ecx
	Mov	cl,[edi+LN_TYPE]
	Cmp	cl,MAXNODETYPES
	Jb	.Valid
	XOr	ecx,ecx
.Valid	Mov	esi,[TypeTable+ecx*4]
	Pushad
	Call	DebWriteLines
	Popad
	Jmp	.L
	;
.Done	Lea	edi,[SysBase+SB_AllocatedMemList]
	SPINUNLOCK	edi
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ListTable	Dd	LSMemFreeTxt,SB_MemoryFreeList
	Dd	LSAllocTxt,SB_AllocatedMemList
	Dd	LSResourceTxt,SB_ResourceList
	Dd	LSDeviceTxt,SB_DeviceList
	Dd	LSLibraryTxt,SB_LibraryList
	Dd	LSPortTxt,SB_PortList
	Dd	LSProcReadyTxt,SB_ReadyList
	Dd	LSProcWaitTxt,SB_ProcWaitList
	Dd	LSProcTempTxt,SB_TempList
	Dd	LSTimerEventTxt,SB_TimerEventList
	Dd	LSDosListTxt,SB_DosList
	Dd	LSIRQ3Txt,SB_IRQ3
	Dd	LSIRQ4Txt,SB_IRQ4
	Dd	LSIRQ5Txt,SB_IRQ5
	Dd	LSIRQ6Txt,SB_IRQ6
	Dd	LSIRQ7Txt,SB_IRQ7
	Dd	LSIRQ9Txt,SB_IRQ9
	Dd	LSIRQ10Txt,SB_IRQ10
	Dd	LSIRQ11Txt,SB_IRQ11
	Dd	LSIRQ12Txt,SB_IRQ12
	Dd	LSIRQ13Txt,SB_IRQ13
	Dd	LSIRQ14Txt,SB_IRQ14
	Dd	LSIRQ15Txt,SB_IRQ15
	Dd	LSPCIListTxt,SB_PCIList
	Dd	LSPNPListTxt,SB_PNPList
	Dd	LSClassListTxt,SB_ClassList
	Dd	LSGDriverListTxt,SB_GfxDriverList
	Dd	LSESCDListTxt,SB_ESCDList
	Dd	LSDeadProcListTxt,SB_DeadProcList

LSHelpTxt	Db	10,10
	Db	"Available lists:",10,10
	Db	" 1 - MemoryFree List         16 - IRQ14 List",10
	Db	" 2 - AllocatedMemory List    17 - IRQ15 List",10
	Db	" 3 - Resource List           18 - PCI List",10
	Db	" 4 - Device List             19 - PnP List",10
	Db	" 5 - Library List            1a - Class List",10
	Db	" 6 - Port List               1b - GfxDriver List",10
	Db	" 7 - Process Ready List      1c - ESCD List",10
	Db	" 8 - Process Wait List       1d - DeadProc List",10
	Db	" 9 - Process Temporary List",10
	Db	" A - Timer Event List",10
	Db	" B - DosList",10
	Db	" C - IRQ3 List",10
	Db	" D - IRQ4 List",10
	Db	" E - IRQ5 List",10
	Db	" F - IRQ6 List",10
	Db	"10 - IRQ7 List",10
	Db	"11 - IRQ9 List",10
	Db	"12 - IRQ10 List",10
	Db	"13 - IRQ11 List",10
	Db	"14 - IRQ12 List",10
	Db	"15 - IRQ13 List",10
	Db	0

LSMemFreeTxt	Db	10,10,"MemoryFree List",0
LSAllocTxt	Db	10,10,"AllocatedMemory List",0
LSResourceTxt	Db	10,10,"Resource List",0
LSDeviceTxt	Db	10,10,"Device List",0
LSLibraryTxt	Db	10,10,"Library List",0
LSPortTxt	Db	10,10,"Port List",0
LSProcReadyTxt	Db	10,10,"Process Ready List",0
LSProcWaitTxt	Db	10,10,"Process Wait List",0
LSProcTempTxt	Db	10,10,"Process Temporary List",0
LSTimerEventTxt	Db	10,10,"Timer Event List",0
LSDosListTxt	Db	10,10,"DosList",0
LSIRQ3Txt	Db	10,10,"IRQ3 List",0
LSIRQ4Txt	Db	10,10,"IRQ4 List",0
LSIRQ5Txt	Db	10,10,"IRQ5 List",0
LSIRQ6Txt	Db	10,10,"IRQ6 List",0
LSIRQ7Txt	Db	10,10,"IRQ7 List",0
LSIRQ9Txt	Db	10,10,"IRQ9 List",0
LSIRQ10Txt	Db	10,10,"IRQ10 List",0
LSIRQ11Txt	Db	10,10,"IRQ11 List",0
LSIRQ12Txt	Db	10,10,"IRQ12 List",0
LSIRQ13Txt	Db	10,10,"IRQ13 List",0
LSIRQ14Txt	Db	10,10,"IRQ14 List",0
LSIRQ15Txt	Db	10,10,"IRQ15 List",0
LSPCIListTxt	Db	10,10,"PCI List",0
LSPNPListTxt	Db	10,10,"PNP List",0
LSClassListTxt	Db	10,10,"Class List",0
LSGDriverListTxt	Db	10,10,"GfxDriver List",0
LSESCDListTxt	Db	10,10,"ESCD List",0
LSDeadProcListTxt	Db	10,10,"Dead Proc List",0

