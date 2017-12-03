;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     GetMouseCoords.s V1.0.0
;
;     Input-handler GetMouseCoords()
;
;     Returns the mouse coordinates relative to the given object.
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; GetMouseCoords
;
;  Input:
;
;   eax - Object to get coordinates for
;
;  Output:
;
;   eax - Mouse coordinates, upper word contains x.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IHGetMouseCoords	PushFD
	PUSHX	ebx,ecx,edx,esi
	Mov	edx,[edx]
	Mov	ebx,[edx+IH_MouseX]
	Mov	ecx,[edx+IH_MouseY]
	;
	Mov	esi,[eax+CD_Root]
	Sub	ebx,[esi+CD_LeftEdge]	; Subtract window x/y
	Sub	ecx,[esi+CD_TopEdge]
	Sub	ebx,[eax+CD_LeftEdge]	; Subtract object x/y
	Sub	ecx,[eax+CD_TopEdge]
	;
	Mov	ax,bx
	Rol	eax,16
	Mov	ax,cx
	POPX	ebx,ecx,edx,esi
	PopFD
	Ret

