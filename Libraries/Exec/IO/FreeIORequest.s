;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     FreeIORequest.s V1.0.0
;
;     Free an allocated IO request.
;
; Make sure to have all pending requests aborted before issuing this command, since
; this command will not abort anything.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Input:
;  eax = IORequest(aptr)
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_FreeIORequest	LIBCALL	FreeMem,ExecBase
	Ret
