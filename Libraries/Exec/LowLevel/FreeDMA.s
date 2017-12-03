;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     FreeDMA.s V1.0.0
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; FreeDMA -- Free previously allocated DMA channel
;
;  Inputs:
;
;  eax = Allocated channel as returned by AllocDMA().
;
;  Output:
;
;  None
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_FreeDMA	Mov dword	[eax+DMA_Status],0
	Mov dword	[eax+DMA_Owner],0
	Ret
