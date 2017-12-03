;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Group_Layout.s V1.0.0
;
;     Group.class V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; eax has to point to a group class.
;
; The below structure will be nested on the stack, try to keep it as small as possible.
;

	Struc	Layout
CL_Current	ResD	1	; This is the pointer to the current Group.
CL_Width	ResD	1
CL_Height	ResD	1
CL_HSpace	ResD	1	; Horizontal spacing...
CL_VSpace	ResD	1	; Vertical spacing...
CL_FrameType	ResD	1	; Type of framing..
CL_NumObjects	ResD	1	; Number of objects
CL_Flags	ResD	1	; Internal flags for class:layout
CL_Dummy	ResD	1	; Temporary variable
CL_UteBase	ResD	1	; Utility.Library
CL_SysBase	ResD	1	; exec.library
CL_UIBase	ResD	1	; userinterface.library
CL_SIZE	EndStruc

	BITDEF	CL,WASGROUP,0
	BITDEF	CL,WASOBJECT,1
	BITDEF	CL,NOTFIRST,2

	Align	16
ClassLayout	LINK	CL_SIZE
	Mov	[ebp+CL_Current],eax

	Mov	edx,[eax+CD_ClassBase]
	Mov	eax,[edx+_SysBase]
	Mov	ebx,[edx+_UteBase]
	Mov	ecx,[edx+_UIBase]
	Mov	[ebp+CL_SysBase],eax
	Mov	[ebp+CL_UteBase],ebx
	Mov	[ebp+CL_UIBase],ecx

	Call	GetClassTags	; Has to be first..
	Call	GetGroupMetrics	; Calculate metrics for total width and height, read note in routine
	Call	SetMinimum	; Set the minimum width or height
	Call	LayoutGroup	; Divide what is left to the current group.
	Call	SetCoordinates	; Set coordinates for the GUI

	Mov	edi,[ebp+CL_Current]
	Lea	esi,[edi+CD_ObjectList]
.Loop	NEXTNODE	esi,.Done
	Cmp dword	[esi+CD_Type],CLASS_GROUP
	Jne	.Loop
	Mov	eax,esi
	Mov	ebx,CM_LAYOUT
	LIB	DoMethod,[ebp+CL_UIBase]
	Jmp	.Loop

.Done	UNLINK	CL_SIZE
	Ret

	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SetMinimum	Mov	edi,[ebp+CL_Current]
	Lea	esi,[edi+CD_ObjectList]

	Mov dword	[ebp+CL_Flags],0

	Bt dword	[edi+GC_Flags],GCB_COLUMNS
	Jc near	SMColumns
	Bt dword	[edi+GC_Flags],GCB_ROWS
	Jc near	SMRows
	Bt dword	[edi+GC_Flags],GCB_VERTICAL
	Jc	SMVertical

SMHorizontal	NEXTNODE	esi,.Done
	Mov	eax,[esi+CD_MinWidth]
	Mov	[esi+CD_Width],eax
	Sub	[ebp+CL_Width],eax

	Cmp dword	[esi+CD_Type],CLASS_GROUP
	Je	.NoHSpacing
	Mov	eax,[ebp+CL_HSpace]
	Sub	[ebp+CL_Width],eax
	Or dword	[ebp+CL_Flags],CLF_WASOBJECT

.NoHSpacing	Mov	eax,[edi+CD_Height]
	Cmp dword	[esi+CD_Type],CLASS_GROUP
	Je	.NoSpacing
	Mov	ecx,[ebp+CL_VSpace]
	Add	ecx,ecx
	Sub	eax,ecx
.NoSpacing	Cmp	eax,[esi+CD_MaxHeight]
	Jbe	.SetHeight
	Mov	eax,[esi+CD_MaxHeight]	; if this works, we have to check for spacers aswell.
.SetHeight	Mov	[esi+CD_Height],eax
	Jmp	SMHorizontal

.Done	Bt dword	[ebp+CL_Flags],CLB_WASOBJECT
	Jnc	.NoObjects
	Mov	eax,[ebp+CL_HSpace]
	Sub	[ebp+CL_Width],eax
