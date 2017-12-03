%ifndef Includes_Classes_Window_I
%define Includes_Classes_Window_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Window.I V1.0.0
;
;     Window class includes.
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Window class structure
;


	Struc WindowClass
	ResB	CD_SIZE
	;
WC_ClipRegions	ResD	1	; Array of intersecting regions.
WC_Flags	ResD	1	; Flagset, see below
WC_EventFlags	ResD	1	; Eventflags
WC_Screen	ResD	1	; Screen window belongs to
WC_RenderMask	ResD	1	; Pointer to rendermask
WC_RenderFlags	ResD	1	; Renderflags, see below
WC_RequestMask	ResD	1	; Request mask
WC_WindowPort	ResD	1	; Window process port
WC_Pens	ResD	1	; Pointer to a pen array or null.
WC_UserPort	ResD	1	; User port
WC_ActiveObject	ResD	1	; Active object in the window
WC_Callback	ResD	1	; Callback routine
WC_SIZE	EndStruc

	;
	; Bit definitions for WC_Flags
	;

	BITDEF	WC,MINIMIZED,0
	BITDEF	WC,MAXIMIZED,1
	BITDEF	WC,ROOT,31


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Window object tags, use these when creating a new window object.
;

	TAGINIT	0x42000000
	TAGDEF	WCT_LEFT	; Window leftedge in pixels
	TAGDEF	WCT_TOP	; Window topedge in pixels
	TAGDEF	WCT_WIDTH	; Window width in pixels
	TAGDEF	WCT_HEIGHT	; Window height in pixels
	TAGDEF	WCT_FLAGS	; Flagset, see below
	TAGDEF	WCT_EVENTFLAGS	; Event filter
	TAGDEF	WCT_USERPORT	; User port to send events to

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; WindowMessages may be sent as NT_FREEMSG only if the message doesn't contain
; allocated memory pointers. The windowmessage must be sent to the window WC_WindowPort. Users
; may not DoMethod() a class directly, they have to send the method through the WindowPort.
;
;

	Struc WindowMessage
	ResB	MN_SIZE
WM_Command	ResD	1	; Type of windowmessage, see below for WMCMD_ definitions.
WM_Object	ResD	1	; Pointer to the object that this message concerns.
	;
	; here goes either a WMIEvent or WMClass event structure depending on if type
	; is WMCMD_IEVENT or WMCMD_USERMETHOD/WMCMD_CLASSMETHOD
	;
WM_SIZE	EndStruc


	;
	; These are the available WindowMessage types (commands) :
	;

	ENUMERATE
	EITEM	WMCMD_IEVENT	; Inputhandler event
	EITEM	WMCMD_CLASSMETHOD	; Window -> Class method
	EITEM	WMCMD_USERMETHOD	; User (-> Window) -> Class method
	EITEM	WMCMD_INTERCLASS	; Class -> Class method
	EITEM	WMCMD_EVENT	; Window -> User event

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc WMIEvent	; Used if WM_Command is set to WMCMD_IEVENT
	ResB	WM_SIZE
WMIE_Type	ResD	1	; Type of IEvent
	;
WMIE_KeyRaw	ResB	1	; Keyboard raw key value
WMIE_KeyVanilla	ResB	1	; Keyboard vanilla key (translated) value
WMIE_KeyQualifier	ResB	1	; Keyboard qualifier mask, see below for definitions
	;
WMIE_MouseX	ResD	1	; Mouse X position; screen position
WMIE_MouseY	ResD	1	; Mouse Y position; screen position
WMIE_MouseDeltaX	ResD	1	; Mouse delta X
WMIE_MouseDeltaY	ResD	1	; Mouse delta Y
WMIE_MouseButton	ResD	1	; Mouse button status (left,right,middle = bit 0,1,2)
WMIE_MouseWheel	ResD	1	; Mouse wheel delta
WMIE_SIZE	EndStruc

	;
	; WMIE_Type events
	;

	ENUMERATE
	EITEM	WMIET_ACTIVATEWINDOW	; Activate window
	EITEM	WMIET_INACTIVATEWINDOW	; Inactivate window
	EITEM	WMIET_MOUSE		; Mouse event
	EITEM	WMIET_KEYBOARD		; Keyboard event

	;
	; WMIE_MouseButton bit definitions
	;

	BITDEF	WMIEMB,LEFT,0		; Left mouse button
	BITDEF	WMIEMB,RIGHT,1		; Right mouse button
	BITDEF	WMIEMB,MIDDLE,2		; Middle mouse button

	;
	; WMIE_Qualifier bit definitions
	;

	BITDEF	WMIEQF,SCROLLLOCK,0
	BITDEF	WMIEQF,NUMLOCK,1
	BITDEF	WMIEQF,CAPSLOCK,2
	BITDEF	WMIEQF,RIGHTALT,3
	BITDEF	WMIEQF,LEFTALT,4
	BITDEF	WMIEQF,CTRL,5
	BITDEF	WMIEQF,RIGHTSHIFT,6
	BITDEF	WMIEQF,LEFTSHIFT,7


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc WMClass	; Used if WM_Command is set to WMCMD_USERMETHOD or WMCMD_CLASSMETHOD
	ResB	WM_SIZE
WMCL_Method	ResD	1	; Method to use, see Classes.I for method definitions.
WMCL_MethodData	ResD	1	; Method data, method dependant.
WMCL_Process	ResD	1	; Process invoking the method.
WMCL_ReturnData	ResD	1	; Return data for the caller.
WMCL_SIZE	EndStruc


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc WMEvent
	ResB	WM_SIZE
WME_Event	ResD	1	; Event flags
WME_SIZE	EndStruc



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif

