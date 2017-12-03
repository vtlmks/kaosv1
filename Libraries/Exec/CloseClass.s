;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     CloseClass.s V1.0.0
;
;     Closes a class by calling the CLOSE function in the class, if it returns
;     with zero, we call expunge and then frees the memory bound to the class.
;
;     It is safe to call this function with a null.
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Close a previously opened class
;
; Inputs:
;  eax - Classpointer, as returned by OpenClass

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_CloseClass	PushFD
	;
	Test	eax,eax
	Jz	.Done
	Mov	edx,eax
	;
	PushAD
	Push	edx
	Call	[edx-8]	; Lib close
	Pop	edx
	Test	eax,eax
	Jnz	.Done
	Call	[edx-12]	; Lib expunge
	PopAD
	;
.Done	PopFD
	Ret

