;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Interrupts.s V1.0.0
;
;     Interrupt supportcode.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; SetupIDT will first create a dummy IDT Table with 256 entries. Then it will
; initiate the IDT according to the entrys defined in the IDTEntrys table below.
; The interrupts may be written in any order, but should be written with ascending
; order for simplicity.
;
SetupIDT	Cld
	Mov	ecx,255
	Lea	edi,[SysBase+SB_IntTable]
	Lea	edx,[IntHandler]
.L	Mov	ax,dx
	Stosw
	Mov	eax,0x8e000008		; Move flagset, selector
	Stosd
	Rol	edx,16
	Mov	ax,dx
	Stosw
	Dec	ecx
	Jnz	.L
	;
	Lea	ebx,[IDTEntrys]
.NextEntry	Lea	edi,[SysBase+SB_IntTable]
	Mov	ecx,[ebx]
	Cmp	ecx,-1
	Je	.Done
	Lea	edi,[edi+ecx]		; Offset to interrupt in the table
	Mov	edx,[ebx+4]		; Move adress, base 31-16
	Mov	ax,dx
	Stosw
	Mov	eax,[ebx+8]		; Move flagset, selector
	Stosd
	Rol	edx,16
	Mov	ax,dx
	Stosw			; Move adress, base 0-15
	Lea	ebx,[ebx+12]
	Jmp	.NextEntry
.Done	LIDT	[IDTLimit]
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IntHandler	IRetd	; Dummy handler

	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IDTEntrys	Dd	0x00*8,Except00,0x8e000008	; Divide error
	Dd	0x01*8,Except01,0x8e000008	; Debug
	Dd	0x02*8,Except02,0x8e000008	; NMI
	Dd	0x03*8,Except03,0x8e000008	; Breakpoint
	Dd	0x04*8,Except04,0x8e000008	; Overflow
	Dd	0x05*8,Except05,0x8e000008	; Bound range exceeded
	Dd	0x06*8,Except06,0x8e000008	; Invalid opcode
	Dd	0x07*8,Except07,0x8e000008	; Device not available (no fpu)
	Dd	0x08*8,Except08,0x8e000008	; Double fault
	Dd	0x09*8,Except09,0x8e000008	; Coprocessor segment overrun
	Dd	0x0A*8,Except10,0x8e000008	; Invalid TSS
	Dd	0x0B*8,Except11,0x8e000008	; Segment not present
	Dd	0x0C*8,Except12,0x8e000008	; Stack-segment fault
;;;	Dd	0x0D*8,Except13,0x8e000008	; General protection, V86 handler
	Dd	0x0D*8,V86Exception,0x8e000008	; General protection, V86 handler
	Dd	0x0E*8,Except14,0x8e000008	; Page fault
	Dd	0x0F*8,Except15,0x8e000008	; *reserved*
	Dd	0x10*8,Except16,0x8e000008	; FPU error
	Dd	0x11*8,Except17,0x8e000008	; Alignment check
	Dd	0x12*8,Except18,0x8e000008	; Machine check
	Dd	0x13*8,Except19,0x8e000008	; SIMD extension
	;--
	Dd	0x20*8,TimerIRQ,0x8e000008	; Timer
	Dd	0x21*8,KeyboardIRQ,0x8e000008	; Keyboard
	Dd	0x23*8,IRQ3Handler,0x8e000008	; Free
	Dd	0x24*8,IRQ4Handler,0x8e000008	; Free
	Dd	0x25*8,IRQ5Handler,0x8e000008	; Free
	Dd	0x26*8,IRQ6Handler,0x8e000008	; Free
	Dd	0x27*8,IRQ7Handler,0x8e000008	; Free
	Dd	0x28*8,RTCHandler,0x8e000008	; Realtime Clock (RTC)
	Dd	0x29*8,IRQ9Handler,0x8e000008	; Free
	Dd	0x2a*8,IRQ10Handler,0x8e000008	; Free
	Dd	0x2b*8,IRQ11Handler,0x8e000008	; Free
	Dd	0x2c*8,PS2MouseIRQ,0x8e000008	; Free
	Dd	0x2d*8,IRQ13Handler,0x8e000008	; Free
	Dd	0x2e*8,IRQ14Handler,0x8e000008	; Free
	Dd	0x2f*8,IRQ15Handler,0x8e000008	; Free
	;--
	Dd	0x40*8,Ring0Service,0xee000008	; Instant access to ring0-code, put pointer to routine in eax
	Dd	0x60*8,EXEC_UserSwitch,0xee000008	; User switch, call it through exec.library
	Dd	0x61*8,EXEC_WaitStub,0xee000008	; Exec.library Wait stub..
	Dd	0x86*8,V86Handler,0xee000008	; Virtual86-mode handler
	Dd	0xfe*8,PrintLongword,0xee000008
	Dd	0xff*8,PrintTextstring,0xee000008
	Dd	-1


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -








;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PrintLongword	PushAD
	PushFD
	PUSHX	ds,es
	Mov	ebx,SYSDATA_SEL
	Mov	ds,bx
	Mov	es,bx
	PRINTLONG	eax
	POPX	ds,es
	PopFD
	PopAD
	IRetd

PrintTextstring	PushAD
	PushFD
	PUSHX	ds,es
	Mov	ebx,SYSDATA_SEL
	Mov	ds,bx
	Mov	es,bx
	PRINTTEXT	eax
	POPX	ds,es
	PopFD
	PopAD
	IRetd

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Grants ring 0 access to users who has the power..
;
; Put pointer to routine eax that should be executed in ring0.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
Ring0Service	PushAD
	PushFD
	PUSHX	ds,es
	Push	ebx
	Mov	ebx,SYSDATA_SEL
	Mov	ds,bx
	Mov	es,bx
	Pop	ebx
	Call	eax
	POPX	ds,es
	PopFD
	PopAD
	IRetd






;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Runs installed handlers in the specified IRQ. Handlers must be installed
; with AddIRQHandler() from exec.library and removed by RemoveIRQHandler().
;
;
	Struc UserIRQ
	ResB	LN_SIZE
UIRQ_HANDLER	ResD	1
UIRQ_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UserIRQHandler	Push	ecx
	Mov	ecx,[esp+4]
	PUSHX	ds,es,fs,gs
	PushFD
	PushAD
	Mov	eax,ss
	Mov	ds,ax
	Mov	es,ax
	Mov	fs,ax
	Mov	gs,ax
	Mov	ebx,[UserIRQTable+ecx*4]
	;
.L	NEXTNODE	ebx,.NoMore
	Push	ebx
	Call	[ebx+UIRQ_HANDLER]
	Pop	ebx
	Jmp	.L
	;
.NoMore	Mov	al,PIC_EOI
	Out	PIC_M,al
	Out	PIC_S,al
	PopAD
	PopFD
	POPX	ds,es,fs,gs
	Pop	ecx
	Lea	esp,[esp+4]
	IRetd

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IRQ3Handler	Push dword	0
	Jmp	UserIRQHandler

IRQ4Handler	Push dword	1
	Jmp	UserIRQHandler

IRQ5Handler	Push dword	2
	Jmp	UserIRQHandler

IRQ6Handler	Push dword	3
	Jmp	UserIRQHandler

IRQ7Handler	Push dword	4
	Jmp	UserIRQHandler

IRQ9Handler	Push dword	5
	Jmp	UserIRQHandler

IRQ10Handler	Push dword	6
	Jmp	UserIRQHandler

IRQ11Handler	Push dword	7
	Jmp	UserIRQHandler

IRQ12Handler	Push dword	8
	Jmp	UserIRQHandler

IRQ13Handler	Push dword	9
	Jmp	UserIRQHandler

IRQ14Handler	Push dword	10
	Jmp	UserIRQHandler

IRQ15Handler	Push dword	11
	Jmp	UserIRQHandler

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UserIRQTable	Dd	SysBase+SB_IRQ3
	Dd	SysBase+SB_IRQ3
	Dd	SysBase+SB_IRQ4
	Dd	SysBase+SB_IRQ5
	Dd	SysBase+SB_IRQ6
	Dd	SysBase+SB_IRQ7
	Dd	SysBase+SB_IRQ9
	Dd	SysBase+SB_IRQ10
	Dd	SysBase+SB_IRQ11
	Dd	SysBase+SB_IRQ12
	Dd	SysBase+SB_IRQ13
	Dd	SysBase+SB_IRQ14
	Dd	SysBase+SB_IRQ15



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IDTLimit	Dw	2048-1
	Dd	SysBase+SB_IntTable


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -


	Struc ExcFaults	; Stack within traps and faults (with errorcode)
