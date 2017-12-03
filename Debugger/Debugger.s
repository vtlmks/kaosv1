;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Debugger.s V1.0.0
;
;     This is the internal "debugger", to be used only by Mindkiller Systems internally while
;     developing the kernel; this is where we roam atm =).
;
;

;;%DEFINE	SERIAL_DEBUG		; Comment this line out to disable serport sniffing


DBG_MAXCHARS	Equ	79	; Maximum chars to accept per line
DBG_MAXPARAMS	Equ	8	; Maximum number of arguments


PromptRow	Equ	31*8*1024
FirstRow	Equ	5*8*1024
SecondRow	Equ	6*8*1024
LastRow	Equ	30*8*1024
WinSize	Equ	26*8*1024
RowSize	Equ	8*1024
ScrollSize	Equ	26*8

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DebuggerInit	Mov dword	[DebugXPos],0
	Mov dword	[DebugYPos],3
	Mov dword	[DebugCounter],0
	Call	SetupDebugCom
	Mov	esi,DebugMainTxt
	Call	DebWriteLines
	Call	DebPrompt
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
Debugger	LIBCALL	Wait,ExecBase
	LIBCALL	GetMsg,ExecBase
	Push	eax
	Mov	eax,[eax+UIPKT_DATA]
	Movzx	eax,al
	Mov	[DebugInChar],al
	Call	DebParseByte
	Pop	eax
	LIBCALL	FreeMem,ExecBase
	Jmp	Debugger

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DebParseByte	XOr	ebx,ebx
.Next	Mov	eax,[DebugInTable+ebx]
	Test	eax,eax
	Jz	.Done
	Cmp	eax,[DebugInChar]
	Je	.Match
	Lea	ebx,[ebx+8]
	Jmp	.Next
.Match	Mov	eax,[DebugInTable+ebx+4]
	Call	eax
	Ret
.Done	Mov	ebx,[DebugCounter]
	Cmp	ebx,DBG_MAXCHARS
	Jge	.NoMore
	Mov	al,[DebugInChar]
	Mov	[DebugParseBuf+ebx],al
	Mov byte	[DebugParseBuf+ebx+1],0
	Inc dword	[DebugCounter]
	Call	DebWriteToPrompt
.NoMore	Ret



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Output one character to the screen from AL to the correct position.
;
DebWriteToPrompt	Cmp	al,0x0a
	Je	.Linefeed

	Movzx	esi,al
	Mov	eax,[PromptXPos]
	Mov	ebx,[PromptYPos]
	Mov	[CharXPos],eax
	Mov	[CharYPos],ebx
	Call	CharBlit

	Mov	eax,[PromptXPos]
	Inc	eax
	Cmp	eax,80
	Jge	.Linefeed
	Mov	[PromptXPos],eax
.Linefeed	Ret


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Output one character to the screen from AL to the correct position.
;
DebWriteChar	Cmp	al,0x0a
	Je	.Linefeed

	PUSHAD
	Movzx	esi,al
	Mov	eax,[DebugXPos]
	Mov	ebx,[DebugYPos]
	Mov	[CharXPos],eax
	Mov	[CharYPos],ebx
	Call	CharBlit
	POPAD

	Mov	eax,[DebugXPos]
	Inc	eax
	Cmp	eax,80
	Jge	.Linefeed
	Mov	[DebugXPos],eax
	Ret
	;
.Linefeed	Mov	eax,[DebugYPos]
	Inc	eax
	Cmp	eax,30
	Jb	.NoScroll

;	PushAD
;	Call	MGA_BltBitmap
;	PopAD


	Mov	esi,[SysBase+SB_VESA+VESA_MEMPTR]
	Mov	edi,esi
	Lea	esi,[esi+SecondRow]		; Fourth line Line
	Lea	edi,[edi+FirstRow]
	Mov	edx,ScrollSize
