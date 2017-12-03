%ifndef Includes_IO_I
%define Includes_IO_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     IO.I V1.0.0
;
;     Structures for I/O communication
;


%ifndef Includes_Ports_I
%include "Includes\Ports.I"
%endif

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; I/O request structure
;

	Struc IORequest
IO_MESSAGE	ResB	MN_SIZE
IO_DEVICE	ResD	1	; Device basepointer
IO_UNIT	ResD	1	; Device unit
IO_COMMAND	ResD	1	; Device command
IO_FLAGS	ResD	1	; Device flags, if any
IO_ERROR	ResD	1	; Error or warning
	;
IO_ACTUAL	ResD	1	; Bytes transfered
IO_LENGTH	ResD	1	; Requested amount of bytes
IO_DATA	ResD	1	; Pointer to data
IO_OFFSET	ResD	1	; Offset for seeking devices
IO_SIZE	EndStruc


;
; IO_FLAGS flags
;

	BITDEF	IO,WAITREQUIRED,0	; Device must send acknowledge before usage, used for OpenDevice only
	BITDEF	IO,QUICK,1	; Complete IO quick


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	DEVINIT	1
%Define	CMD_COUNT	%1
%EndMacro

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	DEVCMD	1	; Commandname
%1	Equ	CMD_COUNT
%Assign	CMD_COUNT	CMD_COUNT+1
%EndMacro


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Default device commands
;

	DEVINIT	0

	DEVCMD	CMD_INVALID	; Invalid command
	DEVCMD	CMD_RESET	; Reset (initiate)
	DEVCMD	CMD_READ	; Default read
	DEVCMD	CMD_WRITE	; Default write
	DEVCMD	CMD_UPDATE	; Write out all buffers
	DEVCMD	CMD_CLEAR	; Clear all buffers
	DEVCMD	CMD_STOP	; Hold current request and queued
	DEVCMD	CMD_START	; Resume after stop
	DEVCMD	CMD_FLUSH	; Flush the entire queue
	;--
	DEVCMD	CMD_NONSTD	; Non-default devicecommands start here

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
; Default device responses
;

DEV_RESPONSE	Equ	0xf0000
DEV_READY	Equ	DEV_RESPONSE+1	; Device is ready to recieve IO requests


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif
