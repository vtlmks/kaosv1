;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     VESA.s V1.0.0
;
;     Driver for VESA 2.0/3.0 with Linear Frame Buffer (LFB)
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -


	Lea	eax,[VESADriverTags]
	Ret


VESAVersion	Equ	1
VESARevision	Equ	0

VESADriverTags	Dd	DT_FLAGS,0
	Dd	DT_VERSION,VESAVersion
	Dd	DT_REVISION,VESARevision
	Dd	DT_TYPE,NT_DRIVER
	Dd	DT_PRIORITY,0
	Dd	DT_NAME,VESADriverN
	Dd	DT_IDSTRING,VESADriverIDN
	Dd	DT_TABLE,VESABase

VESADriverN	Db	"vesa.driver",0
VESADriverIDN	Db	"vesa.driver 1.0 (2001-07-30)",0

VESAOpenCount	Dd	0



	Dd	VESA_SetScreenMode	; -44
	Dd	VESA_SetPalette		; -40
	Dd	VESA_BltBitmap		; -36
	Dd	VESA_RectFill		; -32
	Dd	VESA_DrawLine		; -28
	;-
	Dd	0		; -24
	Dd	0		; -20
	Dd	0		; -16
	Dd	VESAExit		; -12
	Dd	VESAClose		; -8
	Dd	VESAOpen		; -4
VESABase:





;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
VESAInit	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
VESAOpen	PushFD
	PUSHX	ebx,ecx,edx,edi

	Mov	eax,GDE_SIZE
	Mov	ebx,MEMF_NOKEY
	LIBCALL	AllocMem,ExecBase
	Mov	edi,eax
	Mov dword	[edi+GDE_Base],VESABase
	Mov	[ScreenStruct+SC_Driver],edi	; Fix this..

	Mov dword	[edi+LN_NAME],VESADriverN	; Make new entry in driverlist
	Mov byte	[edi+LN_TYPE],NT_DRIVER
	Lea	eax,[SysBase+SB_GfxDriverList]
	SPINLOCK	eax
	Push	eax
	Mov	ebx,edi
	ADDTAIL
	Pop	eax
	SPINUNLOCK	eax

	POPX	ebx,ecx,edx,edi
	PopFD
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
VESAExit	Ret	; remove gfxdriver from driverlist

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
VESAClose	Ret	; update opencount

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	%Include	"Drivers\Graphics\VESA\BltBitmap.s"
	%Include	"Drivers\Graphics\VESA\DrawLine.s"
	%Include	"Drivers\Graphics\VESA\RectFill.s"
	%Include	"Drivers\Graphics\VESA\SetPalette.s"
	%Include	"Drivers\Graphics\VESA\SetScreenMode.s"


