%ifndef Includes_Classes_Group_I
%define Includes_Classes_Group_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Group.I V1.0.0
;
;     Group class includes.
;

	Struc GroupClass
	ResB	CD_SIZE
	;
GC_Flags	ResD	1
GC_Columns	ResD	1
GC_Rows	ResD	1
GC_SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Taglist for Group Creation
;

	TAGINIT	0x41000000
	TAGDEF	GCT_FLAGS	; Flagset, see below
	TAGDEF	GCT_COLUMNS	; Columns
	TAGDEF	GCT_ROWS	; Rows

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Flags for Group Creation
;
	BITDEF	GC,VERTICAL,0
	BITDEF	GC,HORIZONTAL,1
	BITDEF	GC,COLUMNS,2
	BITDEF	GC,ROWS,3


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Taglist for Group Configuration
;
	TAGINIT	0x80020000
	TAGDEF	GCTP_HORIZONTALSPACING
	TAGDEF	GCTP_VERTICALSPACING
	TAGDEF	GCTP_TITLEPOSITION
	TAGDEF	GCTP_TITLEFONT
	TAGDEF	GCTP_TITLEFONTSIZE
	TAGDEF	GCTP_TITLERENDERMODE
	TAGDEF	GCTP_FRAMETYPE
	TAGDEF	GCTP_BACKGROUND

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; GroupClass Frame Types...

GCFT_NONE	Equ	0
GCFT_Group	Equ	1
GCFT_Window	Equ	2


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif

