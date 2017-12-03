;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     FreeDosEntry.s V1.0.0
;
;     Remove an entry from the doslist.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; FreeDosEntry -- Remove doslist entry
;
; Inputs:
;  eax - DOSEntry returned by AddDosEntry or FindDosEntry
;
; Output:
;  None
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DOS_FreeDosEntry	LIBCALL	FreeMem,ExecBase
	Ret
