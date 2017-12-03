%ifndef Includes_Libraries_Font_I
%define Includes_Libraries_Font_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Font.I V1.0.0
;
;     Font.library includes and definitions.
;


;
; Font node structure, open fonts are added to SysBase SB_FontList.
;


	Struc FontStruct
	ResB	LN_SIZE	; LN_NAME points to real fontname (if available), LN_TYPE is set to NT_FONT.
FS_FontData	ResD	1	; Font data pointer
FS_FontName	ResD	1	; Font dos name
FS_FontFH	ResD	1	; Font filehandler
FS_FontType	ResD	1	; Fonttype, see definitions below
FS_CharBuffer	ResD	1	; Font char buffer
FS_Height	ResD	1	; Font Height(Y) size
FS_SIZE	EndStruc


;
; Supported font types
;

FONTTYPE_AMIGA	Equ	0	; Amiga bitmap font
FONTTYPE_TTF	Equ	1	; TrueType-1 font

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; RenderFont() tags
;

	TAGINIT	0x12000000
	TAGDEF	RTF_FONT	; Point to font returned by OpenFont, mandatory
	TAGDEF	RTF_WINDOW	; Window to render in, mandatory
	TAGDEF	RTF_X	; X position, relative
	TAGDEF	RTF_Y	; Y position, relative
	TAGDEF	RTF_TEXT	; Textstring to render, mandatory
	TAGDEF	RTF_SIZE	; Size of font to render (pixels), mandatory
	;
	TAGDEF	RTF_FITWIDTH	; Maximum width to render within, optional
	;
	TAGDEF	RTF_COLOR	; Color to render font with, default is used if not specified
	TAGDEF	RTF_FLAGS	; Font attributes, see below for definitions


	;
	; RTF_FLAGS
	;

	BITDEF RF,BOLD,0
	BITDEF RF,ITALICS,1
	BITDEF RF,UNDERLINE,2
	BITDEF RF,STRIKETHROUGH,3



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
