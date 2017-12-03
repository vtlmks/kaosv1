;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     DoMethod.s V1.0.0
;



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; DoMethod -- Invoke a class method
;
;  Inputs:
;
;  eax = Object, safe to be called with null.
;  ebx = Class Method
;  ecx = Taglist (or other data, method dependant)
;
;  Output:
;
;  eax = Method dependant return
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UI_DoMethod	PushFD
	PushAD
	Test	eax,eax
	Jz	.Failure
	PUSHX	ebx,ecx
	;
	Mov	ebx,[eax+CD_ClassID]
	Mov	edi,[UIMemoryBase]
	Lea	esi,[edi+UIH_ClassList]
	XOr	edx,edx
	SPINLOCK	esi
.L	NEXTNODE	esi,.NoMore
	Cmp	[esi+ON_ClassID],ebx
	Jne	.L
	Mov	edx,[esi+ON_Class]
.NoMore	Lea	esi,[edi+UIH_ClassList]
	SPINUNLOCK	esi
	;
	POPX	ebx,ecx
	Test	edx,edx
	Jz	.Failure
	; base in eax,edx
	Call	[edx+LVOClassMethod]
	;
.Failure	RETURN	eax
	PopAD
	PopFD
	Ret

