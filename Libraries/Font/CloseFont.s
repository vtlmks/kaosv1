;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     CloseFont.s V1.0.0
;
;     Close a font that has been opened by OpenFont().
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; CloseFont
;
; Inputs:
;  eax - Fontpointer as returned by OpenFont(). It's safe to call
;        this function with a null.
;
; Output:
;  None
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
FONT_CloseFont	PushFD
	PushAD
	Test	eax,eax
	Jz short	.Done
	Mov	ebp,edx
	;
	Mov	ebx,eax
	REMOVE		; Remove node from fontlist
	;
	Push	ebx
	Mov	eax,[ebx+FS_FontData]
	Test	eax,eax
	Jz	.NoFontData
	LIB	FreeMem,[ebp+_SysBase]
.NoFontData	Pop	eax
	LIB	FreeMem,[ebp+_SysBase]
.Done	PopAD
	PopFD
	Ret
