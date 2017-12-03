%ifndef Includes_Drivers_Drivers_I
%define Includes_Drivers_Drivers_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Drivers.I V1.0.0
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Driver header tags
;

	TAGINIT	0x50000000
	TAGDEF	DT_FLAGS	; Flagset, see below
	TAGDEF	DT_VERSION	; Driver version
	TAGDEF	DT_REVISION	; Driver revision
	TAGDEF	DT_TYPE	; Driver node type, should NT_DRIVER
	TAGDEF	DT_PRIORITY	; Driver priority
	TAGDEF	DT_NAME	; Driver name
	TAGDEF	DT_IDSTRING	; Driver ID string (with version and date)
	TAGDEF	DT_TABLE	; Pointer to drivertable


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Driver packet structure
;

	Struc DriverPacket
	ResB	MN_SIZE
DR_COMMAND	ResD	1	; Driver command
DR_DATA	ResD	1	; Driver data (command specific)
DR_SIZE	EndStruc



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
