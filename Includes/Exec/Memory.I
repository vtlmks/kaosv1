%ifndef LIBRARIES_EXEC_Memory_I
%define LIBRARIES_EXEC_Memory_I

;
; (C) Copyright 1999 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Memory.I V1.0.0
;
;     Memory structures.
;

%ifndef Includes_TypeDef_I
%include	"Includes\TypeDef.I"
%endif

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc MemList
ML_MEMLIST	ResB	LH_SIZE	; List header.
ML_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc MemEntry
ME_LISTNODE	ResB	LN_SIZE	;
	ResW	1	; Pad for long align
ME_LENGTH	ResD	1	; Size of memorychunk.
ME_POINTER	ResD	1	; Pointer to memory.
ME_PID	ResD	1	; Process ID.
ME_FLAGS	ResD	1	; Described below.
ME_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Memory parameters.

	BITDEF	MEM,NOCLEAR,0
	BITDEF	MEM,TOTAL,1
	BITDEF	MEM,REVERSE,2
	BITDEF	MEM,NOKEY,3

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; MemAlloc Tags
;
;	TAGINIT	0x10000000
;	TAGDEF	MMA_SIZE
;	TAGDEF	MMA_FLAGS

%endif
