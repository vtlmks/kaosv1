;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;



	Struc AmigaFont ; starts @ offset 110..
	ResB	110
tf_YSize	ResW	1	; 0x73
tf_Style	ResB	1
tf_Flags	ResB	1
tf_XSize	ResW	1
tf_Baseline	ResW	1
tf_BoldSmear	ResW	1
tf_Accessors	ResW	1
tf_LoChar	ResB	1	; 0x7a
tf_HiChar	ResB	1	; 0x7b
tf_CharData	ResD	1
tf_Modulo	ResW	1
tf_CharLoc	ResD	1	; Fontlocation
tf_CharSpace	ResD	1	; Fontspace
tf_CharKern	ResD	1	; Fontkerning
tf_SIZE	EndStruc

	BITDEF	TF,ROMFONT,0	; font is in ROM
	BITDEF	TF,DISKFONT,1	; font is from diskfont.library
	BITDEF	TF,REVPATH,2	; designed path is reversed (e.g. left)
	BITDEF	TF,TALLDOT,3	; designed for hires non-interlaced
	BITDEF	TF,WIDEDOT,4	; designed for lores interlaced
	BITDEF	TF,PROPORTIONAL,5	; character sizes vary from tf_XSize
	BITDEF	TF,DESIGNED,6	; size is "designed", not constructed
	BITDEF	TF,REMOVED,7	; the font has been removed




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
OpenAmigaBmp	Mov	ebx,[edi+FS_FontData]
	SWAPWORD	[ebx+tf_YSize]
	SWAPWORD	[ebx+tf_XSize]
	SWAPWORD	[ebx+tf_Baseline]
	SWAPWORD	[ebx+tf_BoldSmear]
	SWAPWORD	[ebx+tf_Accessors]
	SWAPWORD	[ebx+tf_Modulo]
	SWAPLONG	[ebx+tf_CharData]
	SWAPLONG	[ebx+tf_CharLoc]
	SWAPLONG	[ebx+tf_CharSpace]
	SWAPLONG	[ebx+tf_CharKern]

	Lea	ecx,[ebx+0x20]		; Memoryptr + exe header
	Add	[ebx+tf_CharData],ecx
	Add	[ebx+tf_CharLoc],ecx
	Add	[ebx+tf_CharSpace],ecx
	Add	[ebx+tf_CharKern],ecx	; *** check for nulls here...

	Movzx	ecx,word [ebx+tf_YSize]
	Mov	[edi+FS_Height],ecx

	Movzx	ecx,byte [ebx+tf_HiChar]
	Sub	cl,[ebx+tf_LoChar]

	Mov	esi,ecx
	;--
	Mov	edx,[ebx+tf_CharLoc]
.L	SWAPWORD	[edx]
	SWAPWORD	[edx+2]
	Lea	edx,[edx+4]
	Dec	ecx
	Jnz	.L
	;--
.NoCharLoc:
;	Mov	ecx,esi
;	Mov	edx,[ebx+tf_CharSpace]
;.L1	SWAPWORD	[edx]
;	Lea	edx,[edx+2]
;	Dec	ecx
;	Jnz	.L1
	;--
.NoCharSpace:	;
	; Allocate render buffer for one character
	;
;	Movzx	eax,word [ebx+tf_YSize]
;	XOr	edx,edx
;	Mul	word [ebx+tf_XSize]
;	Shl	eax,2

	Mov	eax,0x2000
	XOr	ebx,ebx
	LIB	AllocMem,[ebp+_SysBase]
	Mov	[edi+FS_CharBuffer],eax
	Ret
