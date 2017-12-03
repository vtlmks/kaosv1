;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AbortIO.I V1.0.0
;
;     Attempts to abort an I/O request started by SendIO,
;     it's device dependant if this command will actually
;     abort a running request or not. Some devices may be
;     impossible to abort.
;
;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; AbortIO:
;
; Input:
;  eax = IORequest
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_AbortIO	PushAD
	PushFD
	;
	Mov	ebx,[eax+IO_DEVICE]
	Mov	eax,[ebx+8]
	Call	[eax+LVOAbortIO]
	;
	PopFD
	PopAD
	Ret
