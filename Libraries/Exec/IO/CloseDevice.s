;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     CloseDevice.s V1.0.0
;
;     Closes a Device by calling the CLOSE function in the device, if it returns
;     with zero, we call expunge and then frees the memory bound to the Device.
;



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; CloseDevice:
;
; Input:
;  eax = IORequest
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_CloseDevice	PushAD
	PushFD
	;
	Mov	ebx,[eax+IO_DEVICE]
	Test	ebx,ebx
	Jz	.NoClose
	Mov	ebx,[ebx+8]
	Call	[ebx-8]		; DeviceClose()
	;
.NoClose	PopFD
	PopAD
	Ret

