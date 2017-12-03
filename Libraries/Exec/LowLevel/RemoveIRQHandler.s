;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AddIRQHandler.s V1.0.0
;
;     Add an IRQ handler to a specified IRQ.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Inputs:
;  eax - Pointer to IRQ entry as returned by AddIRQHandler.
;
; Outputs:
;  eax - None
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_RemoveIRQ	LIBCALL	Disable,ExecBase
	Push	eax
	REMOVE
	Pop	eax
	LIBCALL	FreeMem,ExecBase
	LIBCALL	Enable,ExecBase
	Ret
