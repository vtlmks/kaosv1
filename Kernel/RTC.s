;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     RTC.s V1.0.0
;
;     RealTimeClock (RTC) support code based on the
;     Motorola MC146814A/MC146818A CMOS chip.
;
;     The RTC is configured to give periodic interrupts
;     at a frequency of 1024 Hz.
;
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
RTCHandler	PushAD
	PushFD
	PUSHX	ds,es
	Mov	eax,SYSDATA_SEL
	Mov	ds,ax
	Mov	es,ax
	;
	Call	RTCTest		; ** REMOVE **

	Mov	al,RTC_StatusC
	Out	RTC_IndexPort,al
	In	al,RTC_DataPort

	Call	RTCUptime
	Call	RTCTimerEvent

	Mov	al,PIC_EOI
	Out	PIC_M,al
	Out	PIC_S,al
	POPX	ds,es
	PopFD
	PopAD
	IRetd

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
RTCUptime	Cmp dword	[SysBase+SB_Uptime+4],1024
	Je	.NewSecond
	Inc dword	[SysBase+SB_Uptime+4]
	Ret
.NewSecond	Mov dword	[SysBase+SB_Uptime+4],0
	Inc dword	[SysBase+SB_Uptime]
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
RTCTimerEvent	Lea	eax,[SysBase+SB_TimerEventList]
	Bt dword	[eax+LH_FLAGS],LHB_SLOCK	; Don't mess with the list if it's locked,
	Jc	.Done		; for now we skip 1/1024 instead.. this is a bogus solution
	SUCC	eax		; but will do for now.
	Test	eax,eax
	Jz	.Done
	Dec dword	[eax+TE_Ticks]
	Jnz	.Done
	;--
	Bt dword	[eax+TE_Flags],TEB_DELAY
	Jnc	.NoDelayEvent
	Push	eax
	Mov	eax,[eax+TE_Process]
	LIBCALL	Awake,ExecBase
	Pop	eax
	REMOVE
	Ret
	;--
.NoDelayEvent	Push	eax
	REMOVE
	Pop	ebx
	Lea	eax,[SysBase+SB_TimerDeadList]
	ADDTAIL

	Lea	eax,[TimerProcN]
	LIBCALL	FindProcess,ExecBase
	Test	eax,eax
	Jz	.Done
	LIBCALL	Awake,ExecBase
.Done	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	RTC_DTGET	2
	Mov	ah,%2
	Call	RTCRead
	Mov	%1,al
%EndMacro

%Macro	RTC_DTSET	2
	Mov	al,%1
	Mov	ah,%2
	Call	RTCWrite
%EndMacro




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
RTCTimerService	Lea	esi,[SysBase+SB_TimerServiceList]
.L	NEXTNODE	esi,.NoMore
	Mov	edi,[esi+DTS_DTStruct]
	Bt dword	[edi+DT_Flags],DTB_READ
	Jc	.ServiceRead
	Bt dword	[edi+DT_Flags],DTB_WRITE
	Jc near	.ServiceWrite
	Jmp	.L
.NoMore	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.ServiceRead	Bt dword	[edi+DT_Flags],DTB_TIME
	Jnc	.NoReadTime
	RTC_DTGET	[edi+DT_Seconds],RTC_Seconds
	RTC_DTGET	[edi+DT_Minutes],RTC_Minutes
	RTC_DTGET	[edi+DT_Hours],RTC_Hours
	;
.NoReadTime	Bt dword	[edi+DT_Flags],DTB_DATE
	Jnc	.NoReadDate
	RTC_DTGET	[edi+DT_Day],RTC_Day
	RTC_DTGET	[edi+DT_Month],RTC_Month
	RTC_DTGET	[edi+DT_Year],RTC_Year
	RTC_DTGET	[edi+DT_Century],RTC_Century
	;
.NoReadDate	Bt dword	[edi+DT_Flags],DTB_WEEKDAY
	Jnc	.NoReadWeekday
	RTC_DTGET	[edi+DT_Weekday],RTC_Weekday
.NoReadWeekday	Jmp	.L

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.ServiceWrite	Bt dword	[edi+DT_Flags],DTB_TIME
	Jnc	.NoWriteTime
	RTC_DTSET	[edi+DT_Seconds],RTC_Seconds
	RTC_DTSET	[edi+DT_Minutes],RTC_Minutes
	RTC_DTSET	[edi+DT_Hours],RTC_Hours
	;
.NoWriteTime	Bt dword	[edi+DT_Flags],DTB_DATE
	Jnc	.NoWriteDate
	RTC_DTSET	[edi+DT_Day],RTC_Day
	RTC_DTSET	[edi+DT_Month],RTC_Month
	RTC_DTSET	[edi+DT_Year],RTC_Year
	RTC_DTSET	[edi+DT_Century],RTC_Century
	;
.NoWriteDate	Bt dword	[edi+DT_Flags],DTB_WEEKDAY
	Jnc	.NoWriteWeekday
	RTC_DTSET	[edi+DT_Weekday],RTC_Weekday
.NoWriteWeekday	Jmp near	.L








