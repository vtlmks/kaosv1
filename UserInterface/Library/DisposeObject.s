;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     DisposeObject.s V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Dispose a created object
;
;  Inputs:
;   eax = Object
;   ecx = Taglist or null
;
;  Output:
;   eax =
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UI_DisposeObject	PushFD
	PushAD
	Mov	ebx,CM_DISPOSE
	Mov	edx,[eax+CD_ClassBase]
	Call	[edx+LVOClassMethod]
	RETURN	eax
	PopAD
	PopFD
	Ret
