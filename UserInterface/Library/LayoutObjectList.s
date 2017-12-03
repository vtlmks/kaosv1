;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     LayoutObjectList.s V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Layout a created objectlist
;
;  Inputs:
;   eax = Root object in hierachy to layout
;
;  Output:
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc UILayoutObjectList
UILO_ObjectList	ResD	1
UILO_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UI_LayoutObjectList	PushFD
	PushAD
	LINK	UILO_SIZE
	Mov	[ebp+UILO_ObjectList],eax
	;









	;
.Done	UNLINK	UILO_SIZE
	PopAD
	PopFD
	Ret


