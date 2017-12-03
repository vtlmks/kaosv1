%ifndef Includes_Network_IP_I
%define Includes_Network_IP_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     IP.I V1.0.0
;
;     InternetProtocol (IP) includes, based
;     on the RFC 791 specifications.
;
;

	Struc IP ; InternetProtocol structure
.HV	ResB	1	; Header and version (header/version is high/low nibble)
.TOS	ResB	1	; Type Of Service
.TotalLength	ResW	1	; Total length
.ID	ResW	1	; Identification
.FragmentOffset	ResW	1	; Fragment offset field, see below for definitions
.TTL	ResB	1	; Time To Live
.Protocol	ResB	1	; Protocol
.Checksum	ResW	1	; Checksum
.SourceAddress	ResD	1	; Source IP address
.DestAddress	ResD	1	; Destination IP address
.SIZE	EndStruc

IP_MAXPACKET	Equ	65535	; Maximum packet size


	;
	; IP.FragmentOffset flags
	;

IPFO_MF	Equ	0x2000	; More fragments flag
IPFO_DF	Equ	0x4000	; Don't fragment flag
IPFO_OFFMASK	Equ	0x1fff	; Mask for fragmenting bits


	;
	; IP.TOS (Type Of Service) flags

IPTOS_MINCOST	Equ	0x2
IPTOS_RELIABILITY	Equ	0x4
IPTOS_THROUGHPUT	Equ	0x8
IPTOS_LOWDELAY	Equ	0x10

	;
	; IP.Protocol types

IPPROT_ICMP	Equ	1	; ICMP packets
IPPROT_TCP	Equ	6	; TCP packets
IPPROT_EGP	Equ	8	; EGP packets
IPPROT_UDP	Equ	17	; UDP packets






;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif

