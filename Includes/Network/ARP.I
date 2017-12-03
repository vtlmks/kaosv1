%ifndef Includes_Network_ARP_I
%define Includes_Network_ARP_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     ARP.I V1.0.0
;
;     Address Resolution Protocol (ARP) includes.
;     (refer to RFC826 for details)
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc ARPHeader
.hrd	ResW	1	; Format of hardware address, see below
.pro	ResW	1	; Format of protocol address
.hln	ResB	1	; Length of hardware address
.pln	ResB	1	; Length of protocol address
.op	ResW	1	; See below
	;
	; remaining fields are of dynamic size
	;
.sha	ResB	6	; Sender hardware address
.spa	ResB	4	; Sender protocol address
.tha	ResB	6	; Target hardware address
.tpa	ResB	4	; Target protocol address
.SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc ARPTable		; ARP lookup-table
	ResB	MLN_SIZE
.IPAddress	ResB	4
.EtherAddress	ResB	6
.Flags	ResD	1
.SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; ARP.hrd values
;

ARPHRD_ETHER	Equ	1	; Ethernet hardware format
ARPHRD_IEEE802	Equ	6	; IEEE 802 hardware format
ARPHRD_ARCNET	Equ	7	; Ethernet hardware format
ARPHRD_FRELAY	Equ	15	; Frame relay hardware format
ARPHRD_STRIP	Equ	23	; Ricochet Starmode Radio hardware format

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; ARP.op values
;

ARPOP_REQUEST	Equ	1	; Request to resolve address
ARPOP_REPLY	Equ	2	; Response to previous request
ARPOP_REVREQUEST	Equ	3	; Request protocol address given hardware
ARPOP_REVREPLY	Equ	4	; Response giving protocol address
ARPOP_INVREQUEST	Equ	8	; Request to identify peer
ARPOP_INVREPLY	Equ	9	; Request identifying peer





;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
