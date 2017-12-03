%ifndef Includes_Network_UDP_I
%define Includes_Network_UDP_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     UDP.I V1.0.0
;
;     User Datagram Protocol (UDP) includes.
;
;
;

	Struc UDPHeader
.SourcePort	ResW	1	; Source port number
.DestPort	ResW	1	; Destination port number
.Length	ResW	1	; UDP length
.Checksum	ResW	1	; UDP checksum
.SIZE	EndStruc




;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif

