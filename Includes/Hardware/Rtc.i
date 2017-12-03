%ifndef Includes_Hardware_RTC_I
%define Includes_Hardware_RTC_I
;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     RTC.I V1.0.0
;
;     RealTime Clock (RTC) MC146818 includes.
;


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

	Struc RTCTime
RTCT_SECONDS	ResB	1	; Number of seconds
RTCT_MINUTES	ResB	1	; Number of minutes
RTCT_HOURS	ResB	1	; Number of hours
RTCT_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

	Struc RTCDate
RTCD_DAY	ResB	1	; Day number
RTCD_MONTH	ResB	1	; Month number
RTCD_YEAR	ResB	2	; Year number
RTCD_SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

RTC_IndexPort	Equ	0x70	; CMOS RAM index register port, write only
RTC_DataPort	Equ	0x71	; CMOS RAM data port, read/write

RTC_Seconds	Equ	0	; Seconds
RTC_SecAlarm	Equ	1	; Second alarm
RTC_Minutes	Equ	2	; Minutes
RTC_MinAlarm	Equ	3	; Minute alarm
RTC_Hours	Equ	4	; Hours
RTC_HourAlarm	Equ	5	; Hour alarm
RTC_Weekday	Equ	6	; Day of week, 1-7
RTC_Day	Equ	7	; Date of month, 1-31
RTC_Month	Equ	8	; Month, 1-12
RTC_Year	Equ	9	; Year, 0-99
RTC_StatusA	Equ	10	; Status register A
RTC_StatusB	Equ	11	; Status register B
RTC_StatusC	Equ	12	; Status register C
RTC_StatusD	Equ	13	; Status register D
RTC_Century	Equ	50	; BCD value for the century


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; Status A
;
; RTC divisors, all to apply with an oscillator at 32768Hz, the frequency will
; be set as: Frequency=32768 >> (Rate-1), where rate is the value of the low nibble in status
; register A of the RTC. The rate of 1024 Hz gives an approximate frequency of 976.562 micros.
;
; Bit 0 - 3 : Interrupt frequency
; Bit 4 - 6 : Xtal frequency (see below)
; Bit     7 : UIP (Update In Progress), If set, time is invalid
;
	BITDEF	RTCA,UIP,7	; UIP (Update In Progress) flag

RTC_Oscillator	Equ	32	; RTC oscillator frequency = 32768Hz.

RTC_Freq32768	Equ	RTC_Oscillator+1	; 32768 HZ
RTC_Freq16384	Equ	RTC_Oscillator+2	; 16384 Hz
RTC_Freq8192	Equ	RTC_Oscillator+3	; 8192 Hz
RTC_Freq4096	Equ	RTC_Oscillator+4	; 4096 Hz
RTC_Freq2048	Equ	RTC_Oscillator+5	; 2048 Hz
RTC_Freq1024	Equ	RTC_Oscillator+6	; 1024 Hz
RTC_Freq512	Equ	RTC_Oscillator+7	; 512 Hz
RTC_Freq256	Equ	RTC_Oscillator+8	; 256 Hz
RTC_Freq128	Equ	RTC_Oscillator+9	; 128 Hz
RTC_Freq64	Equ	RTC_Oscillator+10	; 64 Hz
RTC_Freq32	Equ	RTC_Oscillator+11	; 32 Hz
RTC_Freq16	Equ	RTC_Oscillator+12	; 16 Hz
RTC_Freq8	Equ	RTC_Oscillator+13	; 8 Hz
RTC_Freq4	Equ	RTC_Oscillator+14	; 4 Hz
RTC_Freq2	Equ	RTC_Oscillator+15	; 2 Hz

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; Status B
;
	BITDEF	RTCB,DAYLIGHT,0	; Daylight savings flag
	BITDEF	RTCB,HOURMODE,1	; 0=12h, 1=24h mode
	BITDEF	RTCB,BCD,2	; 0=BCD, 1=Binary			- Set to 0
	BITDEF	RTCB,SQUAREWAVE,3	; 1=Square wave generator		- Set to 0
	BITDEF	RTCB,TIMEUPDATE,4	; Generate time update interrupts (every second)	- Set to 0
	BITDEF	RTCB,ALARM,5	; Alerm interrupt, int when alarm time reached	- Set to 0
	BITDEF	RTCB,PERIODIC,6	; Generate Periodic Interrupt, see status A	- Set to 0
	BITDEF	RTCB,INHIBITINC,7	; Inhibit time increment (while setting the clock)

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; Status C
;
	BITDEF	RTCC,TCHANGED,4	; 1=Time changed (generated every second)
	BITDEF	RTCC,ALARMTIME,5	; 1=Alarm time reached
	BITDEF	RTCC,PERIODIC,6	; 1=Periodic interrupt
	BITDEF	RTCC,IRQFLAG,7	; IRQ flag set to 1 when any of the Bit 4 - 6 are set.

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; Status D
;
	BITDEF	RTCD,VALID,7	; Valid RAM and time



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%endif
