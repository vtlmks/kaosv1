;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     FreeTaglist.I V1.0.0
;
;     Free a taglist created with CloneTaglist.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; FreeTaglist
;
;Input:
;  eax - pointer to cloned taglist.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UTIL_FreeTaglist	LIBCALL	FreeMem,ExecBase
	Ret