exf_ErrorCode	ResD	1
exf_EIP	ResD	1
exf_CS	ResD	1
exf_EFLAGS	ResD	1
exf_ESP	ResD	1
exf_SS	ResD	1
exf_SIZE	EndStruc

	Struc ExcRegs
exr_EDI	ResD	1
exr_ESI	ResD	1
exr_EAX	ResD	1
exr_EBX	ResD	1
exr_ECX	ResD	1
exr_EDX	ResD	1
exr_EBP	ResD	1
exr_SIZE	EndStruc



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	EXCEPTION	3	; Label, String
%1	Mov dword	[ExceptionIndex],%2
	Mov dword	[ExceptionNum],%3
	Jmp	ExceptionHandler
%EndMacro

	EXCEPTION	Except00,Except0Txt,0
	EXCEPTION	Except01,Except1Txt,1
	EXCEPTION	Except02,Except2Txt,2
	EXCEPTION	Except03,Except3Txt,3
	EXCEPTION	Except04,Except4Txt,4
	EXCEPTION	Except05,Except5Txt,5
	EXCEPTION	Except06,Except6Txt,6
	EXCEPTION	Except07,Except7Txt,7
	EXCEPTION	Except08,Except8Txt,8
	EXCEPTION	Except09,Except9Txt,9
	EXCEPTION	Except10,Except10Txt,10
	EXCEPTION	Except11,Except11Txt,11
	EXCEPTION	Except12,Except12Txt,12
	EXCEPTION	Except13,Except13Txt,13
	EXCEPTION	Except14,Except14Txt,14
	EXCEPTION	Except15,Except15Txt,15
	EXCEPTION	Except16,Except16Txt,16
	EXCEPTION	Except17,Except17Txt,17
	EXCEPTION	Except18,Except18Txt,18
	EXCEPTION	Except19,Except19Txt,19

	EXCEPTION	Except86,Except86Txt,86

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
ExceptionHandler	Push	ax
	Mov	ax,ss
	Mov	ds,ax
	Mov	es,ax
	Mov	fs,ax
	Mov	gs,ax
	Pop	ax
	;
	Call	ExcStackDump
	IRetd


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; TO IMPLEMENT:
;
; If the failing process is not kernel/debugger,
; subtract Processptr from EIP and show it as "userlocation" or whatever,
; this will give us the offset from 0 in the executable that crashed..
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ExcStackDump	Cld
	Mov	[ExcFaultsRegs+exr_EDI],edi
	Mov	[ExcFaultsRegs+exr_ESI],esi
	Mov	[ExcFaultsRegs+exr_EAX],eax
	Mov	[ExcFaultsRegs+exr_EBX],ebx
	Mov	[ExcFaultsRegs+exr_ECX],ecx
	Mov	[ExcFaultsRegs+exr_EDX],edx
	Mov	[ExcFaultsRegs+exr_EBP],ebp
	Lea	esi,[esp+4]		; Since we are within a Call....
	Lea	edi,[ExcFaultsStack]
	Mov	ecx,6
	Rep Movsd
	;
	Call	ClearScreen
	Mov dword	[DebugXPos],0		; Reset debugger..
	Mov dword	[DebugYPos],0
	PRINTTEXT	[ExceptionIndex]
	;
	XOr	ecx,ecx
	Mov	ebx,[ExceptionNum]
	Lea	esi,[ExcCodeTable]
.Next	Lodsd
	Cmp	eax,-1
	Je	.Ok
	Cmp	ebx,eax
	Jne	.Next
	Inc	ecx
	Lea	esi,[ExcScheme]
	Jmp	.Ok2

.Ok	Lea	esi,[ExcScheme+4]
.Ok2	Lea	ecx,[ecx+5]

	;
	XOr	ebx,ebx
.L	PRINTTEXT	[esi+ebx*4]
	PRINTLONG	[ExcFaultsStack+ebx*4]
	Inc	ebx
	Loop	.L
	;
	;
	PRINTTEXT	ExcEAXTxt
	PRINTLONG	[ExcFaultsRegs+exr_EAX]
	PRINTTEXT	ExcEBXTxt
	PRINTLONG	[ExcFaultsRegs+exr_EBX]
	PRINTTEXT	ExcECXTxt
	PRINTLONG	[ExcFaultsRegs+exr_ECX]
	PRINTTEXT	ExcEDXTxt
	PRINTLONG	[ExcFaultsRegs+exr_EDX]
	PRINTTEXT	ExcESITxt
	PRINTLONG	[ExcFaultsRegs+exr_ESI]
	PRINTTEXT	ExcEDITxt
	PRINTLONG	[ExcFaultsRegs+exr_EDI]
	PRINTTEXT	ExcEBPTxt
	PRINTLONG	[ExcFaultsRegs+exr_EBP]

	;
	PRINTTEXT	ExcRaisedTxt
	Mov	ebx,[SysBase+SB_CurrentProcess]
	PRINTTEXT	[ebx+LN_NAME]
	PRINTTEXT	LFTxt
	;
	Call	DebShowInfo

	PRINTTEXT	ExcPressKey

	XOr	esi,esi
.Lx	In	al,0x60
	Test	al,al
	Jz	.Lx
	Movzx	eax,al
	And	al,0x7f
	Cmp	eax,esi
	Je	.Lx
	Mov	esi,eax

	Cmp	eax,0x13	; 'r'
	Je near	Shutdown
	Cmp	eax,0x2e	; 'c'
	Je	.Done
	Jmp	.Lx

.Done	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ExcCodeTable	Dd	8
	Dd	10
	Dd	11
	Dd	12
	Dd	13
	Dd	14
	Dd	17
	Dd	-1


ExcScheme	Dd	ExcStackCodeTxt
	Dd	ExcStackEIPTxt
	Dd	ExcStackCSTxt
	Dd	ExcStackEFlagsTxt
	Dd	ExcStackESPTxt
	Dd	ExcStackSSTxt


ExcStackCodeTxt	Db	"Errorcode: ",0
ExcStackEIPTxt	Db	"EIP      : ",0
ExcStackCSTxt	Db	"CS       : ",0
ExcStackEFlagsTxt	Db	"EFLAGS   : ",0
ExcStackESPTxt	Db	"ESP      : ",0
ExcStackSSTxt	Db	"SS       : ",0

ExcEAXTxt	Db	0xa,"EAX      : ",0
ExcEBXTxt	Db	"EBX      : ",0
ExcECXTxt	Db	"ECX      : ",0
ExcEDXTxt	Db	"EDX      : ",0
ExcESITxt	Db	"ESI      : ",0
ExcEDITxt	Db	"EDI      : ",0
ExcEBPTxt	Db	"EBP      : ",0

ExcRaisedTxt	Db	0xa,"Exception raised by: ",0

ExcPressKey	Db	0xa,0xa,"Press (R)eset or (C)ontinue ...",0xa,0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

Except0Txt	Db	"Exception 0: #DE - Divide error",10,10,0
Except1Txt	Db	"Exception 1: #DB - Debug",10,10,0
Except2Txt	Db	"Exception 2: #-- - NMI interrupt",10,10,0
Except3Txt	Db	"Exception 3: #BP - Breakpoint",10,10,0
Except4Txt	Db	"Exception 4: #OF - Overflow",10,10,0
Except5Txt	Db	"Exception 5: #BR - BOUND range exceeded",10,10,0
Except6Txt	Db	"Exception 6: #UD - Invalid opcode",10,10,0
Except7Txt	Db	"Exception 7: #NM - No FPU",10,10,0
Except8Txt	Db	"Exception 8: #DF - Double fault",10,10,0
Except9Txt	Db	"Exception 9: #-- - Coprocessor segment overrun",10,10,0
Except10Txt	Db	"Exception 10: #TS - Invalid TSS",10,10,0
Except11Txt	Db	"Exception 11: #NP - Segment not present",10,10,0
Except12Txt	Db	"Exception 12: #SS - Stack-segment fault",10,10,0
Except13Txt	Db	"Exception 13: #GP - General protection",10,10,0
Except14Txt	Db	"Exception 14: #PF - Page fault",10,10,0
Except15Txt	Db	"Exception 15: #-- - Reserved",10,10,0
Except16Txt	Db	"Exception 16: #MF - FPU error",10,10,0
Except17Txt	Db	"Exception 17: #AC - Alignment check",10,10,0
Except18Txt	Db	"Exception 18: #MC - Machine check",10,10,0
Except19Txt	Db	"Exception 19: #XF - Streaming SIMD extensions",10,10,0

Except86Txt	Db	"Virtual-8086 exception",10,10,0

ExceptionIndex	Dd	0
ExceptionNum	Dd	0
ExcFaultsStack	Times exf_SIZE Db 0
ExcFaultsRegs	Times exr_SIZE Db 0
ExcTempBuf	Db	"        ",0xa,0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

