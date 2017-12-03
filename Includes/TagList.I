%ifndef Includes_TagList_I
%define Includes_TagList_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     TagList.I V1.0.0
;
;     TagList definitions.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%MACRO	TAGDEF	1
%1	Equ	TAG_COUNT
%ASSIGN	TAG_COUNT	TAG_COUNT+1
%ENDMACRO

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%MACRO	TAGINIT	1
%DEFINE	TAG_COUNT	%1
%ENDMACRO

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; TagItem
;
; This data type may propagate through the system for more general use.
; In the meantime, it is used as a general mechanism of extensible data
; arrays for parameter specification and property inquiry (coming soon
; to a display controller near you).
;
; In practice, an array (or chain of arrays) of TagItems is used.
;
	Struc TagItem
TI_TAG	ResD	1
TI_DATA	ResD	1
TI_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; System tag values
;
TAG_DONE	Equ	0	; Terminates array of TagItems, ti_Data not used.
TAG_END	Equ	0	;
TAG_IGNORE	Equ	1	; Ignore this item, not end of array.
TAG_MORE	Equ	2	; ti_Data is a pointer to another array of TagItems
			; note that this tag Terminates the current array.
TAG_SKIP	Equ	3	; Skip this and the next ti_Data items.


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; User tag identification.
;
TAG_KERNEL	Equ	0x20000000	; Kernel Taglists starts from here.
TAG_USER	Equ	0x80000000	; Differentiates user tags from Kernel tags.

%endif
