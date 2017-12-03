%ifndef Includes_IFF_I
%define Includes_IFF_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     IFF.I V1.0.0
;
;     Additional description goes here.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
	Struc IFFHANDLE
IFF_STREAM	ResD	1
IFF_FLAGS	ResD	1
IFF_DEPTH	ResD	1
IFF_STREAMHOOK	ResD	1
IFF_ENTRYHOOK	ResD	1
IFF_EXITHOOK	ResD	1
IFF_CONTEXTLIST	ResB	MLH_SIZE
IFF_LCILIST	ResB	MLH_SIZE
IFF_SIZE	EndStruc

; Bit masks for the "IFF_FLAGS" field
;
	BITDEF	IFF,READ,0
	BITDEF	IFF,WRITE,1
	BITDEF	IFF,FSEEK,2
	BITDEF	IFF,RSEEK,3
IFFF_RWBITS	Equ	IFFF_READ|IFFF_WRITE

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; When the library calls your stream handler, you'll be passed a pointer
; to this structure as the "message packet".
;
	Struc IFFSTREAMCMD
ISC_COMMAND	ResD	1
ISC_BUFFER	ResD	1
ISC_NUMBYTES	ResD	1
ISC_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
	Struc CONTEXTNODE
	ResB	MLN_SIZE
CN_ID	ResD	1
CN_TYPE	ResD	1
CN_LENGTH	ResD	1
CN_SCAN	ResD	1
CN_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
	Struc LOCALCONTEXTITEM
	ResB	MLN_SIZE
LCI_ID	ResD	1
LCI_TYPE	ResD	1
LCI_IDENT	ResD	1
LCI_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
	Struc STOREDPROPERTY
SPR_LENGTH	ResD	1
SPR_DATA	ResD	1
SPR_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
	Struc COLLECTIONITEM
CIT_NEXT	ResD	1
CIT_LENGTH	ResD	1
CIT_DATA	ResD	1
CIT_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
IFFERR_EOF	Equ	-1
IFFERR_EOC	Equ	-2
IFFERR_NOSCOPE	Equ	-3
IFFERR_NOMEM	Equ	-4
IFFERR_READ	Equ	-5
IFFERR_WRITE	Equ	-6
IFFERR_SEEK	Equ	-7
IFFERR_MANGLED	Equ	-8
IFFERR_SYNTAX	Equ	-9
IFFERR_NOTIFF	Equ	-10
IFFERR_NOHOOK	Equ	-11
IFF_RETURN2CLIENT	Equ	-12

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Possible callback command values
;
IFFCMD_INIT	Equ	0	; Prepare your stream for a session
IFFCMD_CLEANUP	Equ	1	; Terminate stream session
IFFCMD_READ	Equ	2	; Read bytes from stream
IFFCMD_WRITE	Equ	3	; Write bytes to stream
IFFCMD_SEEK	Equ	4	; Seek on stream
IFFCMD_ENTRY	Equ	5	; Just entered a new context
IFFCMD_EXIT	Equ	6	; About to leave a context
IFFCMD_PURGELCI	Equ	7	; Purge a LocalContextItem

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Possible Parse modes.
;
IFFPARSE_SCAN	Equ	0
IFFPARSE_STEP	Equ	1
IFFPARSE_RAWSTEP	Equ	2

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%endif
