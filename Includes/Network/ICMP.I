%ifndef Includes_Network_ICMP_I
%define Includes_Network_ICMP_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     ICMP.I V1.0.0
;
;     Interface Control Message Protocol (ICMP) includes, based
;     on the RFC 792 specifications.
;
;


	Struc ICMP
.TypeOfMsg	ResB	1	; Type of message, see below
.TypeSubCode	ResB	1	; Type sub code
.Checksum	ResW	1	; Ones complement checksum of structure
	;
.SIZE	EndStruc




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Definitions for ICMP.TypeOfMsg
;


ICMP_ECHOREPLY	Equ	0	; Echo reply
ICMP_UNREACH	Equ	3	; Destination unreachable, subcodes below
ICMP_SOURCEQUENCH	Equ	4	; Packet lost, slow down
ICMP_REDIRECT	Equ	5	; Redirect message, subcodes below
ICMP_ECHO	Equ	8	; Echo service
ICMP_ROUTERADVERT	Equ	9	; Router advertisement
ICMP_ROUTERSOLIC	Equ	10	; Router solicitation
ICMP_TIMEXCEEDED	Equ	11	; Time to live exceeded, subcodes below
ICMP_PARAMPROB	Equ	12	; Parameter problem (header), subcodes below
ICMP_TSTAMP	Equ	13	; Timestamp request
ICMP_TSTAMPREPLY	Equ	14	; Timestamp reply
ICMP_IREQ	Equ	15	; Information request
ICMP_IREQREPLY	Equ	16	; Information reply
ICMP_MASKREQ	Equ	17	; Address mask request
ICMP_MASKREPLY	Equ	18	; Address mask reply


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Definitions for ICMP.TypeSubCode
;


;
; Subcodes for ICMP_UNREACH
;

ICMP_UNREACH_NET		Equ	0	; Net unreachable
ICMP_UNREACH_HOST		Equ	1	; Host unreachable
ICMP_UNREACH_PROT		Equ	2	; Protocol unreachable
ICMP_UNREACH_PORT		Equ	3	; Port unreachable
ICMP_UNREACH_NEEDFRAG	Equ	4	; Fragmentation needed and DF set
ICMP_UNREACH_SRCFAIL	Equ	5	; Source route failed
ICMP_UNREACH_NET_UNKNOWN	Equ	6	; Unknown net
ICMP_UNREACH_HOST_UNKNOWN	Equ	7	; Unknown host
ICMP_UNREACH_ISOLATED	Equ	8	; Source host isolated
ICMP_UNREACH_NET_PROHIB	Equ	9	; Prohibited access
ICMP_UNREACH_HOST_PROHIB	Equ	10	; ditto
ICMP_UNREACH_TOSNET	Equ	11	; Bad TOS for net
ICMP_UNREACH_TOSHOST	Equ	12	; Bad TOS for host

;
; Subcodes for ICMP_REDIRECT
;

ICMP_REDIRECT_NET		Equ	0	; Redirect datagrams for the Network
ICMP_REDIRECT_HOST	Equ	1	; Redirect datagrams for the Host
ICMP_REDIRECT_TOSNET	Equ	2	; Redirect datagrams for the Type of Service and Network
ICMP_REDIRECT_TOSHOST	Equ	3	; Redirect datagrams for the Type of Service and Host

;
; Subcodes for ICMP_TIMEXCEEDED
;

ICMP_TIMEXCEEDED_INTRANS	Equ	0	; Time to live exceeded in transit
ICMP_TIMEXCEEDED_REASS	Equ	1	; Fragment reassembly time exceeded


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif

