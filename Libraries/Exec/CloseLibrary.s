;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     CloseLibrary.s V1.0.0
;
;     Closes a library by calling the CLOSE function in the library, if it returns
;     with zero, we call expunge and then frees the memory bound to the library.
;
;     It is safe to call this function with a null.
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Close a previously opened library
;
; Inputs:
;  eax - Librarypointer, as returned by OpenLibrary
;
; Output:
;  None
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_CloseLibrary	PushFD
	;
	Test	eax,eax
	Jz	.Done
	PushAD
	Mov	edx,eax
	Push	edx
	Call	[edx-8]	; Lib close, expunge library if it returns null
	Pop	edx
	Test	eax,eax
	Jnz	.NoExpunge
	;
	Call	[edx-12]	; Lib expunge
	;
.NoExpunge	PopAD
	;
.Done	PopFD
	Ret

