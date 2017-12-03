%ifndef Includes_Devices_Serial_I
%define Includes_Devices_Serial_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Serial.I V1.0.0
;
;     Serial.device includes.
;

;
; Standard is 8 Bit, 1 Stopbit and No Parity.
;
; Remember that the below bits are mutual exclusive, and if not set, the device
; will set a default.
;


	BITDEF	SER,SHARED,0
	BITDEF	SER,PARITY_ODD,1
	BITDEF	SER,PARITY_EVEN,2
	BITDEF	SER,PARITY_HIGH_STICKY,3
	BITDEF	SER,PARITY_LOW_STICKY,4
	BITDEF	SER,2STOPBITS,5
	BITDEF	SER,WLEN_5BIT,6
	BITDEF	SER,WLEN_6BIT,7
	BITDEF	SER,WLEN_7BIT,8
	BITDEF	SER,FIFO_1BYTE_IRQ,9
	BITDEF	SER,FIFO_4BYTE_IRQ,10
	BITDEF	SER,FIFO_8BYTE_IRQ,11
	BITDEF	SER,FIFO_14BYTE_IRQ,12


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
