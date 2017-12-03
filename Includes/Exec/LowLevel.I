%ifndef Includes_Exec_LowLevel_I
%define Includes_Exec_LowLevel_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     LowLevel.I V1.0.0
;
;     Exec lowlevel includes.
;

%ifndef Includes_TagList_I
%Include "Includes\TagList.I"
%endif

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; AddProcess Tags
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	TAGINIT	0x10000000
	TAGDEF	AP_PROCESSPOINTER	; Pointer to process to be started.
	TAGDEF	AP_PRIORITY		; Priority for the started process.
	TAGDEF	AP_STACKSIZE		; Stacksize, rounded to nearest kb.
	TAGDEF	AP_FLAGS		; Flags, see below
	TAGDEF	AP_USERDATA		; For User usage.
	TAGDEF	AP_NAME		; The name for the process.
	;
	TAGDEF	AP_RING		; What ring we shuld have fun in.
	TAGDEF	AP_QUANTUM		; What quantum to give to the process.

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
