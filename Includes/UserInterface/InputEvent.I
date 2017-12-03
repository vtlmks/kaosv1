%ifndef LIBRARIES_UserInterface_InputEvent_I
%define LIBRARIES_UserInterface_InputEvent_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     InputEvent.I V1.0.0
;
;     InputEvent includes.
;


	Struc UIPKT
	ResB	MN_SIZE
UIPKT_COMMAND	ResD	1	; Packet command
UIPKT_DATA	ResD	1	; Packet data
UIPKT_LENGTH	ResD	1	; Packet length
	;
UIPKT_SIZE	EndStruc


	ENUMERATE
	EITEM	UIPKTCMD_RAWMOUSE
	EITEM	UIPKTCMD_RAWKEY
	EITEM	UIPKTCMD_OPENOBJECT
	EITEM	UIPKTCMD_CLOSEOBJECT


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; remove it all from here..




;	Struc IHPKT		; Packet to communicate with InputHandler, i.e. Handler<>InputHandler
;	ResB	MN_SIZE
;IHPKT_COMMAND	ResD	1	; Packet command
;IHPKT_DATA	ResD	1	; Packet data
;IHPKT_LENGTH	ResD	1	; Packet length, optional
;	;
;IHPKT_SIZE	EndStruc


;IHCMD_REGISTER	Equ	0	; Register handle
;IHCMD_UNREGISTER	Equ	1	; Unregister handle
;IHCMD_RAWKEY	Equ	2	; Raw key events
;IHCMD_RAWMOUSE	Equ	3	; Raw mouse events




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;;
;; <<< OBS! EVERYTHING BELOW OF THIS IS SOON TO BE OBSOLETE .. REMOVE ASAP >>>
;;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -


;
; This is the message recieved from WC_WindowPort, currently all messages are sent as
; NT_FREEMSG and should be FreeMem'd and NOT replied.
;
;


;	Struc IHMessage
;	ResB	MN_SIZE
;IHMSG_Type	ResD	1	; Type of event, see bitfield definition below
;IHMSG_Object	ResD	1	; Object ptr
;IHMSG_Key	ResB	1	; Raw/vanilla key
;IHMSG_Qualifier	ResB	1	; Qualifier mask
;
;IHMSG_MouseX	ResD	1	; Mouse X position
;IHMSG_MouseY	ResD	1	; Mouse Y position
;IHMSG_MouseButton ResD	1	; Mouse button
;
;	; fill this out with needed stuff
;
;IHMSG_SIZE	EndStruc

	;
	; Qualifier bits
	;


	BITDEF	UIRKQUALIFIER,SCROLLLOCK,0
	BITDEF	UIRKQUALIFIER,NUMLOCK,1
	BITDEF	UIRKQUALIFIER,CAPSLOCK,2
	BITDEF	UIRKQUALIFIER,RIGHTALT,3
	BITDEF	UIRKQUALIFIER,LEFTALT,4
	BITDEF	UIRKQUALIFIER,CTRL,5
	BITDEF	UIRKQUALIFIER,RIGHTSHIFT,6
	BITDEF	UIRKQUALIFIER,LEFTSHIFT,7

	;
	; Event types (idcmp..)
	;

	BITDEF	IHEVENT,GADGETUP,0	; Object is released
	BITDEF	IHEVENT,GADGETDOWN,1	; Object is pressed
	BITDEF	IHEVENT,RAWKEY,2		; Raw keyboard value
	BITDEF	IHEVENT,VANILLAKEY,3	; Translated keyboard value
	BITDEF	IHEVENT,MOUSEBUTTONS,4	; Mousebutton bitfield
	BITDEF	IHEVENT,MOUSEMOVE,5	; Mousemovement x/y
	BITDEF	IHEVENT,WINDOWACTIVATE,6	; Window object is activated
	BITDEF	IHEVENT,WINDOWINACTIVATE,7	; Window object is inactivated

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%endif
