;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AddHead.s V1.0.0
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Add a node at top of the list
;
; Inputs:
;
;  eax = list ptr
;  ebx = node to insert
;
; Output:
;
;  None
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UTIL_AddHead	Push	ecx
	ADDHEAD
	Pop	ecx
	Ret
