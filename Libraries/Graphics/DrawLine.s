;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Drawline.s V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; ecx - Taglist
;


	Struc LinePacket
LP_Color	ResD	1
LP_Y1	ResD	1
LP_X1	ResD	1
LP_Y0	ResD	1
LP_X0	ResD	1
LP_Window	ResD	1
LP_SIZE	EndStruc


	Struc ClippedLineStruc
CL_Color	ResD	1
CL_EndY	ResD	1
CL_EndX	ResD	1
CL_StartY	ResD	1
CL_StartX	ResD	1
CL_Window	ResD	1
	;
CL_GDEBase	ResD	1
CL_OrgX1	ResD	1
CL_OrgY1	ResD	1
CL_OrgX2	ResD	1
CL_OrgY2	ResD	1
CL_SIZE	EndStruc



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
GFX_DrawLine	Pop	eax
	Push	ebp
	Lea	ebp,[esp+4]
	PushFD
	PushAD
	;
	Mov	ebx,[ebp+LP_Window]
	Mov	ecx,[ebx+CD_LeftEdge]
	Mov	edx,[ebx+CD_TopEdge]
	Add	[ebp+LP_X0],ecx
	Add	[ebp+LP_X1],ecx
	Add	[ebp+LP_Y0],edx
	Add	[ebp+LP_Y1],edx
	;
	Mov	ecx,ebp
	Mov	edx,[ebx+WC_Screen]
	Mov	edx,[edx+SC_Driver]
	Mov	edx,[edx+GDE_Base]
	Cmp dword	[ebx+WC_ClipRegions],0
	Je	.NoClipping
	Call	GFX_DrawLineClipped
	Jmp	.Done

.NoClipping	Call	[edx+GFXP_DrawLine]
	;
.Done	PopAD
	PopFD
	Pop	ebp
	Lea	esp,[esp+LP_SIZE]
	Push	eax
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
GFX_DrawLineClipped PushAD
	Mov	eax,[ebp+LP_X0]
	Mov	ebx,[ebp+LP_X1]
	Mov	ecx,[ebp+LP_Y0]
	Mov	edx,[ebp+LP_Y1]
	Mov	esi,[ebp+LP_Color]
	Mov	edi,[ebp+LP_Window]
	LINK	CL_SIZE

	Cmp	eax,ebx
	Jb	.NoXChange
	XChg	eax,ebx
.NoXChange	Cmp	ecx,edx
	Jb	.NoYChange
	XChg	ecx,edx
.NoYChange	Mov	[ebp+CL_StartX],eax
	Mov	[ebp+CL_EndX],ebx
	Mov	[ebp+CL_StartY],ecx
	Mov	[ebp+CL_EndY],edx
	Mov	[ebp+CL_OrgX1],eax
	Mov	[ebp+CL_OrgX2],ebx
	Mov	[ebp+CL_OrgY1],ecx
	Mov	[ebp+CL_OrgY2],edx
	Mov	[ebp+CL_Color],esi
	Mov	[ebp+CL_Window],edi
	Mov	eax,[edi+WC_Screen]
	Mov	eax,[eax+SC_Driver]
	Mov	eax,[eax+GDE_Base]
	Mov	[ebp+CL_GDEBase],eax

	Mov	eax,[ebp+CL_OrgX1]
	Cmp	eax,[ebp+CL_OrgX2]
	Jne	.NotVertical
	Call	.Vertical
	Jmp	.Exit

.NotVertical	Mov	eax,[ebp+CL_OrgY1]
	Cmp	eax,[ebp+CL_OrgY2]
	Jne	.NotHorizontal
	Call	.Horizontal

.NotHorizontal:
.Exit	UNLINK	CL_SIZE
	PopAD
	Ret





;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.Horizontal	Mov	eax,[ebp+CL_OrgX1]
.LoopH	Call	FindNextVisibleH
	Jc	.ExitH
	Mov	[ebp+CL_StartX],eax
	Call	FindNextHiddenH
	Mov	eax,ecx

	Cmp	eax,[esi+12]
	Je	.LastX
	Dec	ecx
.LastX	Mov	[ebp+CL_EndX],ecx
	;
	PushAD
	Mov	ecx,ebp
	Mov	edx,[ebp+CL_GDEBase]
	Call	[edx+GFXP_DrawLine]
	PopAD
	;
	Cmp	eax,[ebp+CL_OrgX2]
	Jne	.LoopH
.ExitH	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.Vertical	Mov	eax,[ebp+CL_OrgY1]
.LoopV	Call	FindNextVisibleV
	Jc	.ExitV
	Mov	[ebp+CL_StartY],eax
	Call	FindNextHiddenV
	Mov	eax,ecx

	Cmp	eax,[esi+12]
	Je	.LastY
	Dec	ecx
.LastY	Mov	[ebp+CL_EndY],ecx

	;
	PushAD
	Mov	ecx,ebp
	Mov	edx,[ebp+CL_GDEBase]
	Call	[edx+GFXP_DrawLine]
	PopAD
	;
	Cmp	eax,[ebp+CL_OrgY2]
	Jne	.LoopV
.ExitV	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; - Arnes kåååd
;
FindNextVisibleH	Clc
	Mov	ebx,[ebp+CL_OrgY1]
.Redo	Mov	edi,[ebp+CL_Window]
	Mov	edi,[edi+WC_ClipRegions]
.Loop	CMP2	[edi+4],[edi+12],ebx,.NotInside
	CMP2	[edi],[edi+8],eax,.NotInside
	Mov	eax,[edi+8]
	Inc	eax
	Cmp	eax,[ebp+CL_OrgX2]
	Jbe	.Redo
	Stc
	Ret

.NotInside	Lea	edi,[edi+16]
	Cmp dword	[edi],0
	Jne	.Loop
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
FindNextHiddenH	Mov	ebx,[ebp+CL_OrgY1]
	Mov	ecx,[ebp+CL_OrgX2]
.Redo	Mov	edi,[ebp+CL_Window]
	Mov	edi,[edi+WC_ClipRegions]
.Loop	CMP2	[edi+4],[edi+12],ebx,.NotInside
	CMP2	eax,ecx,[edi],.NotInside
	Mov	ecx,[edi]
.NotInside	Lea	edi,[edi+16]
	Cmp dword	[edi],0
	Jne	.Loop
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
FindNextVisibleV	Clc
	Mov	ebx,[ebp+CL_OrgX1]
.Redo	Mov	edi,[ebp+CL_Window]
	Mov	edi,[edi+WC_ClipRegions]
.Loop	CMP2	[edi],[edi+8],ebx,.NotInside
	CMP2	[edi+4],[edi+12],eax,.NotInside
	Mov	eax,[edi+12]
	Inc	eax
	Cmp	eax,[ebp+CL_OrgY2]
	Jbe	.Redo
	Stc
	Ret

.NotInside	Lea	edi,[edi+16]
	Cmp dword	[edi],0
	Jne	.Loop
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
FindNextHiddenV	Mov	ebx,[ebp+CL_OrgX1]
	Mov	ecx,[ebp+CL_OrgY2]
	Mov	edi,[ebp+CL_Window]
	Mov	edi,[edi+WC_ClipRegions]
.Loop	CMP2	[edi],[edi+8],ebx,.NotInside
	CMP2	eax,ecx,[edi+4],.NotInside
	Mov	ecx,[edi+4]
.NotInside	Lea	edi,[edi+16]
	Cmp dword	[edi],0
	Jne	.Loop
	Ret