.NoObjects	Mov	eax,[edi+CD_MinHeight]
	Sub	[ebp+CL_Height],eax
	Ret

SMVertical	NEXTNODE	esi,.Done
	Mov	eax,[esi+CD_MinHeight]
	Mov	[esi+CD_Height],eax
	Sub	[ebp+CL_Height],eax

	Cmp dword	[esi+CD_Type],CLASS_GROUP
	Je	.NoVSpacing
	Mov	eax,[ebp+CL_VSpace]
	Sub	[ebp+CL_Height],eax
	Or dword	[ebp+CL_Flags],CLF_WASOBJECT

.NoVSpacing	Mov	eax,[edi+CD_Width]
	Cmp dword	[esi+CD_Type],CLASS_GROUP
	Je	.NoSpacing
	Mov	ecx,[ebp+CL_HSpace]
	Add	ecx,ecx
	Sub	eax,ecx
.NoSpacing	Cmp	eax,[esi+CD_MaxWidth]
	Jbe	.SetWidth
	Mov	eax,[esi+CD_MaxWidth]
.SetWidth	Mov	[esi+CD_Width],eax
	Jmp	SMVertical

.Done	Bt dword	[ebp+CL_Flags],CLB_WASOBJECT
	Jnc	.NoObjects
	Mov	eax,[ebp+CL_VSpace]
	Sub	[ebp+CL_Height],eax
.NoObjects	Mov	eax,[edi+CD_MinWidth]
	Sub	[ebp+CL_Width],eax
	Ret

SMRows	NEXTNODE	esi,.Done
.Done	Jmp	SMRows

SMColumns	NEXTNODE	esi,.Done
	Jmp	SMColumns

.Done	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Layout the current group...
;
; NOTE: When we come to this routine, all classes has their MINIMAL widths and heights
;       so here we are dealing with the DELTA values that is to be added to each
;       class..  We must check so that the total does not exceed the maximum width for
;       the class we are setting sizes on.
;
	Align	16

LayoutGroup	Mov	edi,[ebp+CL_Current]
	;
	Lea	esi,[edi+CD_ObjectList]
	Bt dword	[edi+GC_Flags],GCB_VERTICAL
	Jc near	LGVertical
	Bt dword	[edi+GC_Flags],GCB_HORIZONTAL
	Jc	LGHorizontal
	Ret

LGHorizontal	Mov	eax,[edi+CD_NumObjects]
	Mov	[ebp+CL_NumObjects],eax
	Mov	[ebp+CL_Dummy],esi

.Loop	Mov	eax,[ebp+CL_Width]
	Mov	esi,[ebp+CL_Dummy]
	XOr	edx,edx
	Div dword	[ebp+CL_NumObjects]
	Test	eax,eax
	Jz	.DivideOne
	Mov	ebx,[edi+CD_NumObjects]
	Mov	[ebp+CL_NumObjects],ebx

.Loop2	NEXTNODE	esi,.Done
	Mov	ebx,[esi+CD_MaxWidth]
	Mov	ecx,[esi+CD_Width]
	Cmp	ebx,ecx
	je	.WasMax
	Sub	ebx,[esi+CD_MinWidth]
	Cmp	ebx,eax
	Jbe	.MaxWidth		; 640kb ought to be enough..
	Add	[esi+CD_Width],eax
	Sub	[ebp+CL_Width],eax
	Jmp	.Loop2

.MaxWidth	Add	[esi+CD_Width],ebx
	Sub	[ebp+CL_Width],ebx
.WasMax	Dec dword	[ebp+CL_NumObjects]
	Jmp	.Loop2

.Done	Cmp dword	[ebp+CL_NumObjects],0
	Je	.Exit
	Cmp dword	[ebp+CL_Width],0
	Jne	.Loop
.Exit	Ret

.DivideOne	Cmp dword	[ebp+CL_Width],0
	Je	.Exit
