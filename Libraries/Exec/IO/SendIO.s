;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     SendIO.s V1.0.0
;
;     Sends a command to a device. The device will return at once and
;     it is up to the user to perform a WaitIO() if they want synchronous
;     requests and a Wait() for the reverse effect.
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; SendIO:
;
; Input:
;  eax = IORequest
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_SendIO	PushAD
	PushFD
	;
	Mov	ebx,[eax+IO_DEVICE]
	Call	[ebx+LVOBeginIO]		; Add new I/O
	;
	PopFD
	PopAD
	Ret
