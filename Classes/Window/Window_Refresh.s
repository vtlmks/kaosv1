;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Window_Refresh.s V1.0.0
;
;     Window.class V1.0.0
;
;

	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; esi = This Window
; eax = Comparing window
;
ClassRefresh	PushAD
	Mov	esi,eax
	;- find damage regions....
.SummonLoop	NEXTNODE	eax,.NoMore
	Mov	ebx,[esi+CD_TopEdge]
	Mov	ecx,[esi+CD_Height]
	Add	ecx,ebx
	Mov	edx,[eax+CD_TopEdge]
	CMP2	ebx,ecx,edx,.NotInsideY1
	Jmp	.CheckInsideX
.NotInsideY1	Add	edx,[eax+CD_Height]
	CMP2	ebx,ecx,edx,.NotInside
.CheckInsideX	Mov	ebx,[esi+CD_LeftEdge]
	Mov	ecx,[esi+CD_Width]
	Add	ecx,ebx
	Mov	edi,[eax+CD_LeftEdge]
	CMP2	ebx,ecx,edi,.NotInsideX1
	Jmp	.Inside
.NotInsideX1	Add	edi,[eax+CD_Width]
	CMP2	ebx,ecx,edi,.NotInside

	; We have a HIT
	; edi = x
	; edx = y
.Inside	Push	eax
	Lea	eax,[RefreshMatch]
	Int	0xff
	Mov	eax,edx
	Int	0xfe
	Mov	eax,edi
	Int	0xfe
	Pop	eax
	; Exit
.NotInside	Jmp	.SummonLoop

.NoMore	PopAD
	Ret

RefreshMatch	Db	"-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -",0xa,0