.Divide	NEXTNODE	esi,.Exit
	Mov	eax,[esi+CD_MaxWidth]
	Mov	ebx,[esi+CD_Width]
	Cmp	eax,ebx
	Je	.Divide
	Inc dword	[esi+CD_Width]
	Dec dword	[ebp+CL_Width]
	Jnz	.Divide
	Ret

	;----------
LGVertical	Mov	eax,[edi+CD_NumObjects]
	Mov	[ebp+CL_NumObjects],eax
	Mov	[ebp+CL_Dummy],esi

.Loop	Mov	eax,[ebp+CL_Height]
	Mov	esi,[ebp+CL_Dummy]
	XOr	edx,edx
	Div dword	[ebp+CL_NumObjects]
	Test	eax,eax
	Jz	.DivideOne
	Mov	ebx,[edi+CD_NumObjects]
	Mov	[ebp+CL_NumObjects],ebx

.Loop2	NEXTNODE	esi,.Done
	Mov	ebx,[esi+CD_MaxHeight]
	Mov	ecx,[esi+CD_Height]
	Cmp	ebx,ecx
	je	.WasMax
	Sub	ebx,[esi+CD_MinHeight]
	Cmp	ebx,eax
	Jbe	.MaxHeight		; 640kb ought to be enough..
	Add	[esi+CD_Height],eax
	Sub	[ebp+CL_Height],eax
	Jmp	.Loop2

.MaxHeight	Add	[esi+CD_Height],ebx
	Sub	[ebp+CL_Height],ebx
.WasMax	Dec dword	[ebp+CL_NumObjects]
	Jmp	.Loop2

.Done	Cmp dword	[ebp+CL_NumObjects],0
	Je	.Exit
	Cmp dword	[ebp+CL_Height],0
	Jne	.Loop
.Exit	Ret

.DivideOne	Cmp dword	[ebp+CL_Height],0
	Je	.Exit
.Divide	NEXTNODE	esi,.Exit
	Mov	eax,[esi+CD_MaxHeight]
	Mov	ebx,[esi+CD_Height]
	Cmp	eax,ebx
	Je	.Divide
	Inc dword	[esi+CD_Height]
	Dec dword	[ebp+CL_Height]
	Jnz	.Divide
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; SetCoordinates will always work with groups, nothing else, It just sets the
; coordinates for everything below itself. This routine will not recurse, but
; only do the coordinate settings for the current group. Something else may do
; the recursion stuff...
;
	Align	16
SetCoordinates	Mov	edi,[ebp+CL_Current]
	;-
	Mov	ecx,[edi+CD_LeftEdge]	; ecx is the X Coordinate
	Mov	edx,[edi+CD_TopEdge]	; edx is the Y Coordinate

	Mov dword	[ebp+CL_Flags],0

	Lea	esi,[edi+CD_ObjectList]
	Bt dword	[edi+GC_Flags],GCB_VERTICAL
	Jc	SetCoordsVert
	Bt dword	[edi+GC_Flags],GCB_HORIZONTAL
	Jc	SetCoordsHor
	Bt dword	[edi+GC_Flags],GCB_ROWS
	Jc near	SetCoordsRows
	Bt dword	[edi+GC_Flags],GCB_COLUMNS
	Jc near	SetCoordsCols
	Ret

SetCoordsVert	NEXTNODE	esi,.VerticalDone
	Cmp dword	[esi+CD_Type],CLASS_GROUP
	Je	.Group

	Bt dword	[ebp+CL_Flags],CLB_WASGROUP
	Jc	.NoSpacing

	Add	edx,[ebp+CL_VSpace]
.NoSpacing	Mov	[esi+CD_TopEdge],edx
	Add	edx,[esi+CD_Height]

	Mov	eax,[ebp+CL_HSpace]
	Mov	[esi+CD_LeftEdge],ecx
	Add	[esi+CD_LeftEdge],eax
	And dword	[ebp+CL_Flags],~CLF_WASGROUP
	Jmp	SetCoordsVert

.Group	Mov	[esi+CD_TopEdge],edx
	Mov	[esi+CD_LeftEdge],ecx
	Add	edx,[esi+CD_Height]
	Or dword	[ebp+CL_Flags],CLF_WASGROUP
	Jmp	SetCoordsVert

