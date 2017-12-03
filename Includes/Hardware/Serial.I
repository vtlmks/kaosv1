%ifndef Includes_Hardware_Serial_I
%define Includes_Hardware_Serial_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Serial.I V1.0.1
;
;     Serial/RS232 (UART) hardware includes.
;
;     Currently supporting:
;
;     - 16450
;     - 16550 (16 byte buffer) obsolete
;     - 16550A, FIFO
;     - 16650, 32 byte FIFO
;     - 16750, 64 byte FIFO
;
;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; UART ports
;

UART0_BASE	Equ	0x3f8	; COM1, IRQ 4
UART1_BASE	Equ	0x2f8	; COM2, IRQ 3
UART2_BASE	Equ	0x3e8	; COM3, IRQ 4
UART3_BASE	Equ	0x2e8	; COM4, IRQ 3

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; UART registers, relative to UART port bases; UART0 LSR is i.e. UART0_BASE+UART_LSR
;

UART_RX	Equ	0x0	; UART (R/-) Recieve Buffer (RBR)
UART_TX	Equ	0x0	; UART (-/W) Transmitter Holding Buffer (THR)
UART_DLL	Equ	0x0	; UART (-/W) Divisor Latch Low byte (DLAB=1) Least significant byte
UART_DLH	Equ	0x1	; UART (-/W) Divisor Latch High byte(DLAB=1) Most significant byte
UART_IER	Equ	0x1	; UART (R/W) Interrupt Enable Register (IER)
UART_IIR	Equ	0x2	; UART (R/-) Interrupt Identification Register (IIR)
UART_FCR	Equ	0x2	; UART (-/W) First In/First Out Control Register (FCR)
UART_EFR	Equ	0x2	; UART (R/W) Extended Features Register (DLAB=1) (16C660 only)
UART_LCR	Equ	0x3	; UART (R/W) Line Control Register (LCR)
UART_MCR	Equ	0x4	; UART (R/W) Modem Control Register (MCR)
UART_LSR	Equ	0x5	; UART (R/-) Line Status Register (LSR)
UART_MSR	Equ	0x6	; UART (R/-) Modem Status Register (MSR)
UART_SCR	Equ	0x7	; UART (R/W) Scratch register

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; UART common divisors and latchbytes for different speeds.
; Latch high/low bytes are presented
;
; The divisor is calculated by dividing the oscillator frequency rate by
; the baudrate*16.
;
; divisor = 1843200/(baudrate*16)
;
;

%DEFINE	UARTDIVS(a)	1843200/(a*16)

%Macro	UARTDIVISOR	1
UARTDIV%1	Equ	UARTDIVS(%1)
UARTDIV%1LHB	Equ	UARTDIVS(%1)>>8
UARTDIV%1LLB	Equ	UARTDIVS(%1)&0xff
%EndMacro

 UARTDIVISOR	50	; UARTDIV50, UARTDIV50LHB, UARTDIV50LLB
 UARTDIVISOR	75	; ..
 UARTDIVISOR	110	; ..
 UARTDIVISOR	300
 UARTDIVISOR	600
 UARTDIVISOR	1200
 UARTDIVISOR	2400
 UARTDIVISOR	4800
 UARTDIVISOR	9600
 UARTDIVISOR	19200
 UARTDIVISOR	38400
 UARTDIVISOR	57600
 UARTDIVISOR	115200


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; UART Interrupt Enable Register (IER)
;

 BITDEF UARTIER,ERDAI,0	; Enable recieved data available interrupt
 BITDEF UARTIER,ETHREI,1	; Enable transmitter holding register empty interrupt
 BITDEF UARTIER,ERLSI,2	; Enable reciever line status interrupt
 BITDEF UARTIER,EMSI,3	; Enable modem status interrupt
 BITDEF UARTIER,ESLEEP,4	; Enables sleep mode (16750)
 BITDEF UARTIER,ELPM,5	; Enables lowpower mode (16750)

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; UART Interrupt Identification Register (IIR)
;

 BITDEF UARTIIR,STOPBITWLEN1,0	; FIFO enable word
 BITDEF UARTIIR,STOPBITWLEN2,1	; FIFO enable word
 BITDEF UARTIIR,STOPBITLEN,2	; Length of Stop Bit
 BITDEF UARTIIR,EFIFO64,5	; Enable 64 byte FIFO (16750 only)
 BITDEF UARTIIR,EFIFO1,6	; FIFO enable
 BITDEF UARTIIR,EFIFO2,7	; FIFO enable (both bits should be set, 6:7)


; Bits 6:7 = FIFO enable
;  Bit 6, Bit 7
;      0      0	= No FIFO
;      0      1   = FIFO enable but unusable
;      1      1   = FIFO enabled

