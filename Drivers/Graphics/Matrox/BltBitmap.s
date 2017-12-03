;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     BltBitmap.s V1.0.0
;
;     Matrox MGA accelerated BlitBitmap (CopyRectRegion)
;

	Struc BBM
BBM_Base	ResD	1	; MGABASE
BBM_Packet	ResD	1	; Packet
BBM_Window	ResD	1	; Window
BBM_SrcStartAddr	ResD	1	; calculated Source start address
BBM_Sign	ResD	1	; calculated
BBM_nWidth	ResD	1	; calculated
BBM_nHeight	ResD	1	; calculated
BBM_nPitch	ResD	1	; calculated
BBM_SrcWidth	ResD	1	; given
BBM_SrcHeight	ResD	1	; given
BBM_SrcTopEdge	ResD	1	; given
BBM_SrcLeftEdge	ResD	1	; given
BBM_DstTopEdge	ResD	1	; given
BBM_DstLeftEdge	ResD	1	; given
BBM_SIZE	Endstruc

%Macro	MGAOUT_BB	2
	Mov	edi,[ebp+BBM_Base]
	Mov	[edi+%1],%2
%EndMacro



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
MGA_BltBitmap	Mov	esi,[MGABASE1]
	LINK	BBM_SIZE
	Mov	[ebp+BBM_Base],esi
	Mov	[ebp+BBM_Packet],eax

;	Call	.BBM_FetchTags
	Call	.BBM_BlitBitmap

	Mov	eax,[ebp+BBM_Base]
.Wait	Bt dword	[eax+MGA_STATUS],16	; Check if drawing engine is busy
	Jc	.Wait

	UNLINK	BBM_SIZE
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.BBM_FetchTags	Mov	esi,[ebp+BBM_Packet]
	Mov	esi,[esi+DR_DATA]
	Lodsd
	Mov	[ebp+BBM_Window],eax
	Lodsd
	Mov	[ebp+BBM_SrcLeftEdge],eax
	Lodsd
	Mov	[ebp+BBM_SrcTopEdge],eax
	Lodsd
	Mov	[ebp+BBM_SrcWidth],eax
	Lodsd
	Mov	[ebp+BBM_SrcHeight],eax
	Lodsd
	Mov	[ebp+BBM_DstLeftEdge],eax
	Lodsd
	Mov	[ebp+BBM_DstTopEdge],eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.BBM_BlitBitmap	Mov	eax,[ebp+BBM_SrcWidth]
	Inc	eax
	Mov	ebx,[ebp+BBM_SrcHeight]
	Inc	ebx
	Mov	[ebp+BBM_nWidth],eax
	Mov	[ebp+BBM_nHeight],ebx
	Mov dword	[ebp+BBM_nPitch],1024	; change later

	MGAOUT_BB	MGA_DWGCTL,dword MGADWGCTL_OPCODE_BITBLT|MGADWGCTL_ATYPE_RPL|MGADWGCTL_SHFTZERO|MGADWGCTL_BLTMOD_BFCOL|0xc0000
	Mov	eax,[ebp+BBM_nPitch]
	MGAOUT_BB	MGA_PITCH,eax
	MGAOUT_BB	MGA_YDSTORG,dword 0x0	; number of pixels from top of mem to framebuffer (always ZERO)
	MGAOUT_BB	MGA_YTOP,dword 0x0
	MGAOUT_BB	MGA_MACCESS,dword 0x0	; CMAP_8 nothing special, nothing hard.
	MGAOUT_BB	MGA_PLNWT,dword ~0x0	; write mask, should be ~0x0
	MGAOUT_BB	MGA_CXBNDRY,dword 0x3ff0000

	MGAOUT_BB	MGA_SRCORG,dword 40*1024
	MGAOUT_BB	MGA_DSTORG,dword 40*1024
	MGAOUT_BB	MGA_AR0,dword 48*1024+640
	MGAOUT_BB	MGA_AR3,dword 48*1024
	MGAOUT_BB	MGA_AR5,dword 1024
	MGAOUT_BB	MGA_FXRIGHT,dword 640
	MGAOUT_BB	MGA_FXLEFT,dword 0
	MGAOUT_BB	MGA_YDST,dword 40
	MGAOUT_BB	MGA_LEN,dword 26*8
	MGAOUT_BB	MGA_SGN+0x100,dword 0x0	; MGASGN_SCANLEFT
	Ret

	Mov	ebx,[ebp+BBM_SrcLeftEdge]
	Mov	eax,[ebp+BBM_SrcTopEdge]
	Mov	ecx,[ebp+BBM_nPitch]
	Mul	ecx
	Mov	[ebp+BBM_SrcStartAddr],eax

	Mov	eax,[ebp+BBM_SrcTopEdge]
	Sub	eax,[ebp+BBM_DstTopEdge]
	Jb	.SourceBelow
	Mov	ebx,[ebp+BBM_SrcLeftEdge]
	Mov	eax,[ebp+BBM_SrcTopEdge]
	Add	eax,[ebp+BBM_SrcHeight]
	Mov	ecx,[ebp+BBM_nPitch]
	Mul	ecx
	Mov	[ebp+BBM_SrcStartAddr],eax
	Mov	eax,[ebp+BBM_nPitch]
	Neg	eax
	MGAOUT_BB	MGA_AR5,eax

	Mov	eax,[ebp+BBM_DstTopEdge]
	Add	eax,[ebp+BBM_SrcHeight]
	Shl	eax,16
	Or	eax,[ebp+BBM_nHeight]
	MGAOUT_BB	MGA_YDSTLEN,eax

	Or dword	[ebp+BBM_Sign],MGASGN_SDY
	Jmp	.SourceAbove
.SourceBelow	Mov	eax,[ebp+BBM_nPitch]
	MGAOUT_BB	MGA_AR5,eax

	Mov	eax,[ebp+BBM_DstTopEdge]
	Shl	eax,16
	Or	eax,[ebp+BBM_nHeight]
	MGAOUT_BB	MGA_YDSTLEN,eax
.SourceAbove	Mov	eax,[ebp+BBM_SrcHeight]
	Mov	ebx,[ebp+BBM_nPitch]
	Mul	ebx
	MGAOUT_BB	MGA_YBOT,eax

	Mov	eax,[ebp+BBM_DstLeftEdge]
	Add	eax,[ebp+BBM_SrcWidth]
	Shl	eax,16
	Or	eax,[ebp+BBM_DstLeftEdge]
	MGAOUT_BB	MGA_FXBNDRY,eax

	Mov	eax,[ebp+BBM_SrcLeftEdge]
	Sub	eax,[ebp+BBM_DstLeftEdge]
	Jb	.WasLeft

	Mov	eax,[ebp+BBM_SrcStartAddr]
	MGAOUT_BB	MGA_AR0,eax
	Mov	eax,[ebp+BBM_SrcStartAddr]
	Add	eax,[ebp+BBM_SrcWidth]
	MGAOUT_BB	MGA_AR3,eax

	Or dword	[ebp+BBM_Sign],MGASGN_SCANLEFT
	Jmp	.WasRight

.WasLeft	Mov	eax,[ebp+BBM_SrcStartAddr]
	MGAOUT_BB	MGA_AR3,eax
	Mov	eax,[ebp+BBM_SrcStartAddr]
	Add	eax,[ebp+BBM_SrcWidth]
	MGAOUT_BB	MGA_AR0,eax

.WasRight	Mov	eax,[ebp+BBM_Sign]
	MGAOUT_BB	MGA_SGN+0x100,eax
	Ret

