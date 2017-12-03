%ifndef Includes_Network_Ethernet_I
%define Includes_Network_Ethernet_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Ethernet.I V1.0.0
;
;     Ethernet includes
;

ETHER_ADDR_LEN	Equ	6		; Number of bytes in an ethernet (MAC) address
ETHER_TYPE_LEN	Equ	2		; Number of bytes in the type field
ETHER_CRC_LEN	Equ	4		; Number of bytes in the trailing CRC field
ETHER_HDR_LEN	Equ	(ETHER_ADDR_LEN*2+ETHER_TYPE_LEN)	; Combined header length

ETHER_MIN_LEN	Equ	64		; Minimum packet length
ETHER_MAX_LEN	Equ	1518		; Maximum packet length

	Struc EtherHeader
Ether_DHost	ResB	ETHER_ADDR_LEN
Ether_SHost	ResB	ETHER_ADDR_LEN
Ether_Type	ResB	ETHER_TYPE_LEN
Ether_SIZE	EndStruc

ETHERTYPE_LOOP	Equ	0x60	; Loopback packet
ETHERTYPE_ECHO	Equ	0x200	; Echo packet
ETHERTYPE_PUP	Equ	0x400	; Xerox PUP protocol
ETHERTYPE_IP	Equ	0x800	; IP protocol
ETHERTYPE_ARP	Equ	0x806	; Address Resolution Protocol (ARP)
ETHERTYPE_RARP	Equ	0x8035	; Reverse Address Resolution Protocol (RARP)
ETHERTYPE_VLAN	Equ	0x8100	; IEEE 802.1Q VLAN tagging
ETHERTYPE_IPV6	Equ	0x86dd	; IPv6 protocol
ETHERTYPE_LOOPBACK Equ	0x9000	; Loopback

ETHERTYPE_TRAILER	Equ	0x1000	; Trailer packet

ETHERMTU	Equ	(ETHER_MAX_LEN-ETHER_HDR_LEN-ETHER_CRC_LEN)
ETHERMIN	Equ	(ETHER_MIN_LEN-ETHER_HDR_LEN-ETHER_CRC_LEN)




;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
