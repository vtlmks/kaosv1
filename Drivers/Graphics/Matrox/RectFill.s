;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     RectFill.s V1.0.0
;
;     Matrox MGA accelerated rectfill
;


%Macro	MGAOUT_RF	2
	Mov	edi,[MGABASE1]
	Mov	[edi+%1],%2
%EndMacro

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
MGA_RectFill	Mov	eax,[MGABASE1]
.Wait	Bt dword	[eax+MGA_STATUS],16	; Check if drawing engine is busy
	Jc	.Wait

	MGAOUT_RF	MGA_DWGCTL,dword MGADWGCTL_OPCODE_TRAP|MGADWGCTL_ATYPE_RPL|MGADWGCTL_SOLID|MGADWGCTL_ARZERO|MGADWGCTL_SGNZERO|MGADWGCTL_SHFTZERO|MGADWGCTL_BLTMOD_BMONOLEF|MGADWGCTL_TRANSC|0xc0000
	MGAOUT_RF	MGA_MACCESS,dword 0x0	; CMAP8
	MGAOUT_RF	MGA_YDSTORG,dword 0x0	; number of pixels from top of mem to frame buffer
	MGAOUT_RF	MGA_CXBNDRY,dword 0x3ff<<16	; width-1<<16
	MGAOUT_RF	MGA_YTOP,dword 0x0
	MGAOUT_RF	MGA_YBOT,dword 0x301*0x400+0x0	; Height+1*Pitch+yTop
	MGAOUT_RF	MGA_PLNWT,dword ~0x0

	Mov	eax,[ebp+RFP_Window]
	Mov	eax,[eax+WC_Screen]
	Mov	eax,[eax+SC_Width]
	MGAOUT_RF	MGA_PITCH,eax		; Bytes per horizontal line

	Mov	eax,[ebp+RFP_TopEdge]
	Shl	eax,16
	Or	eax,[ebp+RFP_Height]
	sub	eax,[ebp+RFP_TopEdge]
	MGAOUT_RF	MGA_YDSTLEN,eax		; (YStart<<16 | YHeight)

	Mov	eax,[ebp+RFP_Width]
	Mov	ebx,[ebp+RFP_LeftEdge]
	Inc	eax
	Shl	eax,16
	Or	eax,ebx
	MGAOUT_RF	MGA_FXBNDRY,eax		; (StartX | (EndX+1<<16))

	Mov	eax,[ebp+RFP_Color]
	MGAOUT_RF	MGA_FCOL+0x100,eax	; color
	Ret
