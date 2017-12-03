;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     DrawLine.s V1.0.0
;
;     Matrox MGA accelerated drawline
;

%Macro	MGAOUT_DL	2
	Mov	edi,[MGABASE1]
	Mov	[edi+%1],%2
%EndMacro
	Struc MGADrawLineStruc
MGADL_Base	ResD	1
MGADL_Packet	ResD	1
MGADL_Window	ResD	1
MGADL_X0	ResD	1
MGADL_X1	ResD	1
MGADL_Y0	ResD	1
MGADL_Y1	ResD	1
MGADL_Color	ResD	1
MGADL_ScreenWidth	ResD	1
MGADL_SIZE	EndStruc

MGA_DrawLine	LINK	MGADL_SIZE
	Mov	[ebp+MGADL_Packet],ecx
	Call	.MGADLFetchData

	Mov	eax,[MGABASE1]
.Wait	Bt dword	[eax+MGA_STATUS],16	; Check if drawing engine is busy
	Jc	.Wait

	MGAOUT_DL	MGA_DWGCTL,dword MGADWGCTL_OPCODE_AUTOLINE_CLOSE|MGADWGCTL_ATYPE_RPL|MGADWGCTL_SOLID|MGADWGCTL_SHFTZERO|MGADWGCTL_BLTMOD_BFCOL|0xc0000
	Mov	eax,[ebp+MGADL_ScreenWidth]
	MGAOUT_DL	MGA_PITCH,eax
	Mov	eax,[ebp+MGADL_X1]
	Shl	eax,16
	Add	eax,[ebp+MGADL_X0]
	MGAOUT_DL	MGA_CXBNDRY,eax
;	MGAOUT_DL	MGA_CXBNDRY,dword 1024<<16
	;
	Mov	eax,[ebp+MGADL_Y0]
	Mul dword	[ebp+MGADL_ScreenWidth]
;	MGAOUT_DL	MGA_YTOP,eax
	MGAOUT_DL	MGA_YTOP,dword 0x0
	;
	Mov	eax,[ebp+MGADL_Y1]
	Mul dword	[ebp+MGADL_ScreenWidth]
;	MGAOUT_DL	MGA_YBOT,eax
	MGAOUT_DL	MGA_YBOT,dword 1024*768
	;
	Mov	eax,[ebp+MGADL_Y0]
	Shl	eax,16
	Add	eax,[ebp+MGADL_X0]
	MGAOUT_DL	MGA_XYSTRT,eax
	;
	Mov	eax,[ebp+MGADL_Y1]
	Shl	eax,16
	Add	eax,[ebp+MGADL_X1]
	MGAOUT_DL	MGA_XYEND,eax
	;
	Mov	eax,[ebp+MGADL_Color]
	MGAOUT_DL	MGA_FCOL+0x100,eax


	UNLINK	MGADL_SIZE
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.MGADLFetchData	Mov	esi,[ebp+MGADL_Packet]
	Mov	eax,[esi+LP_Window]
	Mov	ebx,[esi+LP_X0]
	Mov	ecx,[esi+LP_Y0]
	Mov	edx,[esi+LP_X1]
	Mov	edi,[esi+LP_Y1]
	Mov	[ebp+MGADL_Window],eax
	Mov	[ebp+MGADL_X0],ebx
	Mov	[ebp+MGADL_Y0],ecx
	Mov	[ebp+MGADL_X1],edx
	Mov	[ebp+MGADL_Y1],edi
	Mov	ebx,[esi+LP_Color]
	Mov	[ebp+MGADL_Color],ebx
	;
	Mov	ebx,[eax+WC_Screen]
	Mov	eax,[ebx+SC_Width]
	Mov	[ebp+MGADL_ScreenWidth],eax
	Ret

