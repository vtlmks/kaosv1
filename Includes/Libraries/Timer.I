%ifndef Includes_Libraries_Timer_I
%define Includes_Libraries_Timer_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Timer.I V1.0.0
;
;     Timer.library includes and definitions.
;

	Struc TimerEvent
	ResB	MN_SIZE
TE_Port	ResD	1	; UserMessageport
TE_Process	ResD	1	; Userprocess, filled in by Delay() function.
TE_Ticks	ResD	1	; Ticks to wait
TE_Flags	ResD	1	; Flagset, see below
TE_Userdata	ResD	1	; Userdata
TE_SIZE	EndStruc

	BITDEF	TE,DELAY,0	; Delay event, set by Delay() function.

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc DateTime
	ResB	LN_SIZE
DT_Flags	ResD	1	; Flags, see blow
DT_Seconds	ResB	1	; 0 - 59
DT_Minutes	ResB	1	; 0 - 59
DT_Hours	ResB	1	; 0 - 23
DT_Day	ResB	1	; 1 - 7, sunday=1
DT_Weekday	ResB	1	; 1 - 31
DT_Month	ResB	1	; 1 - 12
DT_Year	ResB	1	; 0 - 99
DT_Century	ResB	1	; 0 - 99
DT_SIZE	EndStruc


;
; DateTime flags, filter out which items to get/set.
;
; Example, DTF_READ|DTF_TIME|DTF_DATE will return date and
; time but not weekday into the DateTime struct.
;
	BITDEF	DT,READ,0	; Get date/time, DTB_READ is set by GetSystemTime() automatically.
	BITDEF	DT,WRITE,1	; Set date/time, DTB_WRITE is set by SetSystemTime() automatically.
	BITDEF	DT,TIME,2	; Get/set time
	BITDEF	DT,DATE,3	; Get/set date
	BITDEF	DT,WEEKDAY,4	; Get/set weekday


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc DateTimeService
	ResB	LN_SIZE
DTS_Process	ResD	1	; Requesting process
DTS_DTStruct	ResD	1	; DateTime structure
DTS_SIZE	EndStruc







;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif

