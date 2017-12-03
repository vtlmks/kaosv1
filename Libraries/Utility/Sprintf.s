;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Sprintf.s V1.0.0
;
;     Format data into string.
;
;
;     Formatstring:
;
;
;
;     %[flags][width.limit][length]type
;
;     flags  - only one allowed. '-' specifies left justification.
;
;     width  - field width.  If the first character is a '0', the
;              field will be padded with leading 0's.
;
;         .  - must follow the field width, if specified
;
;     limit  - maximum number of characters to output from a string.
;              (only valid for %s).
;
;     length - size of input data defaults to WORD for types d, x,
;              and c, 'l' changes this to long (32-bit).
;
;       type - supported types are:
;		b - BSTR, data is 32-bit BPTR to byte count followed
;		    by a byte string, or NULL terminated byte string.
;		    A NULL BPTR is treated as an empty string.
;		    (Added in V36 exec)
;		d - decimal
;		u - unsigned decimal (Added in V37 exec)
;		x - hexadecimal
;		s - string, a 32-bit pointer to a NULL terminated
;		    byte string.  In V36, a NULL pointer is treated
;		    as an empty string
;		c - character
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Sprintf - Format data into string
;
; Inputs:
;
;  eax - Formatstring
;  ebx - Data
;  ecx - Buffer
;  edx - PutChar procedure or null for default	< ** ... change
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc SPrintf
SP_STRING	ResD	1
SP_DATA	ResD	1
SP_BUFFER	ResD	1
SP_PUTCHAR	ResD	1
	;
SP_POSITION	ResD	1		; Data position
SP_FLAGS	ResD	1
SP_WIDTH	ResD	1		; Width field
SP_LIMIT	ResD	1		; Limit field
SP_TEMPBUFFER	ResB	32
SP_SIZE	EndStruc

	BITDEF	SP,LEFTJUSTIFY,0		; Justify left
	BITDEF	SP,CENTER,1		; Justify center
	BITDEF	SP,LONGVALUE,2		; Treat value as long
	BITDEF	SP,SIGNEDVALUE,3		; Treat value as signed
	BITDEF	SP,WIDTHFIELD,4		; Use width/limit fields

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UTIL_Sprintf	PushFD
	PUSHX	ebx,ecx,edx,esi,edi,ebp
	PUSHX	eax,ebx,edx
	Mov	eax,SP_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	edx,eax
	POPX	eax,ebx,ebp
	Mov	[edx+SP_STRING],eax
	Mov	[edx+SP_DATA],ebx
	Mov	[edx+SP_BUFFER],ecx
	Mov	[edx+SP_PUTCHAR],ebp
	;--
	Cld
	Mov	esi,eax
	Mov	edi,ecx
.L	Lodsb
	Test	al,al
	Jz	.Done
	Cmp	al,"%"
	Jne	.NoParse
	Call	SP_Parse
	Inc dword	[edx+SP_POSITION]
	Mov dword	[edx+SP_FLAGS],0
	Jmp	.L
.NoParse	Call	SP_PutChar
	Jmp	.L
	;--
.Done	Mov	eax,edx
	LIBCALL	FreeMem,ExecBase
	POPX	ebx,ecx,edx,esi,edi,ebp
	PopFD
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SP_PutChar	Cmp dword	[edx+SP_PUTCHAR],0
	Je	.Default
	Push	ecx
	Push	edx
	Mov	ecx,[edx+SP_BUFFER]
	Mov	edx,[edx+SP_PUTCHAR]
	Call	edx		; User procedures may only update ECX
	Pop	edx		; The byte to process will remain in AL
	Mov	[edx+SP_STRING],ecx
	Pop	ecx
	Ret
	;
.Default	Stosb
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SP_Parse	Lodsb
	Cmp	al,"-"
	Jne	.NoJustification
	Bts dword	[edx+SP_FLAGS],SPB_LEFTJUSTIFY
	Lodsb
	;
.NoJustification	Cmp	al,"1"
	Jb	.NoWidth
	Cmp	al,"9"
	Ja	.NoWidth

	Call	SP_GetWidth


.NoWidth	Cmp	al,"l"
	Jne	.NoLong
	Bts dword	[edx+SP_FLAGS],SPB_LONGVALUE
	Lodsb
	;

.NoLong	Cmp	al,"d"
	Jne	.NoSignDec
	Bts dword	[edx+SP_FLAGS],SPB_SIGNEDVALUE
	Call	SP_ParseDecimal
.NoSignDec	Cmp	al,"u"
	Je	SP_ParseDecimal
	Cmp	al,"x"
	Je near	SP_ParseHex
	Cmp	al,"s"
	Je near	SP_ParseString
	Cmp	al,"c"
	Je near	SP_ParseChar
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Get Width and Limit fields of the formatstring
;
SP_GetWidth	PUSHX	eax,edx
	Lea	edi,[edx+SP_TEMPBUFFER]
	Stosb
.L	Lodsb			; Parse width field until the dot
	Cmp	al,"."
	Je	.Done
	Stosb
	Jmp	.L
.Done	Mov	al,0
	Stosb
	Lea	eax,[edx+SP_TEMPBUFFER]
	LIBCALL	Ascii2Hex,UteBase
	Mov	[edx+SP_WIDTH],eax
	;
	Lea	edi,[edx+SP_TEMPBUFFER]	; Parse limit field until we find a char that is not 0-9
.L1	Lodsb
	Cmp	al,"0"
	Jb	.NoMore
	Cmp	al,"9"
	Ja	.NoMore
	Stosb
	Jmp	.L1
