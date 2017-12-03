;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     PolyDraw.s V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Input:
;  eax - Window
;  ebx - Pointer to Point list
;  ecx - Pointer to connection list
;
; Output:
;  whatever you put in the registers.
;

	Struc Polydraw
PD_PointList	ResD	1
PD_ConnectList	ResD	1
PD_Taglist	ResD	11
PD_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
GFX_PolyDraw	PushAD
	PushFD
	LINK	PD_SIZE

	Call	PDInitTaglist



	UNLINK	PD_SIZE
	PopFD
	PopAD
	Ret

PDInitTaglist	Lea	eax,[ebp+PD_Taglist]
;	Mov dword	[eax],DLT_WINDOW
;	Lea	eax,[eax+TI_SIZE]
;	Mov dword	[eax],DLT_TOPEDGE
;	Lea	eax,[eax+TI_SIZE]
;	Ret


;	Dd	x,y
;	Dd	x,y
;	Dd	x,y

;Connect	Dd	0,1,color
;	Dd	1,2,-1
;	Dd	2,3,color
;	Dd	-1

