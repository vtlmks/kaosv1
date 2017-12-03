;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AddNodeSorted.s V1.0.0
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Inputs:
;
;  eax = List
;  ebx = New node to insert
;  ecx 0:23  = offset
;      24:31 = flagset, see below
;
; Output:
;
;  None
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -


	Struc AddNodeSortedStruc
ANS_List	ResD	1
ANS_Flags	ResD	1
ANS_SIZE	EndStruc


	BITDEF	ANS,REVERSED,24
	BITDEF	ANS,STRING,25
	BITDEF	ANS,UBYTE,26
	BITDEF	ANS,UWORD,27

	;
	;possible future enhancements
	;
	;BITDEF	ANS,SBYTE,28
	;BITDEF	ANS,SWORD,29
	;BITDEF	ANS,SDWORD,30
	;BITDEF	ANS,STRINGCASE,31


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UTIL_AddNodeSorted PushFD
	PushAD
	LINK	ANS_SIZE

	Mov	[ebp+ANS_List],eax
	Mov	[ebp+ANS_Flags],ecx
	Shr dword	[ebp+ANS_Flags],24
	And	ecx,0xffffff
	Bt dword	[ebp+ANS_Flags],ANSB_STRING
	Jnc	.NoString
	Call	ASF_SortByString
	Jmp	.Done

.NoString	Call	ASF_SortByInteger

.Done	UNLINK	ANS_SIZE
	PopAD
	PopFD
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ASF_SortByString	Mov	edx,[ebx+ecx]
	Bt dword	[ebp+ANS_Flags],ANSB_REVERSED
	Jc	.StringReverse
.L	NEXTNODE	eax,.InsertString
	Mov	ebx,[eax+ecx]
	Mov	eax,edx
	LIBCALL	StriCmp,UteBase
	Cmp	eax,1
	Jne	.L
	Jmp	.InsertString

.StringReverse	NEXTNODE	eax,.InsertString
	Mov	ebx,[eax+ecx]
	Mov	eax,edx
	LIBCALL	StriCmp,UteBase
	Cmp	eax,-1
	Jne	.L
	Jmp	.InsertString

.InsertString	Ret	; insert..



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ASF_SortByInteger	Bt dword	[ebp+ANS_Flags],ANSB_UBYTE
	Jc	ASF_SortByByte
	Bt dword	[ebp+ANS_Flags],ANSB_UWORD
	Jc	ASF_SortByWord
	Jmp	ASF_SortByDword


ASF_SortByByte	Mov	dl,[ebx+ecx]
	Bt dword	[ebp+ANS_Flags],ANSB_REVERSED
	Jc	.IntegerReverse
.L	NEXTNODE	eax,ASF_InsertInteger
	Bt dword	[ebp+ANS_Flags],ANSB_REVERSED
	Jc	.IntegerReverse
	Cmp	[eax+ecx],dl
	Ja	.L
	Jmp	ASF_InsertInteger
.IntegerReverse	Cmp	[eax+ecx],dl
	Jb	.L
	Jmp	ASF_InsertInteger


ASF_SortByWord	Mov	dx,[ebx+ecx]
	Bt dword	[ebp+ANS_Flags],ANSB_REVERSED
	Jc	.IntegerReverse
.L	NEXTNODE	eax,ASF_InsertInteger
	Bt dword	[ebp+ANS_Flags],ANSB_REVERSED
	Jc	.IntegerReverse
	Cmp	[eax+ecx],dx
	Ja	.L
	Jmp	ASF_InsertInteger
.IntegerReverse	Cmp	[eax+ecx],dx
	Jb	.L
	Jmp	ASF_InsertInteger


ASF_SortByDword	Mov	edx,[ebx+ecx]
	Bt dword	[ebp+ANS_Flags],ANSB_REVERSED
	Jc	.IntegerReverse
.L	NEXTNODE	eax,ASF_InsertInteger
	Bt dword	[ebp+ANS_Flags],ANSB_REVERSED
	Jc	.IntegerReverse
	Cmp	[eax+ecx],edx
	Ja	.L
	Jmp	ASF_InsertInteger
.IntegerReverse	Cmp	[eax+ecx],edx
	Jb	.L
	;Jmp	ASF_InsertInteger


ASF_InsertInteger	Ret	; insert..

