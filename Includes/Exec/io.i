%ifndef Includes_Exec_IO_I
%define Includes_Exec_IO_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     IO.I V1.0.0
;
;     Exec I/O includes.
;

%ifndef Includes_TagList_I
%Include "Includes\TagList.I"
%endif


	LIBINIT
	LIBDEF	LVOBeginIO
	LIBDEF	LVORemoveIO



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; OpenDevice tags
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	TAGINIT	0x10000000
	TAGDEF	OD_NAME	; Device name
	TAGDEF	OD_UNIT	; Unit
	TAGDEF	OD_FLAGS	; Flags
	TAGDEF	OD_IOREQUEST	; I/O request

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
