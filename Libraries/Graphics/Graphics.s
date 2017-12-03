;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Graphics.s V1.0.0
;
;     Graphics.library V1.0.0
;


	%Include	"Libraries\Graphics\BltBitmap.s"
	%Include	"Libraries\Graphics\DrawBevel.s"
	%Include	"Libraries\Graphics\DrawLine.s"
	%Include	"Libraries\Graphics\ObtainPen.s"
	%Include	"Libraries\Graphics\PolyDraw.s"
	%Include	"Libraries\Graphics\RectFill.s"
	%Include	"Libraries\Graphics\PutPixel.s"
	%Include	"Libraries\Graphics\SetPalette.s"

GfxStart	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

GfxVersion	Equ	1
GfxRevision	Equ	1

GfxLibTag	Dd	LT_FLAGS,0
	Dd	LT_VERSION,GfxVersion
	Dd	LT_REVISION,GfxRevision
	Dd	LT_TYPE,NT_LIBRARY
	Dd	LT_PRIORITY,0
	Dd	LT_NAME,GfxName
	Dd	LT_IDSTRING,GfxIDString
	Dd	LT_INIT,GfxInitTable
	Dd	TAG_DONE

GfxInitTable	Dd	0	; _SIZE
	Dd	GfxBase
	Dd	GfxInit
	Dd	-1

GfxName	Db	"graphics.library",0
GfxIDString	Db	"graphics.library 1.0 (2001-12-04)",0

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
Gfx_OpenCount	Dd	1

OpenGfx	Mov	eax,GfxBase
	Ret

CloseGfx:
ExpungeGfx	Mov	eax,-1
	Ret

NullGfx	XOr	eax,eax
	Ret

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
GfxInit	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Dd	GFX_SetPalette		; -56
	Dd	GFX_BltBitmap		; -52
	Dd	GFX_DrawBevel		; -48
	Dd	GFX_PutPixel		; -44
	Dd	GFX_RectFill		; -40
	Dd	GFX_PolyDraw		; -36
	Dd	GFX_ObtainPen		; -32
	Dd	GFX_DrawLine		; -28
	;-
	Dd	NullGfx		; -24
	Dd	NullGfx		; -20
	Dd	NullGfx		; -16
	Dd	ExpungeGfx		; -12
	Dd	CloseGfx		; -8
	Dd	OpenGfx		; -4
GfxBase:
