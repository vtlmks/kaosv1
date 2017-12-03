;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     FreeMsg.s V1.0.0
;
;     Free's a previously allocated message.


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;  Inputs:
;
;   eax = Pointer to allocated message, it's safe to call this function with a null.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_FreeMsg	LIBCALL	FreeMem,ExecBase
	Ret
