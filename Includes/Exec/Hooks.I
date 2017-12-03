%ifndef Includes_Exec_Hooks_I
%define Includes_Exec_Hooks_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Hooks.I V1.0.0
;
;     Callback hooks includes.
;


	Struc HOOK
H_ENTRY	ResD	1	; Entry point
H_SUBENTRY	ResD	1	; Optional entry point
H_DATA	ResD	1	; Owner specific data
H_SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
