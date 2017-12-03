;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     SetPalette.s V1.0.0
;
;     Set 8-bit palette


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; eax - Pointer to palette, array with 256 RGB longwords
; ebx - Window

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
GFX_SetPalette	PUSHX	ebx,ecx,dx
	Mov	ecx,eax
	Mov	edx,[ebx+WC_Screen]
	Mov	edx,[edx+SC_Driver]
	Mov	edx,[edx+GDE_Base]
	Call	[edx+GFXP_SetPalette]
	POPX	ebx,ecx,edx
	Ret
