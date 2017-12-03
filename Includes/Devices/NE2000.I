%ifndef Includes_Devices_NE2000_I
%define Includes_Devices_NE2000_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     NE2000 (8390).I V1.0.0
;
;     NE2000 8390 includes
;


	Struc NE2000EEPROM
.Config1	ResB	1	; See below for bit defs
.Config2	ResB	2	; logical device configuration registers
.Config3	ResB	3
	ResB	1
	;-
.EthernetID	ResB	6	; Ethernet node address
.ProductID	ResB	8	; Assigned by card makers; negligible
	;-
.VendorID	ResB	4	; Plug and Play serial identifier
.SerialNumber	ResB	4
.SerialIDChecksum	ResB	1
	;-
.PnPResourceData	ResB	101
.SIZE	EndStruc

; Detail values of 9346 CONFIG1-3 bytes

	BITDEF	CONFIG1,IOS0,0
	BITDEF	CONFIG1,IOS1,1
	BITDEF	CONFIG1,IOS2,2
	BITDEF	CONFIG1,IOS3,3
	BITDEF	CONFIG1,IRQS0,4
	BITDEF	CONFIG1,IRQS1,5
	BITDEF	CONFIG1,IRQS2,6

	BITDEF	CONFIG2,BS0,0
	BITDEF	CONFIG2,BS1,1
	BITDEF	CONFIG2,BS2,2
	BITDEF	CONFIG2,BS3,3
	BITDEF	CONFIG2,BS4,4
	BITDEF	CONFIG2,PL0,6
	BITDEF	CONFIG2,PL1,7

	BITDEF	CONFIG3,ACTIVEB,0
	BITDEF	CONFIG3,PWRDN,1
	BITDEF	CONFIG3,LEDS0,4
	BITDEF	CONFIG3,LEDS1,5
	BITDEF	CONFIG3,FUDUP,6
	BITDEF	CONFIG3,PNP,7



NE_DATAPORT	Equ	0x10	; NE2000 Port Window.
NE_RESET	Equ	0x1f	; Issue a read for reset

EN_CCMD	Equ	0x00	; Chip's command register

EN0_CLDALO	Equ	0x01	; Low byte of current local dma addr  RD
EN0_STARTPG	Equ	0x01	; Starting page of ring bfr WR
EN0_CLDAHI	Equ	0x02	; High byte of current local dma addr  RD
EN0_STOPPG	Equ	0x02	; Ending page +1 of ring bfr WR
EN0_BOUNDARY	Equ	0x03	; Boundary page of ring bfr RD WR
EN0_TSR	Equ	0x04	; Transmit status reg RD
EN0_TPSR	Equ	0x04	; Transmit starting page WR
EN0_NCR	Equ	0x05	; Number of collision reg RD
EN0_TCNTLO	Equ	0x05	; Low  byte of tx byte count WR
EN0_FIFO	Equ	0x06	; FIFO RD
EN0_TCNTHI	Equ	0x06	; High byte of tx byte count WR
EN0_ISR	Equ	0x07	; Interrupt status reg RD WR
EN0_CRDALO	Equ	0x08	; low byte of current remote dma address RD
EN0_RSARLO	Equ	0x08	; Remote start address reg 0
EN0_CRDAHI	Equ	0x09	; high byte of current remote dma address RD
EN0_RSARHI	Equ	0x09	; Remote start address reg 1
EN0_RCNTLO	Equ	0x0a	; Remote byte count reg WR
EN0_RCNTHI	Equ	0x0b	; Remote byte count reg WR
EN0_RSR	Equ	0x0c	; rx status reg RD
EN0_RXCR	Equ	0x0c	; RX control reg WR
EN0_TXCR	Equ	0x0d	; TX control reg WR
EN0_COUNTER0	Equ	0x0d	; Rcv alignment error counter RD
EN0_DCFG	Equ	0x0e	; Data configuration reg WR
EN0_COUNTER1	Equ	0x0e	; Rcv CRC error counter RD
EN0_IMR	Equ	0x0f	; Interrupt mask reg WR
EN0_COUNTER2	Equ	0x0f	; Rcv missed frame error counter RD

; Page 1

EN1_PHYS	Equ	0x01	; This board's physical enet addr RD WR
EN1_CURPAG	Equ	0x07	; Current memory page RD WR
EN1_MULT	Equ	0x08	; Multicast filter mask array (8 bytes) RD WR

; Chip commands in EN_CCMD

