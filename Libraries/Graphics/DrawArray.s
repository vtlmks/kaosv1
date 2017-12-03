;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     DrawArray.s V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Input:
;
;  ecx = Taglist
;
; Output:
;
;  None
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -


	Struc DrawArrayPacket
	ResB	DR_SIZE
DAP_WINDOW	ResD	1	; Window object
DAP_X	ResD	1	; Start x
DAP_Y	ResD	1	; Start y
DAP_XSIZE	ResD	1	; X modulo
DAP_YSIZE	ResD	1	; Y modulo
DAP_SIZE	EndStruc



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; DrawArray() tags

	TAGINIT	0x10000000
	TAGDEF	DAT_WINDOW
	TAGDEF	DAT_X
	TAGDEF	DAT_Y
	TAGDEF	DAT_XSIZE
	TAGDEF	DAT_YISZE

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
GFX_DrawArray	PushAD
	PushFD
	Mov	esi,ecx

	Mov	eax,DAP_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Test	eax,eax
	Jz	.Failure
	Mov	ebp,eax

	Lea	eax,[.DrawArrayTable]
	Mov	ebx,ebp
	Mov	ecx,esi
	LIBCALL	FetchTags,UteBase
	Test	eax,eax
	Jnz	.Failure

	Mov	eax,ebp
	Lea	ebx,[ebp+DAP_WINDOW]
	Mov	[ebp+DR_DATA],ebx
	Mov dword	[eax+DR_COMMAND],GFXP_DRAWARRAY
	Mov byte	[eax+MN_NODE+LN_TYPE],NT_FREEMSG
	Mov	ebx,[ebp+DAP_WINDOW]
	Mov	ebx,[ebx+WC_Screen]
	Mov	ebx,[ebx+SC_Driver]
	Mov	ebx,[ebx+GDE_Base]
	Call	[ebx+GFX_PACKET]
	PopFD
	PopAD
	Ret

.Failure	PopFD
	PopAD
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.DrawArrayTable	Dd	DAT_WINDOW,DAP_WINDOW,TRUE
	Dd	DAT_X,DAP_X,FALSE
	Dd	DAT_Y,DAP_Y,FALSE
	Dd	DAT_XSIZE,DAP_X,FALSE
	Dd	DAT_YSIZE,DAP_Y,FALSE
	Dd	0



