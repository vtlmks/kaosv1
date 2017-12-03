;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     FindScreen.s V1.0.0
;
;
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; FindScreen - Find an opened screen
;
; Inputs:
;
;  eax - Name of screen or null for default screen
;
; Output:
;
;  eax - Screen or null for failure
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UI_FindScreen	PushFD
	PushAD
	Test	eax,eax
	Jnz	.NoDefault
	Lea	eax,[SysBase+SB_ScreenList]
	SUCC	eax
	Jmp	.Done
	;
.NoDefault	Lea	ebx,[SysBase+SB_ScreenList]
	LIBCALL	FindName,UteBase
	;
.Done	RETURN	eax
	PopAD
	PopFD
	Ret

