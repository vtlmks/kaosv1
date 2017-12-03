;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     RemoveHead.s V1.0.0
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Remove the head node.
;
; Inputs:
;
;  eax = list ptr
;
; Output:
;
;  None
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UTIL_RemoveHead	PushFD
	PUSHX	ebx,ecx
	REMHEAD
	POPX	ebx,ecx
	PopFD
	Ret
