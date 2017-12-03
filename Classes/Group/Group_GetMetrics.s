;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Group_GetMetrics.s V1.0.0
;
;     Group.class V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc CGM
CGM_Current	ResD	1	; Current Object, should be a Group.
CGM_SysBase	ResD	1	;
CGM_UteBase	ResD	1	;
CGM_UIBase	ResD	1	;
CGM_HSpace	ResD	1	;
CGM_VSpace	ResD	1	;
CGM_FrameType	ResD	1	;
CGM_Flags	ResD	1	; Internal flags...
CGM_NumObjects	ResD	1	; Number of objects
CGM_Dummy	ResD	1	;
CGM_SIZE	EndStruc

	BITDEF	CGM,WASGROUP,0

	Align	16
ClassGetMetrics	Mov	edi,eax	; Current Object
	Mov	edx,ebp

	LINK	CGM_SIZE
	Mov	eax,[edx+_SysBase]
	Mov	ebx,[edx+_UteBase]
	Mov	ecx,[edx+_UIBase]
	Mov	[ebp+CGM_SysBase],eax
	Mov	[ebp+CGM_UteBase],ebx
	Mov	[ebp+CGM_Current],edi
	Mov	[ebp+CGM_UIBase],ecx

	XOr	eax,eax
	Mov	[edi+CD_MinWidth],eax
	Mov	[edi+CD_MaxWidth],eax
	Mov	[edi+CD_MinHeight],eax
	Mov	[edi+CD_MaxHeight],eax

	Mov	[ebp+CGM_NumObjects],eax
	Mov	[ebp+CGM_Flags],eax

	Call	GetMetricClassTags

	Lea	esi,[edi+CD_ObjectList]

	Bt dword	[edi+GC_Flags],GCB_VERTICAL
	Jnc	.NotVertical
	Call	GetMetricsVert
	Jmp	.Done

.NotVertical	Bt dword	[edi+GC_Flags],GCB_HORIZONTAL
	Jnc	.NotHorizontal
	Call	GetMetricsHz
	Jmp	.Done

.NotHorizontal	Bt dword	[edi+GC_Flags],GCB_COLUMNS
	Jnc	.NotColumns
	Call	GetMetricsColumn
	Jmp	.Done

.NotColumns	Bt dword	[edi+GC_Flags],GCB_ROWS
	Jnc	.NotRows
	Call	GetMetricsRow
	Jmp	.Done
.NotRows:

.Done	UNLINK	CGM_SIZE
	Ret


GetMetricsHz	NEXTNODE	esi,.HzDone
	Cmp dword	[esi+CD_Type],CLASS_GROUP
	Jne	.HNoGroup
	Mov	eax,esi
	Mov	ebx,CM_GETMETRICS
	LIB	DoMethod,[ebp+CGM_UIBase]

.HNoGroup	Mov	eax,[esi+CD_MinWidth]
	Mov	ebx,[esi+CD_MaxWidth]
	Add	[edi+CD_MinWidth],eax
	Add	[edi+CD_MaxWidth],ebx

	Cmp dword	[esi+CD_Type],CLASS_GROUP
	Je	.NoSpacing

	Inc dword	[ebp+CGM_NumObjects]

	Mov	eax,[ebp+CGM_HSpace]
	Add	[edi+CD_MinWidth],eax
	Add	[edi+CD_MaxWidth],eax

.NoSpacing	Mov	eax,[esi+CD_MaxHeight]
	Cmp	[edi+CD_MaxHeight],eax
	Jae	.NoMaxHeight
	Mov	[edi+CD_MaxHeight],eax

.NoMaxHeight	Mov	eax,[esi+CD_MinHeight]
	Cmp	[edi+CD_MinHeight],eax
	Jae	.NoMinHeight
	Mov	[edi+CD_MinHeight],eax
.NoMinHeight	Jmp	GetMetricsHz

.HzDone	Mov	eax,[ebp+CGM_NumObjects]
	Test	eax,eax
	Jz	.Exit
	Mov	eax,[ebp+CGM_HSpace]
	Mov	ebx,[ebp+CGM_VSpace]
	Add	ebx,ebx
	Add	[edi+CD_MaxHeight],ebx
	Add	[edi+CD_MinHeight],ebx
	Add	[edi+CD_MinWidth],eax
	Add	[edi+CD_MaxWidth],eax
.Exit	Ret

GetMetricsVert	NEXTNODE	esi,.VertDone
	Cmp dword	[esi+CD_Type],CLASS_GROUP
	Jne	.VNoGroup
	Mov	eax,esi
	Mov	ebx,CM_GETMETRICS
	LIB	DoMethod,[ebp+CGM_UIBase]
	;
.VNoGroup	Mov	ecx,[esi+CD_MinHeight]
	Mov	ebx,[esi+CD_MaxHeight]
	Add	[edi+CD_MinHeight],ecx
	Add	[edi+CD_MaxHeight],ebx

	Cmp dword	[esi+CD_Type],CLASS_GROUP
	Je	.NoSpacing

	Inc dword	[ebp+CGM_NumObjects]
	Mov	eax,[ebp+CGM_VSpace]
	Add	[edi+CD_MinHeight],eax
	Add	[edi+CD_MaxHeight],eax

.NoSpacing	Mov	ecx,[esi+CD_MaxWidth]
	Cmp	[edi+CD_MaxWidth],ecx
	Jae	.NoMaxWidth
	Mov	[edi+CD_MaxWidth],ecx

.NoMaxWidth	Mov	ecx,[esi+CD_MinWidth]
	Cmp	[edi+CD_MinWidth],ecx
	Jae	.NoMinWidth
	Mov	[edi+CD_MinWidth],ecx
.NoMinWidth	Jmp	GetMetricsVert

.VertDone	Mov	eax,[ebp+CGM_NumObjects]
	Test	eax,eax
	Jz	.Exit
	Mov	eax,[ebp+CGM_VSpace]
	Mov	ebx,[ebp+CGM_HSpace]
	Add	ebx,ebx
	Add	[edi+CD_MaxHeight],eax
	Add	[edi+CD_MinHeight],eax
	Add	[edi+CD_MinWidth],ebx
	Add	[edi+CD_MaxWidth],ebx
.Exit	Ret




GetMetricsColumn	NEXTNODE	esi,.ColumnDone
	Cmp dword	[esi+CD_Type],CLASS_GROUP
	Jne	.CNoGroup
	Mov	eax,esi
	Mov	ebx,CM_GETMETRICS
	LIB	DoMethod,[ebp+CGM_UIBase]
	;
.CNoGroup:
	; Check number of columns....

	Jmp	GetMetricsColumn

.ColumnDone:

GetMetricsRow	NEXTNODE	esi,.RowDone
	Cmp dword	[esi+CD_Type],CLASS_GROUP
	Jne	.RNoGroup
	Mov	eax,esi
	Mov	ebx,CM_GETMETRICS
	LIB	DoMethod,[ebp+CGM_UIBase]
	;
.RNoGroup:
	; Check number of rows...

	Jmp	GetMetricsRow

.RowDone	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

GetMetricClassTags PushAD
	Mov	edi,[ebp+CGM_Current]
	Mov	eax,CCD_GROUP
	Mov	ebx,[edi+CD_Root]
	Mov	ebx,[ebx+CD_Config]
	LIB	GetTagData,[ebp+CGM_UteBase]
	Test	eax,eax
	Jz	.Exit
	Mov	ebx,eax
	;-
	Mov	eax,GCTP_HORIZONTALSPACING
	LIB	GetTagData
	Mov	[ebp+CGM_HSpace],eax
	Mov	eax,GCTP_VERTICALSPACING
	LIB	GetTagData
	Mov	[ebp+CGM_VSpace],eax
	Mov	eax,GCTP_FRAMETYPE
	LIB	GetTagData
	Mov	[ebp+CGM_FrameType],eax
	PopAD
	Ret
	;-
.Exit	XOr	eax,eax
	Mov	[ebp+CGM_HSpace],eax
	Mov	[ebp+CGM_VSpace],eax
	Mov	[ebp+CGM_FrameType],eax
	PopAD
	Ret

