%ifndef Includes_UserInterface_Classes_I
%define Includes_UserInterface_Classes_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Classes.I V1.0.0
;
;     Includes for usage of Classes.
;

	LIBINIT
	LIBDEF	LVOClassMethod


	Struc ClassDefault
	ResB	LN_SIZE
CD_ObjectList	ResB	MLH_SIZE	; Object list
CD_Root	ResD	1	; Object hierarchy root
CD_Owner	ResD	1	; Object owner (parent)
CD_ClassBase	ResD	1	; Object Base
CD_ClassID	ResD	1	; Object ID
CD_Config	ResD	1	; Object Configuration
CD_Type	ResD	1	; Object type
CD_Flags	ResD	1	; Flagset
CD_NumObjects	ResD	1	; Number of childobjects added to this object.
CD_MinWidth	ResD	1	;
CD_MinHeight	ResD	1	;
CD_MaxWidth	ResD	1	;
CD_MaxHeight	ResD	1	;
CD_LeftEdge	ResD	1	;
CD_TopEdge	ResD	1	;
CD_Width	ResD	1	;
CD_Height	ResD	1	;
CD_DefWidth	ResD	1	;
CD_DefHeight	ResD	1	;
CD_ReturnFlags	ResD	1	; Return flags for window
CD_ReturnEvents	ResD	1	; Return events
CD_MouseState	ResD	1	; Mouse state
CD_SIZE	EndStruc


	;
	; Class return codes

	BITDEF	CRF,ACTIVATE,0	; Object activated
	BITDEF	CRF,DEACTIVATE,1	; Object deactivated

	;
	; Class return events

	BITDEF	CRE,CLOSE,0
	BITDEF	CRE,GADGET_UP,1
	BITDEF	CRE,GADGET_DOWN,2
	BITDEF	CRE,REFRESH,3



	BITDEF	CD,LAYOUTDONE,0
	BITDEF	CD,GHOSTED,1

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Tags for CreateObjectList()
;

	TAGINIT	0x20000000
	TAGDEF	COT_APPNAME	; Application name
	TAGDEF	COT_CONFIGNAME	; Application configurationfile
	TAGDEF	COT_OBJECTLIST	; List of objects to create


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Main class config definitions
;
	TAGINIT	0x80000000
	TAGDEF	CCD_WINDOW	; Window config
	TAGDEF	CCD_GROUP	; Group config
	TAGDEF	CCD_BUTTON	; Button config


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Default Class Methods
;


CM_DEFBASE	Equ	0	; Default methods use CM_DEFBASE as base

CM_CREATE	Equ	CM_DEFBASE+0	; Create object
CM_DISPOSE	Equ	CM_DEFBASE+1	; Remove object
CM_GETATTRIBUTES	Equ	CM_DEFBASE+2	;
CM_SETATTRIBUTES	Equ	CM_DEFBASE+3	;
CM_ADDMEMBER	Equ	CM_DEFBASE+4	;
CM_REMMEMBER	Equ	CM_DEFBASE+5	;
CM_REFRESH	Equ	CM_DEFBASE+6	; Refresh damaged regions
CM_RENDER	Equ	CM_DEFBASE+7	; Render everything
CM_LAYOUT	Equ	CM_DEFBASE+8	; Layout
CM_GETMETRICS	Equ	CM_DEFBASE+9	; Fill out dimensions
CM_EVENT	Equ	CM_DEFBASE+10	; Input-handler event

;
; NOTE: Classes must use boundary checks to prevent unsupported Methods, more
; methods will be added.
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Extended Class Methods
;

CM_EXTBASE	Equ	0x10000000	; Extended methods should use CM_EXTBASE as base



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Object types
;

CLASS_OBJECT	Equ	0
CLASS_WINDOW	Equ	1
CLASS_GROUP	Equ	2
CLASS_GROUPEND	Equ	3



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Default class tags
;

	TAGINIT	0x30000000
	TAGDEF	CT_CLASSNAME
	TAGDEF	CT_CLASSVERSION

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