; Bit 2 = Length of Stop bit
;     0 = One stop bit
;     1 = 2 stops bits for words of length 6,7 or 8 bits or 1.5 stop bits
;                 for word lengths of 5 bits.

; Bits 0:1 = Word length
;   Bit 1, Bit 0
;       0      0   = 5 bits
;       0      1   = 6 bits
;       1      0   = 7 bits
;       1      1   = 8 bits


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; UART First In/First Out Control Register (FCR)
;

 BITDEF UARTFCR,ITL2,7	; Interrupt trigger level, see below
 BITDEF UARTFCR,ITL1,6
 BITDEF UARTFCR,EFIFO64,5	; Enable 64 byte FIFO (16750 only)
 BITDEF UARTFCR,DMAMS,3	; DMA mode select. Change status of RXRDY/TXRDY from mode 1 to 2.
 BITDEF UARTFCR,CTFIFO,2	; Clear Transmit FIFO
 BITDEF UARTFCR,CRFIFO,1	; Clear Transmit FIFO
 BITDEF UARTFCR,EFIFO,0	; Enable FIFO

; Bits 6:7 - Interrupt trigger level
;  Bit 7, Bit 6
;    0      0	= 1 byte
;    0      1	= 4 bytes
;    1      0	= 8 bytes
;    1      1	= 14 bytes


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; UART Line Control Register (LCR)
;

 BITDEF UARTLCR,STOPBITWLEN1,0	; Word Length
 BITDEF UARTLCR,STOPBITWLEN2,1	;
 BITDEF UARTLCR,STOPBITLEN,2	; Length of Stop Bit
 BITDEF UARTLCR,PARITYENABLE,3	; Parity select
 BITDEF UARTLCR,PARITYEVEN,4
 BITDEF UARTLCR,PARITYSTICK,5
 BITDEF UARTLCR,BREAK,6	; Set break enable
 BITDEF UARTLCR,DLAB,7	; Set=Divisor Latch Access Bit Clr=Access to reciever buffer,
		; transmitter buffer and IER.

; Bits 0:1 = Word length
;   Bit 1, Bit 0
;       0      0   = 5 bits
;       0      1   = 6 bits
;       1      0   = 7 bits
;       1      1   = 8 bits
;
; Bit 2 = Length of Stop bit
;     0 = One stop bit
;     1 = Two stops bits for words of length 6,7 or 8 bits or 1.5 stop bits
;         for word lengths of 5 bits.
;
; Bits 3:5 = Parity select
;   Bit 3, Bit 4, Bit 5
;       X      X      0   = No Parity
;       0      0      1   = Odd Parity
;       0      1      1   = Even Parity
;       1      0      1   = High Parity (Sticky)
;       1      1      1   = Low Parity (Sticky)
;

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; UART Modem Control Register (MCR)
;

 BITDEF UARTMCR,FORCEDTR,0	; Force data terminal ready
 BITDEF UARTMCR,FORCERTS,1	; Force request to send
 BITDEF UARTMCR,AUX1,2	; AUX output 1
 BITDEF UARTMCR,AUX2,3	; AUX output 2
 BITDEF UARTMCR,LOOPBACK,4	; Loopback mode
 BITDEF UARTMCR,AUTOFLOW,5	; Autoflow control (16750)

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; UART Line Status Register (LSR)
;

 BITDEF UARTLSR,DRDY,0	; Data Ready
 BITDEF UARTLSR,OVERRUNERR,1	; Overrun error
 BITDEF UARTLSR,PARITYERR,2	; Parity error
 BITDEF UARTLSR,FRAMINGERR,3	; Framing error
 BITDEF UARTLSR,BREAKINT,4	; Break interrupt
 BITDEF UARTLSR,EMPTYTHR,5	; Empty Transmitter Holding Register
 BITDEF UARTLSR,EMPTYDHR,6	; Empty Data holding register
 BITDEF UARTLSR,FIFORECVERR,7	; Error in recieved FIFO

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
;
; UART Modem Status Register (MSR)
;

 BITDEF UARTMSR,DCTS,0	; Delta Clear To Send
 BITDEF UARTMSR,DDSR,1	; Delta Data Set Ready
 BITDEF UARTMSR,TERI,2	; Trailing Edge Ring Indicator
 BITDEF UARTMSR,DDCD,3	; Delta Data Carrier Detect
 BITDEF UARTMSR,CTS,4	; Clear To Send
 BITDEF UARTMSR,DSR,5	; Data Set Ready
 BITDEF UARTMSR,RI,6	; Ring Indicator
 BITDEF UARTMSR,CD,7	; Carrier Detect

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
