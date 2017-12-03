;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     MGA_CRTC.I V1.0.0
;
;     MGA CRTC and Aparture Base routines/macros
;     for the Matrox graphiccard driver.
;
;


%Macro	MGACRTCWRITE	2
	Mov	al,%1
	Mov	bl,%2
	Call	CGx00CRTC_Write
%EndMacro

%Macro	MGACRTCEXTWRITE	2
	Mov	al,%1
	Mov	bl,%2
	Call	CGx00CRTC_EXTWrite
%EndMacro

%Macro	MGASEQWRITE	2
	Mov	al,%1
	Mov	bl,%2
	Call	CGx00CRTC_SEQWrite
%EndMacro

%Macro	MGAXWRITE	2
	Mov	al,%1
	Mov	bl,%2
	Call	CGX00CRTC_XWrite
%EndMacro

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
CGx00CRTC_SetMGAMode Mov	al,3		; outp( 0x3DE, 3 );
	Mov	dx,0x3de		; CRTC EXTENSION Index
	Out	dx,al
	;
	Mov	dx,0x3df		; CRTC EXTENSION Data
	In	al,dx		; outp( 0x3DF, inp(0x3DF)|0x80 );
	Or	al,0x80
	Out	dx,al
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Removes the writeprotection on CRTC registers 0 - 7
;

CGx00CRTC_WriteEnable Mov	dx,VGAREG_CRT2INDEX
	Mov	al,0x11
	Out	dx,al		; Remove writeprotection on CRTC0-7 registers..
	;
	Mov	dx,VGAREG_CRT2ACCESS
	In	al,dx
	And	al,0x7f		; Bit 7 = wp bit
	Out	dx,al
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; al = ireg
; bl = ivalue
;
CGx00_GCTLWrite	Mov	dx,VGAREG_GFXINDEX	; outp( 0x3CE, iReg );
	Out	dx,al
	Mov	al,bl
	Mov	dx,VGAREG_GFXACCESS	; outp( 0x3CF, iValue );
	Out	dx,al
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; al = ireg
; bl = ivalue
;
CGx00CRTC_Write	Mov	dx,VGAREG_CRT2INDEX	; outp( 0x3D4, iReg );
	Out	dx,al
	Mov	al,bl
	Mov	dx,VGAREG_CRT2ACCESS	; outp( 0x3D5, iValue );
	Out	dx,al
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; al = ireg
; bl = ivalue
;
CGx00CRTC_EXTWrite Mov	dx,0x3de		; outp( 0x3DE, iReg );
	Out	dx,al
	Mov	al,bl
	Mov	dx,0x3df		; outp( 0x3DF, iValue );
	Out	dx,al
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; al = ireg
; bl = ivalue
;
CGx00CRTC_SEQWrite Mov	dx,VGAREG_SEQINDEX	; outp( 0x3C4, iReg );
	Out	dx,al
	Mov	al,bl
	Mov	dx,VGAREG_SEQACCESS	; outp( 0x3C5, iValue );
	Out	dx,al
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;  Write to MGA Control Aparture Base
;
;  Inputs:
;
;   ax = MGA register
;   bl = value to write

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
CGX00CRTC_XWrite	Push	ecx
	Mov	ecx,[ebp+MGAMemory.MGABASE1]
	Mov	[ecx+MGA_PALWTADD],al
	Mov	ecx,[ebp+MGAMemory.MGABASE1]
	Mov	[ecx+MGA_X_DATAREG],bl
	Pop	ecx
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
CGx00CRTC_WaitVBlank Mov	dx,VGAREG_INPUTST2	; while( (inp(0x3DA)&0x08)==0 )
.L	In	al,dx
	And	al,8		; Wait for CRTC1 vertical retrace..
	Test	al,al
	Jz	.L
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
CGx00CRTC_DisplayUnBlank Mov	dx,VGAREG_SEQINDEX	; outp( 0x3C4, 0x01 );
	Mov	al,VGASEQ_CLOCKING
	Out	dx,al
	;
	Mov	dx,VGAREG_SEQACCESS	; outp( 0x3C5, inp(0x3C5)&~0x20 );
	In	al,dx
	Btc	ax,5		; Enable video, scroff bit
	Out	dx,al
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
CGx00CRTC_DisplayBlank Mov	al,VGASEQ_CLOCKING
	Mov	dx,VGAREG_SEQINDEX	; outp( 0x3C4, 0x01 );
	Out	dx,al
	;
	Mov	dx,VGAREG_SEQACCESS	; outp( 0x3C5, inp(0x3C5)|0x20 );
	In	al,dx
	Or	al,0x20		; Disable video, scroff bit
	Out	dx,al
	Ret
