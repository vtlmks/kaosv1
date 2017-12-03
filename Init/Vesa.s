;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Vesa.s V1.0.0
;
;     VESA 2/3.x initialization stubs.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SetupVESA	Push	es

	Mov	ax,VESA_VBEInfo
	Lea	di,[InitBase+INIT_CardInfoBuf]
	Int	0x10

	Mov	ax,VESA_ModeInfo
	Mov	cx,0x105		; Screenmode to probe
	Lea	di,[InitBase+INIT_ModeInfoBuf]
	Int	0x10

	Pop	es

	Mov	ax,VESA_SetMode
	Mov	bx,0x105		; Screenmode to switch to
;;	Or	bx,1<<11		; Select CRTC configuration, pointer in ES:DI
	Or	bx,1<<14		; Select linear mode
	Lea	di,[CRTCInfoBlock]
	Int	0x10

	Call	SetGrayScale
	Call	SetPalette
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
CRTCInfoBlock	Dw	1360	;1360	;1072	; Horizontal total in pixels
	Dw	1136	;1024	;832	; Horizontal sync start in pixels
	Dw	1312	;1136	;936	; Horizontal sync end in pixels
	Dw	802	;802	;636	; Vertical total in lines
	Dw	772	;769	;601	; Vertical sync start in lines
	Dw	800	;772	;604	; Vertical sync end in lines
	Db	0	; Flags (Interlaced, Doublescan etc..)
	Dd	94387000	; Pixelclock in hz
	Dw	8500	;7500	; Refresh Hz*0.01 = (PixelClock/(XTot*YTot))
	Times 40 Db	0	; Reserved



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SetGrayScale	Mov	ecx,0xff
.L	Mov	dx,VGAREG_DACWRITE
	Mov	al,cl
	Out	dx,al
	Inc	dx
	Mov	al,cl
	Out	dx,al
	Out	dx,al
	Out	dx,al
	Loop	.L
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SetPalette	Mov	ax,VESA_DACPalette	; Set 8 bits per channel
	Mov	bl,0
	Mov	bh,8
	Int	0x10
	;
	XOr	dx,dx
	Mov	ax,VESA_PaletteData	; Set 8-bit palette, all 256 colors as grayscale
;.L
	Lea	di,[PaletteData]
	Mov	cx,8
	Mov	bl,0
;	PushAD		; push	dx
	Int	0x10
;	PopAD		; Pop	dx
;	Add dword	[PaletteData],0x00010101
;	Add	si,4
;	Inc	dl
;	Test	dl,dl
;	Jnz	.L
	Ret


PaletteData	Db	166,125,105,0	; Desktopbackground
	Db	57 ,0  ,0  ,0	; Darkpen
	Db	255,227,227,0	; Highlightpen
	Db	162,117,117,0	; Windowbackground
	Db	202,178,178,0	; Objectbackground
	Db	190,121,85 ,0	; Titlebarbackground
	Db	223,223,223,0	; Menubackground
	Db	182,138,142,0	; Buttonbackground

	; EOF Mindkiller color table...

	Db	0x00, 0x00, 0x00, 0x00	; Kurt Skauen colors, just to have some colors here...
	Db	0x00, 0x08, 0x08, 0x08
	Db	0x00, 0x10, 0x10, 0x10
	Db	0x00, 0x18, 0x18, 0x18
	Db	0x00, 0x20, 0x20, 0x20
	Db	0x00, 0x28, 0x28, 0x28
	Db	0x00, 0x30, 0x30, 0x30
	Db	0x00, 0x38, 0x38, 0x38
	Db	0x00, 0x40, 0x40, 0x40
	Db	0x00, 0x48, 0x48, 0x48
	Db	0x00, 0x50, 0x50, 0x50
	Db	0x00, 0x58, 0x58, 0x58
	Db	0x00, 0x60, 0x60, 0x60
	Db	0x00, 0x68, 0x68, 0x68
	Db	0x00, 0x70, 0x70, 0x70
	Db	0x00, 0x78, 0x78, 0x78
	Db	0x00, 0x80, 0x80, 0x80
	Db	0x00, 0x88, 0x88, 0x88
	Db	0x00, 0x90, 0x90, 0x90
	Db	0x00, 0x98, 0x98, 0x98
	Db	0x00, 0xa0, 0xa0, 0xa0
	Db	0x00, 0xa8, 0xa8, 0xa8
	Db	0x00, 0xb0, 0xb0, 0xb0
	Db	0x00, 0xb8, 0xb8, 0xb8
	Db	0x00, 0xc0, 0xc0, 0xc0
	Db	0x00, 0xc8, 0xc8, 0xc8
	Db	0x00, 0xd0, 0xd0, 0xd0
	Db	0x00, 0xd9, 0xd9, 0xd9
	Db	0x00, 0xe2, 0xe2, 0xe2
	Db	0x00, 0xeb, 0xeb, 0xeb
	Db	0x00, 0xf5, 0xf5, 0xf5
	Db	0x00, 0xfe, 0xfe, 0xfe
	Db	0x00, 0x00, 0x00, 0xff
	Db	0x00, 0x00, 0x00, 0xe5
	Db	0x00, 0x00, 0x00, 0xcc
	Db	0x00, 0x00, 0x00, 0xb3
	Db	0x00, 0x00, 0x00, 0x9a
	Db	0x00, 0x00, 0x00, 0x81
	Db	0x00, 0x00, 0x00, 0x69
	Db	0x00, 0x00, 0x00, 0x50
	Db	0x00, 0x00, 0x00, 0x37
	Db	0x00, 0x00, 0x00, 0x1e
	Db	0x00, 0xff, 0x00, 0x00
	Db	0x00, 0xe4, 0x00, 0x00
	Db	0x00, 0xcb, 0x00, 0x00
	Db	0x00, 0xb2, 0x00, 0x00
	Db	0x00, 0x99, 0x00, 0x00
	Db	0x00, 0x80, 0x00, 0x00
	Db	0x00, 0x69, 0x00, 0x00
	Db	0x00, 0x50, 0x00, 0x00
	Db	0x00, 0x37, 0x00, 0x00
	Db	0x00, 0x1e, 0x00, 0x00
	Db	0x00, 0x00, 0xff, 0x00
	Db	0x00, 0x00, 0xe4, 0x00
	Db	0x00, 0x00, 0xcb, 0x00
	Db	0x00, 0x00, 0xb2, 0x00
	Db	0x00, 0x00, 0x99, 0x00
	Db	0x00, 0x00, 0x80, 0x00
	Db	0x00, 0x00, 0x69, 0x00
	Db	0x00, 0x00, 0x50, 0x00
	Db	0x00, 0x00, 0x37, 0x00
	Db	0x00, 0x00, 0x1e, 0x00
	Db	0x00, 0x00, 0x98, 0x33
	Db	0x00, 0xff, 0xff, 0xff
	Db	0x00, 0xcb, 0xff, 0xff
	Db	0x00, 0xcb, 0xff, 0xcb
	Db	0x00, 0xcb, 0xff, 0x98
	Db	0x00, 0xcb, 0xff, 0x66
	Db	0x00, 0xcb, 0xff, 0x33
	Db	0x00, 0xcb, 0xff, 0x00
	Db	0x00, 0x98, 0xff, 0xff
	Db	0x00, 0x98, 0xff, 0xcb
	Db	0x00, 0x98, 0xff, 0x98
	Db	0x00, 0x98, 0xff, 0x66
	Db	0x00, 0x98, 0xff, 0x33
	Db	0x00, 0x98, 0xff, 0x00
	Db	0x00, 0x66, 0xff, 0xff
	Db	0x00, 0x66, 0xff, 0xcb
	Db	0x00, 0x66, 0xff, 0x98
	Db	0x00, 0x66, 0xff, 0x66
	Db	0x00, 0x66, 0xff, 0x33
	Db	0x00, 0x66, 0xff, 0x00
	Db	0x00, 0x33, 0xff, 0xff
	Db	0x00, 0x33, 0xff, 0xcb
	Db	0x00, 0x33, 0xff, 0x98
	Db	0x00, 0x33, 0xff, 0x66
	Db	0x00, 0x33, 0xff, 0x33
	Db	0x00, 0x33, 0xff, 0x00
	Db	0x00, 0xff, 0x98, 0xff
	Db	0x00, 0xff, 0x98, 0xcb
	Db	0x00, 0xff, 0x98, 0x98
	Db	0x00, 0xff, 0x98, 0x66
	Db	0x00, 0xff, 0x98, 0x33
	Db	0x00, 0xff, 0x98, 0x00
	Db	0x00, 0x00, 0x66, 0xff
	Db	0x00, 0x00, 0x66, 0xcb
	Db	0x00, 0xcb, 0xcb, 0xff
	Db	0x00, 0xcb, 0xcb, 0xcb
	Db	0x00, 0xcb, 0xcb, 0x98
	Db	0x00, 0xcb, 0xcb, 0x66
	Db	0x00, 0xcb, 0xcb, 0x33
	Db	0x00, 0xcb, 0xcb, 0x00
	Db	0x00, 0x98, 0xcb, 0xff
	Db	0x00, 0x98, 0xcb, 0xcb
	Db	0x00, 0x98, 0xcb, 0x98
	Db	0x00, 0x98, 0xcb, 0x66
	Db	0x00, 0x98, 0xcb, 0x33
	Db	0x00, 0x98, 0xcb, 0x00
	Db	0x00, 0x66, 0xcb, 0xff
	Db	0x00, 0x66, 0xcb, 0xcb
	Db	0x00, 0x66, 0xcb, 0x98
	Db	0x00, 0x66, 0xcb, 0x66
	Db	0x00, 0x66, 0xcb, 0x33
	Db	0x00, 0x66, 0xcb, 0x00
	Db	0x00, 0x33, 0xcb, 0xff
	Db	0x00, 0x33, 0xcb, 0xcb
	Db	0x00, 0x33, 0xcb, 0x98
	Db	0x00, 0x33, 0xcb, 0x66
	Db	0x00, 0x33, 0xcb, 0x33
	Db	0x00, 0x33, 0xcb, 0x00
	Db	0x00, 0xff, 0x66, 0xff
	Db	0x00, 0xff, 0x66, 0xcb
	Db	0x00, 0xff, 0x66, 0x98
	Db	0x00, 0xff, 0x66, 0x66
	Db	0x00, 0xff, 0x66, 0x33
	Db	0x00, 0xff, 0x66, 0x00
	Db	0x00, 0x00, 0x66, 0x98
	Db	0x00, 0x00, 0x66, 0x66
	Db	0x00, 0xcb, 0x98, 0xff
	Db	0x00, 0xcb, 0x98, 0xcb
	Db	0x00, 0xcb, 0x98, 0x98
	Db	0x00, 0xcb, 0x98, 0x66
	Db	0x00, 0xcb, 0x98, 0x33
	Db	0x00, 0xcb, 0x98, 0x00
	Db	0x00, 0x98, 0x98, 0xff
	Db	0x00, 0x98, 0x98, 0xcb
	Db	0x00, 0x98, 0x98, 0x98
	Db	0x00, 0x98, 0x98, 0x66
	Db	0x00, 0x98, 0x98, 0x33
	Db	0x00, 0x98, 0x98, 0x00
	Db	0x00, 0x66, 0x98, 0xff
	Db	0x00, 0x66, 0x98, 0xcb
	Db	0x00, 0x66, 0x98, 0x98
	Db	0x00, 0x66, 0x98, 0x66
	Db	0x00, 0x66, 0x98, 0x33
	Db	0x00, 0x66, 0x98, 0x00
	Db	0x00, 0x33, 0x98, 0xff
	Db	0x00, 0x33, 0x98, 0xcb
	Db	0x00, 0x33, 0x98, 0x98
	Db	0x00, 0x33, 0x98, 0x66
	Db	0x00, 0x33, 0x98, 0x33
	Db	0x00, 0x33, 0x98, 0x00
	Db	0x00, 0xe6, 0x86, 0x00
	Db	0x00, 0xff, 0x33, 0xcb
	Db	0x00, 0xff, 0x33, 0x98
	Db	0x00, 0xff, 0x33, 0x66
	Db	0x00, 0xff, 0x33, 0x33
	Db	0x00, 0xff, 0x33, 0x00
	Db	0x00, 0x00, 0x66, 0x33
	Db	0x00, 0x00, 0x66, 0x00
	Db	0x00, 0xcb, 0x66, 0xff
	Db	0x00, 0xcb, 0x66, 0xcb
	Db	0x00, 0xcb, 0x66, 0x98
	Db	0x00, 0xcb, 0x66, 0x66
	Db	0x00, 0xcb, 0x66, 0x33
	Db	0x00, 0xcb, 0x66, 0x00
	Db	0x00, 0x98, 0x66, 0xff
	Db	0x00, 0x98, 0x66, 0xcb
	Db	0x00, 0x98, 0x66, 0x98
	Db	0x00, 0x98, 0x66, 0x66
	Db	0x00, 0x98, 0x66, 0x33
	Db	0x00, 0x98, 0x66, 0x00
	Db	0x00, 0x66, 0x66, 0xff
	Db	0x00, 0x66, 0x66, 0xcb
	Db	0x00, 0x66, 0x66, 0x98
	Db	0x00, 0x66, 0x66, 0x66
	Db	0x00, 0x66, 0x66, 0x33
	Db	0x00, 0x66, 0x66, 0x00
	Db	0x00, 0x33, 0x66, 0xff
	Db	0x00, 0x33, 0x66, 0xcb
	Db	0x00, 0x33, 0x66, 0x98
	Db	0x00, 0x33, 0x66, 0x66
	Db	0x00, 0x33, 0x66, 0x33
	Db	0x00, 0x33, 0x66, 0x00
	Db	0x00, 0xff, 0x00, 0xff
	Db	0x00, 0xff, 0x00, 0xcb
	Db	0x00, 0xff, 0x00, 0x98
	Db	0x00, 0xff, 0x00, 0x66
	Db	0x00, 0xff, 0x00, 0x33
	Db	0x00, 0xff, 0xaf, 0x13
	Db	0x00, 0x00, 0x33, 0xff
	Db	0x00, 0x00, 0x33, 0xcb
	Db	0x00, 0xcb, 0x33, 0xff
	Db	0x00, 0xcb, 0x33, 0xcb
	Db	0x00, 0xcb, 0x33, 0x98
	Db	0x00, 0xcb, 0x33, 0x66
	Db	0x00, 0xcb, 0x33, 0x33
	Db	0x00, 0xcb, 0x33, 0x00
	Db	0x00, 0x98, 0x33, 0xff
	Db	0x00, 0x98, 0x33, 0xcb
	Db	0x00, 0x98, 0x33, 0x98
	Db	0x00, 0x98, 0x33, 0x66
	Db	0x00, 0x98, 0x33, 0x33
	Db	0x00, 0x98, 0x33, 0x00
	Db	0x00, 0x66, 0x33, 0xff
	Db	0x00, 0x66, 0x33, 0xcb
	Db	0x00, 0x66, 0x33, 0x98
	Db	0x00, 0x66, 0x33, 0x66
	Db	0x00, 0x66, 0x33, 0x33
	Db	0x00, 0x66, 0x33, 0x00
	Db	0x00, 0x33, 0x33, 0xff
	Db	0x00, 0x33, 0x33, 0xcb
	Db	0x00, 0x33, 0x33, 0x98
	Db	0x00, 0x33, 0x33, 0x66
	Db	0x00, 0x33, 0x33, 0x33
	Db	0x00, 0x33, 0x33, 0x00
	Db	0x00, 0xff, 0xcb, 0x66
	Db	0x00, 0xff, 0xcb, 0x98
	Db	0x00, 0xff, 0xcb, 0xcb
	Db	0x00, 0xff, 0xcb, 0xff
	Db	0x00, 0x00, 0x33, 0x98
	Db	0x00, 0x00, 0x33, 0x66
	Db	0x00, 0x00, 0x33, 0x33
	Db	0x00, 0x00, 0x33, 0x00
	Db	0x00, 0xcb, 0x00, 0xff
	Db	0x00, 0xcb, 0x00, 0xcb
	Db	0x00, 0xcb, 0x00, 0x98
	Db	0x00, 0xcb, 0x00, 0x66
	Db	0x00, 0xcb, 0x00, 0x33
	Db	0x00, 0xff, 0xe3, 0x46
	Db	0x00, 0x98, 0x00, 0xff
	Db	0x00, 0x98, 0x00, 0xcb
	Db	0x00, 0x98, 0x00, 0x98
	Db	0x00, 0x98, 0x00, 0x66
	Db	0x00, 0x98, 0x00, 0x33
	Db	0x00, 0x98, 0x00, 0x00
	Db	0x00, 0x66, 0x00, 0xff
	Db	0x00, 0x66, 0x00, 0xcb
	Db	0x00, 0x66, 0x00, 0x98
	Db	0x00, 0x66, 0x00, 0x66
	Db	0x00, 0x66, 0x00, 0x33
	Db	0x00, 0x66, 0x00, 0x00
	Db	0x00, 0x33, 0x00, 0xff
	Db	0x00, 0x33, 0x00, 0xcb
	Db	0x00, 0x33, 0x00, 0x98
	Db	0x00, 0x33, 0x00, 0x66
	Db	0x00, 0x33, 0x00, 0x33
	Db	0x00, 0x33, 0x00, 0x00
	Db	0x00, 0xff, 0xcb, 0x33
	Db	0x00, 0xff, 0xcb, 0x00
	Db	0x00, 0xff, 0xff, 0x00
	Db	0x00, 0xff, 0xff, 0x33
	Db	0x00, 0xff, 0xff, 0x66
	Db	0x00, 0xff, 0xff, 0x98
	Db	0x00, 0xff, 0xff, 0xcb
	Db	0x00, 0xff, 0xff, 0xff