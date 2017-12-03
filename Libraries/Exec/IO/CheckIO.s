;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     CheckIO.I V1.0.0
;
;     Check and IO request for pending IO.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; CheckIO - Check for pending I/O
;
; Input:
;
;  eax - IO request
;
; Output:
;
;  eax - I/O Request or null for pending I/O
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_CheckIO	Bt dword	[eax+IO_FLAGS],IOB_QUICK
	Jc	.Done
	Cmp byte	[eax+LN_TYPE],NT_REPLYMSG
	Je	.Done
	XOr	eax,eax
.Done	Ret
