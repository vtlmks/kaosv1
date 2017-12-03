%ifndef Includes_Drivers_Graphics_Graphics_I
%define Includes_Drivers_Graphics_Graphics_I
;
;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Graphic drivers packet includes V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc GfxDriverEntry
	ResB	LN_SIZE
GDE_Base	ResD	1	; Driverbase
GDE_MsgPort	ResD	1	; Driverport
GDE_SIZE	EndStruc

	LIBINIT
	LIBDEF	GFXP_DrawLine
	LIBDEF	GFXP_RectFill
	LIBDEF	GFXP_BltBitmap
	LIBDEF	GFXP_SetScreenMode
	LIBDEF	GFXP_SetPalette

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%endif
