;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     SetPalette.s V1.0.0
;
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Inputs:
;
;  ecx = Pointer to 256 longword RGB palette
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
VESA_SetPalette	PushFD
	PUSHX	ebx,ecx,edx,esi

	Mov	esi,ecx

	XOr	al,al
	Mov	dx,VGAREG_DACWRITE
	Out	dx,al
	Mov	dx,VGAREG_DACDATA

	Mov	ecx,256
	Cld
.L	Lodsd
	Rol	eax,16
	Out	dx,al
	Rol	eax,8
	Out	dx,al
	Rol	eax,8
	Out	dx,al
	Dec	ecx
	Jnz	.L

	POPX	ebx,ecx,edx,esi
	PopFD
	Ret


