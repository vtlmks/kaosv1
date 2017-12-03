%ifndef Includes_Network_TCP_I
%define Includes_Network_TCP_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     TCP.I V1.0.0
;
;     Transmission Control Protocol (TCP) includes.
;
;
;

	Struc TCPHeader
.SourcePort	ResW	1	; Source port number
.DestPort	ResW	1	; Destination port number
.Seq	ResD	1	; Sequence
.Ack	ResD	1	; Acknowledged sequence
.HeaderLength	ResB	1
.CodeFlags	ResB	1	; Control flags
.Window	ResW	1	; Window advertisement
.Checksum	ResW	1	; Checksum
.Urgent	ResW	1	; Urgent pointer
.SIZE	EndStruc

	;
	; TCP codeflags definitions
	;

	BITDEF	TCPCF,FINISHED,0		; Sender is at end of stream
	BITDEF	TCPCF,SYNCSEQNUM,1	; Synchronize sequence numbers
	BITDEF	TCPCF,RESET,2		; Reset the connection
	BITDEF	TCPCF,PUSH,3		; Segment requests push
	BITDEF	TCPCF,ACKVALID,4		; Acknowledge valid
	BITDEF	TCPCF,URGVALID,5		; Urgent pointer valid



;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif

