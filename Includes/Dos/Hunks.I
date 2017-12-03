%ifndef Includes_Dos_Hunks_I
%define Includes_Dos_Hunks_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Hunks.I V1.0.0
;
;     Hunk definitions
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc HunkList
HUNK	ResB	LN_SIZE
HUNK_TYPE	ResD	1
HUNK_LENGTH	ResD	1
HUNK_BUFFER:
HUNK_SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
HUNK_BASE	Equ	8000

HUNK_HEADER	Equ	HUNK_BASE+1
HUNK_CODE	Equ	HUNK_BASE+2
HUNK_DATA	Equ	HUNK_BASE+3
HUNK_BSS	Equ	HUNK_BASE+4
HUNK_RELOC32	Equ	HUNK_BASE+5
HUNK_RELOC16	Equ	HUNK_BASE+6
HUNK_RELOC8	Equ	HUNK_BASE+7
HUNK_SYMBOL	Equ	HUNK_BASE+8
HUNK_DEBUG	Equ	HUNK_BASE+9
HUNK_EXT	Equ	HUNK_BASE+10

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
