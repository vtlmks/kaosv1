%ifndef Includes_Classes_Checkbox_I
%define Includes_Classes_Checkbox_I

;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     CheckBox.I V1.0.0
;
;     CheckBox class includes.
;

	Struc ButtonClass
	ResB	CD_SIZE
	;
CB_State	ResD	1	; Checkbox state, see below for definitions
CB_SIZE	EndStruc


	TAGINIT	0x42000000
	TAGDEF	CBT_STATE	; State 0=unchecked, 1=checked, 2...



CBSTATE_UNCHECKED	Equ	0
CBSTATE_CHECKED	Equ	1

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%endif