;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; This is the debugger clock
;
RTCTest:
	%IFNDEF SERIAL_DEBUG

	Inc dword	[RTCCount]
	Cmp dword	[RTCCount],1023
	Jne near	.NoUpdate
	Mov dword	[RTCCount],0
	Lea	edi,[TempTime]
	Call	RTCGetTime
	Lea	edi,[TempDate]
	Call	RTCGetDate
	Push dword	[DebugXPos]
	Push dword	[DebugYPos]
	Mov dword	[DebugYPos],0
	Mov dword	[DebugXPos],50
	;
	Mov	eax,[TempTime]
	Lea	edi,[Tempo]
	Call	Hex2AscII
	Mov	eax,[TempDate]
	Lea	edi,[Tempo+8]
	Call	Hex2AscII
	;
	Lea	esi,[Tempo+2]
	Lea	edi,[TempStr]
	Movsw
	Mov	al,":"
	Stosb
	Movsw
	Stosb
	Movsw
	Mov	al," "
	Stosb
	Movsd
	Mov	al,"-"
	Stosb
	Movsw
	Stosb
	Movsw
	;
	PRINTTEXT	TempStr
	Pop dword	[DebugYPos]
	Pop dword	[DebugXPos]
.NoUpdate:
	%ENDIF
	Ret



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; RTCInit() - Initialize the RTC. Should only be used at a boot-up since
; this routine also unmasks the RTC IRQ. RTCReInitialize() should be called
; from within the handler.
;
RTCInit	Mov	eax,IRQ_CMOSCLK
	Call	UnMaskIRQ
	Call	RTCWait
	Mov	al,RTC_StatusA
	Out	RTC_IndexPort,al
	Mov	al,RTC_Freq1024
	Out	RTC_DataPort,al
	Call	RTCWait
	Mov	al,RTC_StatusB
	Out	RTC_IndexPort,al
	Mov	al,RTCBF_PERIODIC		; Periodic Interrupt Enable
	Out	RTC_DataPort,al
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
RTCReInitialize	Call	RTCWait
	Mov	al,RTC_StatusA
	Out	RTC_IndexPort,al
	Mov	al,RTC_Freq1024
	Out	RTC_DataPort,al
	Call	RTCWait
	Mov	al,RTC_StatusB
	Out	RTC_IndexPort,al
	Mov	al,RTCBF_PERIODIC		; Periodic Interrupt Enable
	Out	RTC_DataPort,al
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; RTCWait() - Wait for CMOS RTC to finish
;
RTCWait	PUSHX	eax,ecx
	Mov	ecx,32
	Mov	al,RTC_StatusA
	Out	RTC_IndexPort,al
.Loop	In	al,RTC_DataPort
	Test	al,RTCAF_UIP
	Loopnz	.Loop
	POPX	eax,ecx
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; RTCRead() - Read a byte from the CMOS RTC
;
RTCRead	Call	RTCWait
	Mov	al,ah
	Out	RTC_IndexPort,al
	In	al,RTC_DataPort
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; RTCWrite() - Write a byte to the CMOS RTC
;
RTCWrite	Push	eax
	Call	RTCWait
	XChg	al,ah
	Out	RTC_IndexPort,al
	XChg	al,ah
	Out	RTC_DataPort,al
	Pop	eax
	Ret




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; RTCGetTime() - Get BCD time. EDI == pointer to 3 byte buffer
;
RTCGetTime	Push	eax
	Mov	ah,RTC_Seconds
	Call	RTCRead
	Mov	[edi+RTCT_SECONDS],al
	Mov	ah,RTC_Minutes
	Call	RTCRead
	Mov	[edi+RTCT_MINUTES],al
	Mov	ah,RTC_Hours
	Call	RTCRead
	Mov	[edi+RTCT_HOURS],al
	Pop	eax
	Ret


;;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;; RTCSetTime() - Set BCD time. ESI == pointer to 3 byte buffer
;;
;RTCSetTime	Push	eax
;	Mov	al,[esi+RTCT_SECONDS]
;	Mov	ah,RTC_Seconds
;	Call	RTCWrite
;	Mov	al,[esi+RTCT_MINUTES]
;	Mov	ah,RTC_Minutes
;	Call	RTCWrite
;	Mov	al,[esi+RTCT_HOURS]
;	Mov	ah,RTC_Hours
;	Call	RTCWrite
;	Pop	eax
;	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; RTCGetDate() - Get BCD date. EDI == pointer to 4 byte buffer.
;
RTCGetDate	Push	eax
	Mov	ah,RTC_Day
	Call	RTCRead
	Mov	[edi+RTCD_DAY],al
	Mov	ah,RTC_Month
	Call	RTCRead
	Mov	[edi+RTCD_MONTH],al
	Mov	ah,RTC_Year
	Call	RTCRead
	Mov	[edi+RTCD_YEAR],al
	Mov	ah,RTC_Century
	Call	RTCRead
	Mov	[edi+RTCD_YEAR+1],al
	Pop	eax
	Ret

;;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;; RTCSetDate() - Set BCD date. ESI == pointer to 4 byte buffer.
;;
;RTCSetDate	Push	eax
;	Mov	al,[esi+RTCD_DAY]
;	Mov	ah,RTC_Day
;	Call	RTCWrite
;	Mov	al,[esi+RTCD_MONTH]
;	Mov	ah,RTC_Month
;	Call	RTCWrite
;	Mov	al,[esi+RTCD_YEAR]
;	Mov	ah,RTC_Year
;	Call	RTCWrite
;	Mov	al,[esi+RTCD_YEAR+1]
;	Mov	ah,RTC_Century
;	Call	RTCWrite
;	Pop	eax
;	Ret
;



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
RTCCount	Dd	0

TempTime	Dd	0
TempDate	Dd	0

Tempo	Times 16 Db 0
TempStr	Times 20 Db	0
TempLf	Db	0xa,0

TimerProcN	Db	"timer.library",0



