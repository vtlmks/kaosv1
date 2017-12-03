;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     CreateObject.s V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Create a new object
;
;  Inputs:
;   eax = Class returned by OpenClass
;   ecx = Taglist
;
;  Output:
;   eax = Object or null for failure
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UI_CreateObject	PushFD
	PushAD
	Mov	ebx,CM_CREATE
	Mov	edx,eax
	Call	[edx+LVOClassMethod]
	RETURN	eax
	PopAD
	PopFD
	Ret