.Loop	Mov	ecx,640/4
	Rep Movsd
	Lea	esi,[esi+1024-640]
	Lea	edi,[edi+1024-640]
	Dec	edx
	Jnz	.Loop
	XOr	eax,eax
	Mov	edi,[SysBase+SB_VESA+VESA_MEMPTR]
	Lea	edi,[edi+LastRow]
	Mov	ecx,RowSize/4
	Rep Stosd
	Jmp	.NoUpdate
	;
.NoScroll	Mov	[DebugYPos],eax
.NoUpdate	Mov dword	[DebugXPos],0
	Ret


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Write nullterminated lines to the debugconsole, also supports different
; colorcodes to give some fancy output.
;
; Inputs:  esi == nullterminated pointer to string
;
DebWriteLines	Call	WriteDebugCom
	XOr	eax,eax
	Lodsb
	Test	al,al
	Jz	.Done
.L	Push	esi
	Call	DebWriteChar
	Pop	esi
	XOr	eax,eax
	Lodsb
	Test	al,al
	Jnz	.L
.Done	Ret


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DebPrompt	XOr	eax,eax
	Mov	edi,[SysBase+SB_VESA+VESA_MEMPTR]
	Lea	edi,[edi+PromptRow]
	Mov	ecx,1024*8/4
	Rep Stosd
	;
	Mov dword	[PromptXPos],1
	Mov dword	[PromptYPos],31
	Mov dword	[CharXPos],0
	Mov dword	[CharYPos],31
	Mov	esi,">"
	Call	CharBlit
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DebLineFeed	Mov dword 	[DebugCounter],0
	Call	DebParseLine
	Call	DebPrompt
	Call	DebClearBuf
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DebBackSpace	Mov	ebx,[DebugCounter]
	Test	ebx,ebx
	Jz	.Done
	Dec	ebx
	Mov	[DebugCounter],ebx

	Mov	esi," "
	Mov	eax,[PromptXPos]
	Mov	ebx,[PromptYPos]
	Mov	[CharXPos],eax
	Mov	[CharYPos],ebx
	Call	CharBlit
	Dec dword	[PromptXPos]
	;
	Mov	ebx,[DebugCounter]
	Mov byte	[DebugParseBuf+ebx],0
.Done	Ret



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Clear input buffer
DebClearBuf	Mov	edi,DebugParseBuf
	XOr	eax,eax
	Mov	ecx,256/4
	Rep Stosd
	Ret


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DebGetParams	Mov dword	[DbgFuncArray],0
	Mov	esi,DebugArgsBuf
	XOr	ebx,ebx
	XOr	ecx,ecx
.L	Lodsb
	Test	al,al
	Jz	.Done
	Cmp	al,0x20
	Jne	.L
	Call	.Function
	Cmp	ecx,DBG_MAXPARAMS
	Jne	.L
.Done	Ret

.Function	Mov byte	[esi-1],0
	Mov	[DbgFuncArray+ebx*4],esi
	Inc	ebx
	Inc	ecx
	Ret

DbgFuncArray	Times DBG_MAXPARAMS Dd 0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DebParseLine	XOr	ebx,ebx
	Cmp byte	[DebugParseBuf],0
	Jne	.Args
	Ret
	;
.Args	Cld
	Lea	esi,[DebugParseBuf]
	Lea	edi,[DebugArgsBuf]
	Mov	ecx,64
	Rep Movsd
	;
.MainLoop	Mov	esi,[DebugTable+ebx*4]
	Test	esi,esi
	Jz	.Done
	Lea	edi,[DebugArgsBuf]
.Loop	Lodsb
	Mov byte	ah,[edi]
	Inc	edi
	Cmp	al,ah
	Jne	.NoMatch
	Test	al,al
	Jnz	.Loop
	Jmp	.Match
	;
.NoMatch	Test	al,al
	Jnz	.L
	Cmp	ah,0x20
	Je	.Match
.L	Lea	ebx,[ebx+2]
	Jmp	.MainLoop
	;
.Match	Lea	eax,[DebugTable+4+ebx*4]
	Call	[eax]
	Ret
