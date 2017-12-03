;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     PathPart.s V1.0.0
;
;     Returns the Path part for a file.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; PathPart() - Copies the path part of a pathstring to the destination
;              buffer. Strips trailing slashes, but colons remains
;              untouched.
;
; Inputs : eax - nullterminated ptr to sourcepath
;          ebx - destination buffer
;
; Output : Destination buffer is filled with the pathpart.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
DOS_PathPart	PushFD
	PUSHX	ebx,esi,edi
	Cld
	Mov	esi,eax
	Mov	edi,ebx
	Push	ebx
	;
.L1	Lodsb
	Stosb
	Test	al,al
	Jnz	.L1
	;
	Pop	esi	; Destination buffer
.L	Lodsb
	Cmp	al,":"
	Jne	.NoDevice
	Mov	ebx,esi
.NoDevice	Cmp	al,"/"
	Jne	.NoPath
	Lea	ebx,[esi-1]	; Strip trailing slashes
.NoPath	Test	al,al
	Jnz	.L
	Mov byte	[ebx],0
	POPX	ebx,esi,edi
	PopFD
	Ret
