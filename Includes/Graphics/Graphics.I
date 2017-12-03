%ifndef Includes_Graphics_Graphics_I
%define Includes_Graphics_Graphics_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Graphics.I V1.0.0
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; RectFill() tags
;

	TAGINIT	0x10000000
	TAGDEF	RFT_WINDOW	; Window object
	TAGDEF	RFT_LEFTEDGE	; Rectangle leftedge position
	TAGDEF	RFT_TOPEDGE	; Rectangle topedge position
	TAGDEF	RFT_WIDTH	; Rectangle width
	TAGDEF	RFT_HEIGHT	; Rectangle height
	TAGDEF	RFT_COLOR	; Color, 32 bit

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; DrawBevel() tags
;

	TAGINIT	0x10000000
	TAGDEF	DBT_WINDOW	; Window object
	TAGDEF	DBT_X0	; Relative x0 position
	TAGDEF	DBT_X1	; Relative x1 position
	TAGDEF	DBT_Y0	; Relative y0 position
	TAGDEF	DBT_Y1	; Relative y1 position
	TAGDEF	DBT_BRIGHTCOLOR	; Color, 32 bit
	TAGDEF	DBT_DARKCOLOR	; Color, 32 bit
	TAGDEF	DBT_FLAGS	; Flags

	BITDEF	DB,RECESSED,0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; DrawLine() tags
;

	TAGINIT	0x10000000
	TAGDEF	DLT_WINDOW	; Window object
	TAGDEF	DLT_X0	; Relative x0 position
	TAGDEF	DLT_X1	; Relative x1 position
	TAGDEF	DLT_Y0	; Relative y0 position
	TAGDEF	DLT_Y1	; Relative y1 position
	TAGDEF	DLT_COLOR	; Color, 32 bit

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; PutPixel() tags

	TAGINIT	0x10000000
	TAGDEF	PPT_WINDOW	; Window object
	TAGDEF	PPT_X	; Relative x position
	TAGDEF	PPT_Y	; Relative y position
	TAGDEF	PPT_COLOR	; Color, 32 bit


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%endif
