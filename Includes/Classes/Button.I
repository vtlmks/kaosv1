%ifndef Includes_Classes_Button_I
%define Includes_Classes_Button_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Button.I V1.0.0
;
;     Button class includes.
;

	Struc ButtonClass
	ResB	CD_SIZE
	;
BC_Text	ResD	1
BC_SIZE	EndStruc


	TAGINIT	0x40000000
	TAGDEF	BCT_TEXT	; Pointer to buttontext


	TAGINIT	0x80030000
	TAGDEF	BCTP_FRAME
	TAGDEF	BCTP_BACKGROUND
	TAGDEF	BCTP_BACKGROUNDPRESSED
	TAGDEF	BCTP_FONT
	TAGDEF	BCTP_FONTSIZE


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Class render types
;

RENDER_NORMAL	Equ	0	; Default render
RENDER_PRESSED	Equ	1
RENDER_RELEASED	Equ	2
RENDER_OVER	Equ	3
RENDER_HELP	Equ	4	; Sent if mouse is over an object for a period of time

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif

