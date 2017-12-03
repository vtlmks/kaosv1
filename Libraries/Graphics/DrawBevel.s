;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     DrawBevel.s V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; ecx - Taglist
;


	Struc BevelPacket
	ResB	DR_SIZE
BP_Window	ResD	1	; Window Object that we are drawing in.
BP_X0	ResD	1	;
BP_X1	ResD	1	;
BP_Y0	ResD	1	;
BP_Y1	ResD	1	;
BP_Color	ResD	1	; Bright Edge color
BP_Color2	ResD	1	; Dark edge color
BP_Flags	ResD	1	; Raised / Recessed etc.
BP_Size	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
GFX_DrawBevel	PushAD
	PushFD
	LINK	BP_Size
	;
	Call	.DBFetchData
	Jc	.Error
	;
	Mov	edx,[ebp+BP_X0]
	Mov	ebx,[ebp+BP_Y0]
	Mov	esi,[ebp+BP_X1]
	Mov	edi,[ebp+BP_Y1]

	Push dword	[ebp+BP_Window]
	Push	edx
	Push	ebx
	Push	esi
	Push	ebx
	Push dword	[ebp+BP_Color]
	LIBCALL	DrawLine,GfxBase

	Push dword	[ebp+BP_Window]
	Push	esi
	Push	ebx
	Push	esi
	Push	edi
	Push dword	[ebp+BP_Color2]
	LIBCALL	DrawLine,GfxBase

	Push dword	[ebp+BP_Window]
	Push	edx
	Push	edi
	Push	esi
	Push	edi
	Push dword	[ebp+BP_Color2]
	LIBCALL	DrawLine,GfxBase

	Push dword	[ebp+BP_Window]
	Push	edx
	Push	edi
	Push	edx
	Push	ebx
	Push dword	[ebp+BP_Color]
	LIBCALL	DrawLine,GfxBase

.Error	UNLINK	BP_Size
	PopFD
	PopAD
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.DBFetchData	Lea	eax,[.BevelTaglist]
	Mov	ebx,ebp
	LIBCALL	FetchTags,UteBase
	Test	eax,eax
	Jnz	.Failure
	;
	Bt dword	[ebp+BP_Flags],DBB_RECESSED
	Jnc	.Raised
	Push dword	[ebp+BP_Color]	; swap colors to make bevel recessed
	Push dword	[ebp+BP_Color2]
	Pop dword	[ebp+BP_Color]
	Pop dword	[ebp+BP_Color2]
.Raised	Clc
	Ret
	;
.Failure	Stc
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.BevelTaglist	Dd	DBT_WINDOW,BP_Window,TRUE
	Dd	DBT_X0,BP_X0,FALSE
	Dd	DBT_X1,BP_X1,FALSE
	Dd	DBT_Y0,BP_Y0,FALSE
	Dd	DBT_Y1,BP_Y1,FALSE
	Dd	DBT_BRIGHTCOLOR,BP_Color,FALSE
	Dd	DBT_DARKCOLOR,BP_Color2,FALSE
	Dd	DBT_FLAGS,BP_Flags,FALSE	; Raised / Recessed etc.
	Dd	TAG_DONE