ENC_STOP	Equ	0x01	; Stop the chip
ENC_START	Equ	0x02	; Start the chip
ENC_TRANS	Equ	0x04	; Transmit a frame
ENC_RREAD	Equ	0x08	; remote read
ENC_RWRITE	Equ	0x10	; remote write
ENC_NODMA	Equ	0x20	; No remote DMA used on this card
ENC_PAGE0	Equ	0x00	; Select page 0 of chip registers
ENC_PAGE1	Equ	0x40	; Select page 1 of chip registers

; Commands for EN0_RXCR - RX control reg
ENRXCR_CRC	Equ	0x01	; Save error pkts
ENRXCR_RUNT	Equ	0x02	; Accept runt pkt
ENRXCR_BCST	Equ	0x04	; Accept broadcasts
ENRXCR_MULTI	Equ	0x08	; Multicast (if pass filter)
ENRXCR_PROMP	Equ	0x10	; Promiscuous physical addresses
ENRXCR_MON	Equ	0x20	; Monitor mode (no packets rcvd)

; Bits in EN0_TXCR - transmit control reg
ENTXCR_CRC	Equ	0x01	; inhibit CRC, do not append crc
ENTXCR_LOOP	Equ	0x02	; Set loopback mode
ENTXCR_LB01	Equ	0x06	; encoded loopback control
ENTXCR_ATD	Equ	0x08	; auto tx disable
ENTXCR_OFST	Equ	0x10	; collision offset enable

; Bits in EN0_DCFG - Data config register

	BITDEF	ENDCFG,WTS,0	; Word Transfer Select, 0=byte wide DMA, 1=word wide
	BITDEF	ENDCFG,BOS,1	; Byte Order Select, 0=intel, 1=motorola
	BITDEF	ENDCFG,LAS,2	; This bit must be set to zero
	BITDEF	ENDCFG,LS,3	; loopback select
	BITDEF	ENDCFG,ARM,4	; Auto-initialize remote 0=send packet command not executed 1=send executed
	BITDEF	ENDCFG,FT0,5	; FIFO threshold
	BITDEF	ENDCFG,FT1,6	; FIFO threshold

; Bits in EN0_ISR - Interrupt status register

	BITDEF	ENISR,RX,0	; Receiver, no error
	BITDEF	ENISR,TX,1	; Transmitter, no error
	BITDEF	ENISR,RX_ERR,2	; Receiver, with error
	BITDEF	ENISR,TX_ERR,3	; Transmitter, with error
	BITDEF	ENISR,OVER,4	; Receiver overwrote the ring
	BITDEF	ENISR,COUNTERS,5	; Counters need emptying
	BITDEF	ENISR,RDC,6	; remote dma complete
	BITDEF	ENISR,RESET,7	; Reset completed

ENISR_ALL	Equ	0x3f	; Interrupts we will enable

; Bits in received packet status byte and EN0_RSR


	BITDEF	ENRSR,RXOK,0	; Received a good packet
	BITDEF	ENRSR,CRC,1	; CRC error
	BITDEF	ENRSR,FAE,2	; frame alignment error
	BITDEF	ENRSR,FO,3	; FIFO overrun
	BITDEF	ENRSR,MPA,4	; missed pkt
	BITDEF	ENRSR,PHY,5	; physical/multicase address
	BITDEF	ENRSR,DIS,6	; receiver disable. set in monitor mode
	BITDEF	ENRSR,DEF,7	; deferring

; Bits in EN0_TSR -  TX status reg

	BITDEF	ENTSR,PTX,0	; Packet transmitted without error
	BITDEF	ENTSR,DFR,1	; non deferred tx
	BITDEF	ENTSR,COLL,2	; Collided at least once
	BITDEF	ENTSR,COLL16,3	; Collided 16 times and was dropped
	BITDEF	ENTSR,CRS,4	; carrier sense lost
	BITDEF	ENTSR,FU,5	; TX FIFO Underrun
	BITDEF	ENTSR,CDH,6	; collision detect heartbeat
	BITDEF	ENTSR,OWC,7	; out of window collision

; Description of header of each packet in receive area of memory

EN_RBUF_STAT	Equ	0	; Received frame status
EN_RBUF_NXT_PG	Equ	1	; Page after this frame
EN_RBUF_SIZE_LO	Equ	2	; Length of this frame
EN_RBUF_SIZE_HI	Equ	3	; Length of this frame
EN_RBUF_NHDR	Equ	4	; Length of above header area

; Shared memory management parameters

SM_TSTART_PG	Equ	0x40	; First page of TX buffer
SM_RSTART_PG	Equ	0x46	; Starting page of RX ring
SM_RSTOP_PG	Equ	0x80	; Last page +1 of RX ring



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