.VerticalDone	Ret

SetCoordsHor	NEXTNODE	esi,.HorizontalDone
	Cmp dword	[esi+CD_Type],CLASS_GROUP
	Je	.Group

	Bt dword	[ebp+CL_Flags],CLB_WASGROUP
	Jc	.NoSpacing

	Add	ecx,[ebp+CL_HSpace]	; this is for objects [LeftEdge]
.NoSpacing	Mov	[esi+CD_LeftEdge],ecx
	Add	ecx,[esi+CD_Width]
	Mov	eax,[ebp+CL_VSpace]
	Mov	[esi+CD_TopEdge],edx	; [Topedge]
	Add	[esi+CD_TopEdge],eax
	And dword	[ebp+CL_Flags],~CLF_WASGROUP
	Jmp	SetCoordsHor

.Group	Mov	[esi+CD_LeftEdge],ecx	; this is for groups, without spacers.
	Mov	[esi+CD_TopEdge],edx
	Add	ecx,[esi+CD_Width]
	Or dword	[ebp+CL_Flags],CLF_WASGROUP
	Jmp	SetCoordsHor

.HorizontalDone	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SetCoordsRows	NEXTNODE	esi,.RowsDone
	Cmp dword	[esi+CD_Type],CLASS_GROUP
	Je	.NoSpacing

	Jmp	SetCoordsRows
.NoSpacing	Jmp	SetCoordsRows
.RowsDone	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
SetCoordsCols	NEXTNODE	esi,.ColumnsDone
	Cmp dword	[esi+CD_Type],CLASS_GROUP
	Je	.NoSpacing

	Jmp	SetCoordsCols
.NoSpacing	Jmp	SetCoordsCols
.ColumnsDone	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; GetGroupMetrics - Calculate everything neccesary for this GROUP.
;
; NOTE: The values in ebp+CL_Width/CL_Height is not thesame values as in CD_Width/CD_Height
;       these are calculated values.
;
; Here we calculate the values that we are to divide among the different classes
; in this group. Here we count everything, height for total group, and width for
; the group. We also check if it is a columnar or rowed group, and calculate the
; correct sizes for that aswell...
;
GetGroupMetrics	Mov	edi,[ebp+CL_Current]
	;
	Bt dword	[edi+GC_Flags],GCB_COLUMNS
	Jc near	.Columns
	Bt dword	[edi+GC_Flags],GCB_ROWS
	Jc near	.Rows
	Bt dword	[edi+GC_Flags],GCB_VERTICAL
	Jc	.Vertical

.Horizontal	Mov	eax,[edi+CD_Height]
	Mov	ebx,[edi+CD_Width]
	Mov	[ebp+CL_Height],eax
	Mov	[ebp+CL_Width],ebx
	Ret

.Vertical	Mov	eax,[edi+CD_Height]
	Mov	ebx,[edi+CD_Width]
	Mov	[ebp+CL_Height],eax
	Mov	[ebp+CL_Width],ebx
	Ret

.Columns	Ret

.Rows	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Get the tags needed to layout this class..
;
GetClassTags	Mov	edi,[ebp+CL_Current]
	Mov	eax,CCD_GROUP
	Mov	ebx,[edi+CD_Root]
	Mov	ebx,[ebx+CD_Config]
	LIB	GetTagData,[ebp+CL_UteBase]
	Test	eax,eax
	Jz	.Exit
	Mov	ebx,eax
	;-
	Mov	eax,GCTP_HORIZONTALSPACING
	LIB	GetTagData
	Mov	[ebp+CL_HSpace],eax
	Mov	eax,GCTP_VERTICALSPACING
	LIB	GetTagData
	Mov	[ebp+CL_VSpace],eax
	Mov	eax,GCTP_FRAMETYPE
	LIB	GetTagData
	Mov	[ebp+CL_FrameType],eax
	Ret
	;-
.Exit	Mov dword	[ebp+CL_HSpace],0
	Mov dword	[ebp+CL_VSpace],0
	Mov dword	[ebp+CL_FrameType],0
	Ret

