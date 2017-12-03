;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Timer.s V1.0.0
;
;     Supportcode for Timer IRQ.
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Unmask the Timer IRQ and triggers the timer counter.
; 1193182 (0x1234DE) Hz clock/0x4a9 ~ 1KHz = OS timer resolution.
;
InitTimer	In	al,0x61
	Or	al,1
	Out	0x61,al

	Mov	al,0x34
	Out	TIMER_CTRL,al
	Mov	al,0x34
	Out	TIMER_COUNT0,al
	Mov	al,0x12	; 0x04
	Out	TIMER_COUNT0,al

	Mov	al,0xb4
	Out	TIMER_CTRL,al
	XOr	al,al
	Out	TIMER_COUNT2,al
	Out	TIMER_COUNT2,al

	Mov	eax,IRQ_TIMER
	Call	UnMaskIRQ
	Ret