.Done	Mov	esi,InvalidCmdTxt
	Call	DebWriteLines
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; edi = Screen memory pointer <top left>
; esi = Char to print
; CharColor
; CharXPos
; CharYPos

CharBlit	Mov	eax,[CharXPos]
	Mov	edi,[SysBase+SB_VESA+VESA_MEMPTR]
	Lea	edi,[edi+eax*8]
	Mov	eax,[CharYPos]
	Shl	eax,13
	Lea	edi,[edi+eax]
	Shl	esi,6
	Lea	esi,[FontData+esi]
	Mov	ecx,8
.L	Movsd
	Movsd
	Lea	edi,[edi+1024-8]
	Dec	ecx
	Jnz	.L
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SetupDebugCom:
	%IFDEF SERIAL_DEBUG
	Mov	al,0x83
	Mov	dx,UART1_BASE+UART_LCR	; 8n1, prepare to set latch
	Out	dx,al
	;
	Mov	al,0x01
	Mov	dx,UART1_BASE+UART_DLL	; 115k2
	Out	dx,al
	;
	Mov	al,0x00
	Mov	dx,UART1_BASE+UART_DLH
	Out	dx,al
	;
	Mov	al,0x03		; 8n1
	Mov	dx,UART1_BASE+UART_LCR
	Out	dx,al
	;
	Mov	al,0x00
	Mov	dx,UART1_BASE+UART_IER	; Disable interrupts
	Out	dx,al
	%ENDIF
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
WriteDebugCom:
	%IFDEF SERIAL_DEBUG
	Pushad
.L	Mov	dx,UART1_BASE+UART_LSR
.Main	In	al,dx
	And	al,UARTLSRF_EMPTYDHR
	Jz	.Main
	Mov	dx,UART1_BASE+UART_TX
	Lodsb
	Test	al,al
	Jz	.Done
	Out	dx,al
	Jmp	.L
.Done	Popad
	%ENDIF
	Ret



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; help() -- display help screen
Func1	Mov	esi,DebugHelpTxt
	Call	DebWriteLines
	Ret

DoForever	Lea	ecx,[DoForeverTags]
	LIBCALL	AddProcess,ExecBase
	Ret

DoForeverProc:	;;;LIBCALL	Disable,ExecBase
	Jmp	$	; ye.


DoForeverTags	Dd	AP_PROCESSPOINTER,DoForeverProc
	Dd	AP_PRIORITY,0
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,1024
	Dd	AP_RING,2
	Dd	AP_QUANTUM,1
	Dd	AP_NAME,DoForeverProcN
	Dd	TAG_DONE

DoForeverProcN	Db	'doforever proc',0



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; cls() -- clearscreen
Func4	Mov	edi,[SysBase+SB_VESA+VESA_MEMPTR]
	Lea	edi,[edi+1024*8*4]
	Mov	ecx,1024*(768-5*8)/4
	XOR	eax,eax
	Rep Stosd
	Mov dword	[DebugXPos],0
	Mov dword	[DebugYPos],3
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
DebugParseBuf	Times 256 Db 0
DebugArgsBuf	Times 256 Db 0
DebugInChar	Dd	0
DebugCounter	Dd	0

DebuggerPrintBuffer Times 8 Db	0
	Db	0xa,0



PromptXPos	Dd	0
PromptYPos	Dd	0
DebugXPos	Dd	0
DebugYPos	Dd	0

CharXPos	Dd	0
CharYPos	Dd	0

DebugInTable	Dd	0xa,DebLineFeed
	Dd	0xd,DebLineFeed
	Dd	0x8,DebBackSpace
	Dd	0

DebugTable	Dd	Func1N,Func1
	Dd	ExitN,Shutdown
	Dd	ShutdownN,Shutdown
	Dd	Func4N,Func4
	Dd	MemDumpN,MemDumpProc
	Dd	ShowInfoN,DebShowInfo
	Dd	ShowListN,ShowList
	Dd	DebuggerListN,DebuggerList
	Dd	DoForeverN,DoForever
	Dd	LoadN,Load
	Dd	SprintfN,Sprintf
	Dd	OpenVesaN,OpenVesa
	Dd	RunProcN,RunProc
	Dd	OpenMGAN,OpenMGA
	Dd	AssignN,AssignTest
	Dd	TimerTestN,TimerTest
	Dd	SwitchBackN,SwitchBack
	Dd	MasterTestN,masterTest
	Dd	SlaveTestN,slaveTest
	Dd	SlakenN,Doitdeluxe
	Dd	MailN,DumpMessages
	Dd	V86N,V86Test
	Dd	0

Func1N	Db	"help",0
ExitN	Db	"exit",0
MemDumpN	Db	"m",0
Func4N	Db	"cls",0
ShutdownN	Db	"shutdown",0
ShowInfoN	Db	"showinfo",0

ShowListN	Db	"showlist",0
DebuggerListN	Db	"list",0

DoForeverN	Db	"doforever",0
LoadN	Db	"load",0
SprintfN	Db	"sprintf",0
OpenVesaN	Db	"openvesa",0
OpenMGAN	Db	"openmga",0
RunProcN	Db	"run",0
AssignN	Db	"assign",0
TimerTestN	Db	"timer",0
SwitchBackN	Db	"switchback",0
MasterTestN	Db	"master",0
SlaveTestN	Db	"slave",0
SlakenN	Db	"slaken",0
MailN	Db	"mail",0
V86N	Db	"v86",0
LFTxt	Db	0xa,0

DebugMainTxt	Db	"KAOS V0.3.4 PL2 Beta 1 Copyright (C) 1999-2001 Mindkiller Systems inc.",0xa,0xa,0xa
	Db	"Debugger spawned.",0xa,0xa,0

InvalidCmdTxt	Db	0xa,0xa,"?Invalid command. Type 'help' for options.",0xa,0xa,0

DebugHelpTxt	Db	0xa,0xa
	Db	"KAOS Debugger V0.0.1",0xa
	Db	"Copyright (c) 1999-2001 Mindkiller Systems inc.",0xa
	Db	"All rights reserved.",0xa,0xa
	Db	"Available commands:",0xa,0xa
	;-
	Db	"Cls              -                 Clear screen",0xa
	Db	"Exit             -                 Shutdown",0xa
	Db	"FreeMem          MemPtr            Free allocation",0xa
	Db	"Help             -                 Display help",0xa
	Db	"List             Listnumber        Display a list",0xa
	Db	"M                Offset, Length    Dump memory",0xa
	Db	"Mount            -                 Mount root",0xa
	Db	"Open             -                 Open test",0xa
	Db	"Run              -                 Run command",0xa
	Db	"ShowInfo         -                 Display some info",0xa
	Db	"ShowList         ListPtr           Display absolute list",0xa
	Db	"OpenVesa         -                 Open vesa driver",0xa
	Db	"OpenMGA          -                 Open mga driver",0xa
	Db	"assign           -                 assigns some test..",0xa
	Db	"master           -                 Message master..",0xa
	Db	"slave            -                 Slave message sender..",0xa
	Db	"mail             -                 Check POP3..",0xa
	;-
	Db	0


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	%Include	"Init\FontData2.s"

	%Include	"Debugger\DosOpen.s"
	%Include	"Debugger\ListFunctions.s"
	%Include	"Debugger\MemDump.s"
	%Include	"Debugger\ShowInfo.s"
	%Include	"Debugger\SprintfTest.s"
	%Include	"Debugger\VesaTest.s"
	%Include	"Debugger\Run.s"

	%Include	"Debugger\AssignTest.s"
	%Include	"Debugger\TimerTest.s"
	%Include	"Debugger\SwitchBack.s"
	%Include	"Debugger\msgtest.s"
	%Include	"Debugger\Slaken.s"
	%Include	"Debugger\DumpMessages.s"
	%Include	"Debugger\V86Test.s"
	