.NoMore	Mov	al,0
	Stosb
	;
	Lea	eax,[edx+SP_TEMPBUFFER]
	LIBCALL	Ascii2Hex,UteBase
	Mov	[edx+SP_LIMIT],eax
	POPX	eax,edx
	Bts dword	[edx+SP_FLAGS],SPB_WIDTHFIELD
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Parse both unsigned and signed decimals, e.g. hex -> (un)signed decimal
;

SP_ParseDecimal	Mov	ecx,[edx+SP_POSITION]
	Mov	ebx,[edx+SP_DATA]
	Mov	eax,[ebx+ecx*4]
	Bt dword	[edx+SP_FLAGS],SPB_LONGVALUE
	Jc	.LongDecimal
	XOr	eax,eax
	Mov	ax,[ebx+ecx*4]
.LongDecimal	Call	.ConvertDec
	Ret


	; check for case null in dec and hex..

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.ConvertDec	PUSHX	edx,esi
	Mov	ebp,edx
	Mov	edx,eax
	Bt dword	[ebp+SP_FLAGS],SPB_SIGNEDVALUE	; Check if we should use signed values
	Jnc	.Positive

	Bt dword	[ebp+SP_FLAGS],SPB_LONGVALUE
	Jc	.SignedLong
	XOr	ecx,ecx
	Mov	cx,ax
	Sub	cx,0x8000		; Check signed word
	Jc	.Positive
	Neg	dx
	Jmp	.Ok

.SignedLong	Mov	ecx,eax		; Check signed long
	Sub	ecx,0x80000000
	Jc	.Positive
	Neg	edx
	;--
.Ok	Mov	al,"-"		; Apply negative character (dash)
	Push	edx
	Mov	edx,ebp
	Call	SP_PutChar
	Pop	edx
	;--
.Positive	Mov dword	ebx,"0"
	Lea	esi,[SPDecimalTable]
.Loop	Lodsd
	Test	eax,eax
	Jz	.Done
	Mov dword	ecx,"0"-1
.L	Inc	ecx
	Sub	edx,eax
	Jnc	.L
	Lea	edx,[edx+eax]
	Cmp	ebx,ecx
	Je	.Loop
	XOr	ebx,ebx
	Push	eax
	Mov	al,cl
	Push	edx
	Mov	edx,ebp
	Call	SP_PutChar
	Pop	edx
	Pop	eax
	Jmp	.Loop
.Done	Mov dword	ebx,"0"
	Add	dl,bl
	Mov	al,dl
	Push	edx
	Mov	edx,ebp
	Call	SP_PutChar
	Pop	edx
	POPX	edx,esi
	Ret

SPDecimalTable	Dd	1000000000		; Decimal lookup table
	Dd	100000000
	Dd	10000000
	Dd	1000000
	Dd	100000
	Dd	10000
	Dd	1000
	Dd	100
	Dd	10
	Dd	0

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SP_ParseHex	Mov	ecx,[edx+SP_POSITION]
	Mov	ebx,[edx+SP_DATA]
	Mov	eax,[ebx+ecx*4]
	Bt dword	[edx+SP_FLAGS],SPB_LONGVALUE
	Jc	.LongHex
	XOr	eax,eax
	Mov	ax,[ebx+ecx*4]

.LongHex	Mov	ecx,8
.L	Rol	eax,4
	Push	eax
	And	al,0xf
	Cmp	al,0xa
	Sbb	al,0x69
	Das
	Mov	ah,7
	Cmp	al,"0"
	Je	.Skip
	Call	SP_PutChar
.Skip	Pop	eax
	Loop	.L
	Ret




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; 1) Check length of input string
; 2) Check if we shall align it
; 3) Apply limit/width


SP_ParseString	Bt dword	[edx+SP_FLAGS],SPB_WIDTHFIELD
	Jnc	.NoAlign
	Bt dword	[edx+SP_FLAGS],SPB_LEFTJUSTIFY
	Jc	.NoRightJustify
	Mov	eax,[edx+SP_POSITION]
	Mov	ebx,[edx+SP_DATA]
	Mov	eax,[ebx+eax*4]
	LIBCALL	StrLen,UteBase
	Test	eax,eax
	Jz	.NoRightJustify
	Mov	ebx,[edx+SP_LIMIT]
	Sub	eax,ebx
	Jc	.NoRightJustify
	Mov	ecx,eax
	Mov	al," "		; Pad with spaces
	Rep	Stosb		; PutCH!!
	;--
.NoRightJustify	Mov	eax,[edx+SP_POSITION]
	Mov	ebx,[edx+SP_DATA]
	Push	esi
	Mov	esi,[ebx+eax*4]
	Mov	ebx,[edx+SP_LIMIT]
	Mov	ebp,[edx+SP_WIDTH]
.L1	Lodsb
	Test	al,al
	Jz	.NoMore
	Call	SP_PutChar
	Dec	ebx
	Jz	.NoMore
	Dec	ebp
	Jz	.NoMore
	Jmp	.L1
	;--
.NoAlign	Mov	eax,[edx+SP_POSITION]
	Mov	ebx,[edx+SP_DATA]
	Push	esi
	Mov	esi,[ebx+eax*4]
.L	Lodsb
	Test	al,al
	Jz	.NoMore
	Call	SP_PutChar
	Jmp	.L
.NoMore	Pop	esi
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SP_ParseChar	Mov	eax,[edx+SP_POSITION]
	Mov	ebx,[edx+SP_DATA]
	Mov	al,[ebx+eax*4]
	Call	SP_PutChar
	Ret

