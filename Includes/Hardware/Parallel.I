%ifndef Includes_Hardware_Parallel_I
%define Includes_Hardware_Parallel_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Parellel.I V1.0.0
;
;     Parallel (LPT) port hardware includes.
;     Currently includes SPP, ECP and EPP.


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Parallel/LinePrinTer base ports
;
;

LPT1_BASE	Equ	0x378	; LPT 1
LPT2_BASE	Equ	0x278	; LPT 2

LPT_DATAPORT	Equ	0	; Data port (SPP), write only
			; ECP address FIFO (ECP MODE), read/write
LPT_STATUSPORT	Equ	1	; Status port (all modes), read/write
LPT_CONTROLPORT	Equ	2	; Control port (all modes), read/write
LPT_ADDRESSPORT	Equ	3	; Address port (EPP) read/write
LPT_EPPDATAPORT	Equ	4	; Data port (EPP) read/write
LPT_CONFIGREGA	Equ	0x400	; Configuration Register A (Config mode) read/write
			; Data FIFO (ECP mode) read/write
			; Test FIFO (Test mode) read/write
			; Data FIFO (Parallel port FIFO mdoe)
LPT_CONFIGREGB	Equ	0x401	; Configuration Register B (Config mode) read/write
LPT_EXTCONFIG	Equ	0x402	; Extended control register (all modes) read/write


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; Status port (all modes)
;

 BITDEF LPTSP,IRQ,2
 BITDEF LPTSP,ERROR,3
 BITDEF LPTSP,SELECTIN,4
 BITDEF LPTSP,PAPEROUT,5
 BITDEF LPTSP,ACK,6
 BITDEF LPTSP,BUSY,7

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; Control port (all modes)
;

 BITDEF LPTCP,STROBE,0
 BITDEF LPTCP,AUTOLF,1	; Auto linefeed
 BITDEF LPTCP,INITPRT,2	; Initialize printer (reset)
 BITDEF LPTCP,SELPRT,3	; Select printer
 BITDEF LPTCP,ENABLEIRQ,4	; Enable IRQ via ack line
 BITDEF LPTCP,ENABLEBIP,5	; Enable bi-directional port

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; ECP's Extended Control Register (ECR)
;

 BITDEF LPTECR,FIFOEMPTY,0	; FIFO empty
 BITDEF LPTECR,FIFOFULL,1	; FIFO full
 BITDEF LPTECR,ECPSERVICE,2	; ECP service
 BITDEF LPTECR,DMAENABLE,3	; DMA enable
 BITDEF LPTECR,ECPI,4	; ECP interrupt bit
 BITDEF LPTECR,MODESEL0,5	; Mode select, see below
 BITDEF LPTECR,MODESEL1,6
 BITDEF LPTECR,MODESEL2,7

; Mode select bits, select current mode of operation
;
; 000 - Standard mode
; 001 - Byte mode
; 010 - Parallel port FIFO mdoe
; 011 - ECP FIFO mode
; 100 - EPP mode
; 101 - Reserved
; 110 - FIFO test mode
; 111 - Configuration mode

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; ECP's Configuration Register A (CRA)
;

 BITDEF LPTCRA,HOSTREC1,0
 BITDEF LPTCRA,HOSTREC2,1
 BITDEF LPTCRA,HOSTRECSEL,2	; Host recovery, see below
 BITDEF LPTCRA,ACCEPTMAX0,4	; Accepts max, see below
 BITDEF LPTCRA,ACCEPTMAX1,5	; Accepts max, see below
 BITDEF LPTCRA,ACCEPTMAX2,6	; Accepts max, see below
 BITDEF LPTCRA,INTLEVEL,7	; 1=Interrupts level triggered, 0=Edge triggered (pulses)


; Accepts max bits:
;
; 0x00 - 16 bit wide words
; 0x01 - 8 bit wide words
; 0x02 - 32 bit wide words
; 0x03-0x07 - Reserved

; Host recovery bits
;
; HOSTRECSEL
;  0 - In forward direction, the 1 byte in the transmitter pipeline
;      doesn't affect FIFO full.
;  1 - In forward direction, the 1 byte in the transmitter pipeline
;      is include as part of FIFO full.
;
; HOSTREC1-2, Host recovery: Unsent byte(s) left in FIFO
;
; 00 - Complete word
; 01 - 1 valid byte
; 10 - 2 valid byes
; 11 - 3 valid bytes

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; ECP's Configuration Register B (CRB)
;

 BITDEF LPTCRB,DMASEL0,0	; DMA select (or display DMA channel status).
 BITDEF LPTCRB,DMASEL1,1
 BITDEF LPTCRB,DMASEL2,2
 BITDEF LPTCRB,IRQSEL0,3	; IRQ select, see below
 BITDEF LPTCRB,IRQSEL1,4
 BITDEF LPTCRB,IRQSEL2,5
 BITDEF LPTCRB,INTSTATUS,6	; Interrupt status, current status of the IRQ pin.
 BITDEF LPTCRB,COMPRESS,7	; If set, compress outgoing data using RLE.

;
; DMA select, selects or display status of the DMA channel, bit 0:2
;
; 000 - Uses a jumpered 8 bit DMA channel
; 001 - DMA channel 1
; 010 - DMA channel 2
; 011 - DMA channel 3
; 100 - Uses a jumpered 16 bit DMA channel
; 101 - DMA channel 5
; 110 - DMA channel 6
; 111 - DMA channel 7

;
; IRQ select, selects or displays status of IRQ line , bit 3:5
;
; 000 - Interrupt selected via jumper
; 001 - IRQ 7
; 010 - IRQ 9
; 011 - IRQ 10
; 100 - IRQ 11
; 101 - IRQ 14
; 110 - IRQ 15
; 111 - IRQ 5
;









;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
