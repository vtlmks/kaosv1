%ifndef Includes_Hardware_Pic_I
%define Includes_Hardware_Pic_I
;
; (C) Copyright 1999 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Pic.I V1.0.0
;
;     PIC 8259 includes.
;



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -


; IRQ 0-7 are master IRQ's, 8-15 are slave IRQ's. By default the IRQ 9-12 and
; 15 are free.

IRQ_TIMER	EQU	0	; Timer (8254)
IRQ_KEYBOARD	EQU	1	; Keyboard (8042)
IRQ_SLAVEPIC	EQU	2	; Slave PIC link
IRQ_COM2	EQU	3	; Serialport 2
IRQ_COM1	EQU	4	; Serialport 1
IRQ_LPT2	EQU	5	; Parallellport 2
IRQ_FLOPPY	EQU	6	; Floppy device controller
IRQ_LPT1	EQU	7	; Parallellport 1
IRQ_CMOSCLK	EQU	8	; CMOS realtime clock
IRQ_IRQ9	EQU	9	; Free
IRQ_IRQ10	EQU	10	; Free
IRQ_IRQ11	EQU	11	; Free
IRQ_PS2MOUSE	EQU	12	; PS/2 Mouse IRQ
IRQ_MATH	EQU	13	; Math coprocessor (?)
IRQ_IDEHD	EQU	14	; IDE harddisk controller
IRQ_IRQ15	EQU	15	; Free

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

PIC_M	EQU	0x20	; Master PIC I/O
PIC_S	EQU	0xa0	; Slave PIC I/O

PIC_EOI	EQU	0x20	; PIC EOI command
ICW1	EQU	0x11	; Interrupt Control Word 1
ICW4	EQU	0x01	; Interrupt Control Word 4
PIC_MVEC	EQU	0x68	; Master PIC vector
PIC_SVEC	EQU	0x70	; Slave PIC vector

OCW3_IRR	EQU	0x0a	; PIC read IRR
OCW3_ISR	EQU	0x0b	; PIC read ISR



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%endif
