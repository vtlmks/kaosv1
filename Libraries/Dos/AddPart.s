;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AddPart.s V1.0.0
;
;     Add a part to a filepath, including trailing "/".
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; AddPart()
;
; Inputs : eax = Nullterminated ptr to dirname (+filename space)
;          ebx = Nullterminated ptr to filename
;
; Output : Dirname is joined with filename
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DOS_AddPart	PushFD
	PUSHX	ebx,esi,edi
	Cld
	Mov	esi,eax
	Push	ebx
.L	Lodsb
	Test	al,al
	Jnz	.L
	Cmp byte	[esi-2],":"
	Je	.Mark
	Cmp byte	[esi-2],"/"
	Je	.Mark
	Mov byte	[esi-1],"/"
	Jmp	.L1
.Mark	Dec	esi
.L1	Mov	edi,esi
	Pop	esi	; Filename buffer
.L2	Lodsb
	Stosb
	Test	al,al
	Jnz	.L2
	POPX	ebx,esi,edi
	PopFD
	Ret
