%ifndef Includes_Ports_I
%define Includes_Ports_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Ports.I V1.0.0
;
;     Message ports and messages.
;

%ifndef Includes_Lists_I
%include "Includes\Lists.I"
%endif

%ifndef Includes_Nodes_I
%include "Includes\Nodes.I"
%endif

%ifndef Includes_TypeDef_I
%include "Includes\TypeDef.I"
%endif


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
	Struc MessagePort
MP_NODE	ResB	LN_SIZE
MP_FLAGS	ResD	1
MP_SIGPROC	ResD	1	; Process to be signalled
MP_ID	ResD	1	; Port identification, non-zero for user ports and unique for each new port.
MP_USERID	ResD	1	; UserID
MP_MSGLIST	ResB	LH_SIZE	; Linked list of messages
MP_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; MP_FLAGS
;
	BITDEF	MP,SELECTED,0	; Used by the Select() call...
	BITDEF	MP,SYSSELECTED,1	; Selected by system
	BITDEF	MP,SYSDISABLED,2	; Forced disabled by system

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
	Struc Message
MN_NODE	ResB	LN_SIZE
MN_REPLYPORT	ResD	1	; Message reply port
MN_LENGTH	ResD	1	; Message length in bytes, add MN_SIZE to the length
MN_PORTID	ResD	1	; MessageportID. Tells you the port id that gave you this message.
MN_USERID	ResD	1	; UserID
MN_SIZE	EndStruc


	;
	; SelectMsgPort() types
	;

	ENUMERATE
	EITEM	MPSELECT_ENABLE		; Select one messageport
	EITEM	MPSELECT_ENABLELIST	; Select messageports from a list
	EITEM	MPSELECT_ENABLEALL	; Select all available messageports
	EITEM	MPSELECT_DISABLE		; Deselect a messageport
	EITEM	MPSELECT_DISABLELIST	; Deselect messageports from a list
	EITEM	MPSELECT_DISABLEALL	; Deselect all available messageports
	;
	EITEM	MPSELECT_SYSTEMSET	; Selected by system, users should stay away from this one
	EITEM	MPSELECT_SYSTEMRESET	; Old selection is restored





;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%endif

