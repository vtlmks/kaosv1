;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     OpenWindow.s V1.0.0
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; OpenWindow
;
;  Inputs:
;
;   eax - Window object; root object
;
;  Output:
;
;   eax -
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UI_OpenWindow	PushFD
	PushAD
	Mov	edi,eax
	;
	Cmp dword	[edi+WC_Screen],0		; If no screen is set, use default screen
	Jne	.NoDefault
	XOr	eax,eax
	LIBCALL	FindScreen,UIBase
	Mov	[edi+WC_Screen],eax
	;
.NoDefault	Mov	eax,[edi+WC_Screen]	; Attach window to selected screen
	Lea	eax,[eax+SC_WindowList]
	Mov	ebx,edi
	ADDTAIL
	;

	Mov	eax,edi
	Mov	ebx,CM_GETMETRICS
	XOr	ecx,ecx
	LIBCALL	UserMethod,UIBase
	;
	Mov	eax,edi
	Mov	ebx,CM_LAYOUT
	XOr	ecx,ecx
	LIBCALL	UserMethod,UIBase
	;
	Mov	eax,edi
	Mov	ebx,CM_RENDER
	XOr	ecx,ecx
	LIBCALL	UserMethod,UIBase
	;
	PopAD
	PopFD
	Ret
