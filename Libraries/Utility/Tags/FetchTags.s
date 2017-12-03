;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     FetchTags.s V1.0.0
;
;
;  Extracts tags according to specified parselist from a taglist, and fills in
;  the destination. Checks for nulls can be specified per tag.
;  The trade-off for using this function instead of GetTagData() manually
;  is somewhere around 4-5 tags.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Inputs:
;
;  eax - Parselist, 3 columns wide array where first array is TAGITEM, second is offset
;        into destination (ebx), and third should be set to TRUE if this function
;        should fail on tags that are not found or return null. The list is terminated
;        by setting the last TAGITEM in the list to null. See example below.
;
;  ebx - Destination buffer. Tags are saved into this buffer plus the offset specified
;        in the parselist.
;
;  ecx - Taglist to extract tagdatas from.
;
; Output:
;
;  eax - Null for success
;
;
; Example:
;
;		;Tag, Destination, Checkfornull (set to true)
; TagTable	Dd	TAGITEM_0,_TagItem0,TRUE
;	Dd	TAGITEM_1,_TagItem1,FALSE
;	Dd	0


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UTIL_FetchTags	PushFD
	PushAD
	Cld
	Mov	esi,eax		; Parselist
	Mov	edi,ebx		; Destination
	Mov	ebp,ecx
	;
.L	Lodsd
	Test	eax,eax
	Jz	.Done
	Mov	ebx,ebp
	LIBCALL	GetTagData,UteBase
	Mov	ebx,eax
	Lodsd
	Mov	[edi+eax],ebx
	Lodsd
	Test	eax,eax
	Jz	.L
	Test	ebx,ebx
	Jnz	.L
	;
.Failure	PopAD
	PopFD
	Mov	eax,-1
	Ret
	;
.Done	PopAD
	PopFD
	XOr	eax,eax
	Ret

