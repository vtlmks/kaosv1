%ifndef Includes_Libraries_I
%define Includes_Libraries_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Libraries.I V1.0.0
;
;     Definitions and macros for library creation.
;

%ifndef Includes_TagList_I
%include "Includes\TagList.I"
%endif



LIB_VECTORSIZE	Equ	4	; Default library vectorsize

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	LIBDEF	1
%1	Equ	LIB_COUNT
%Assign	LIB_COUNT	LIB_COUNT-LIB_VECTORSIZE
%EndMacro

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	LIBINIT	0
%Define	LIB_COUNT	-28
%EndMacro

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	LIBCALL	2	; Only to be used within the kernel
	Call	[%2+LVO%1]
%EndMacro

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	LIB	1-2	; For external programs
	%IF	%0 = 2
	Mov	edx,%2
	%ENDIF
	Call	[edx+LVO%1]
%EndMacro



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc DeviceEntry
DEV_HEAD	ResB	LN_SIZE	; Listnode
DEV_LIBTABLE	ResD	1	; Pointer to device table
DEV_LIBSEGLIST	ResD	1	; Pointer to device seglist
DEV_SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc LibEntry
	ResB	LN_SIZE
LE_LIBVERSION	ResD	1	; Library version
LE_LIBTABLE	ResD	1	; Library inittable
LE_LIBSEGLIST	ResD	1	; Library seglist
LE_SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Library and device tag definitions.
;

	TAGINIT	0x10000000
	TAGDEF	LT_FLAGS
	TAGDEF	LT_VERSION
	TAGDEF	LT_REVISION
	TAGDEF	LT_TYPE
	TAGDEF	LT_PRIORITY
	TAGDEF	LT_NAME
	TAGDEF	LT_IDSTRING
	TAGDEF	LT_INIT

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%endif
