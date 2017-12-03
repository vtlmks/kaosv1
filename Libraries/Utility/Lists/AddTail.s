;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AddTail.s V1.0.0
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Add a node at end of the list
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
UTIL_AddTail	Push	ecx
	ADDTAIL
	Pop	ecx
	Ret
