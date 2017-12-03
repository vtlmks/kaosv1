

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

V86Test	Mov	al,0x10	; Int#
	XOr	ebx,ebx	; Parameters
	Int	0x86
	Ret

