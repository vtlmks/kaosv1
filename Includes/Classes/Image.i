%ifndef Includes_Classes_Image_I
%define Includes_Classes_Image_I

;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Image.I V1.0.0
;
;     Image class includes.
;

	Struc ImageClass
	ResB	CD_SIZE
	;
IM_SIZE	EndStruc


	TAGINIT	0x40000000		; Change this
	TAGDEF	IMT_DUMMY	; Change this


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif

