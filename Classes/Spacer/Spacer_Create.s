;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Spacer_Create.s V1.0.0
;
;     Spacer.class V1.0.0
;
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassCreate	Mov	eax,SC_SIZE
	XOr	ebx,ebx
	LIB	AllocMem,[ebp+_SysBase]
	Push	eax
	INITLIST	[eax+LN_SIZE]
	Pop	eax

	; should read the flags here... if the spacer is opened with the "Vertical" flag, it should have a width of 0
	; if it was opened with the "Horizontal" Flag it should have a height of 0 if none of those flags are set, it
	; will have a very high max width/height and 0 as min width/height.
	;
	; When the Vertical/Horizontal flag is set we should also ask for the width/height of the spacer, and if they
	; put zero in that tag, we should have -1 as width/height

	Push dword	[ebp+_ClassID]
	Pop dword	[eax+CD_ClassID]

	Mov dword	[eax+CD_MinWidth],0x1
	Mov dword	[eax+CD_MaxWidth],0xffff
	Mov dword	[eax+CD_MinHeight],0x1
	Mov dword	[eax+CD_MaxHeight],0xffff
	Ret
