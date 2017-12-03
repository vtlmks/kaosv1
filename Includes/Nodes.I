%ifndef Includes_Nodes_I
%define Includes_Nodes_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Nodes.I V1.0.0
;
;     Node structures and types.
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc NODE	; List Node
LN_SUCC	ResD	1	; Ptr to next node
LN_PRED	ResD	1	; Ptr to previous node
LN_TYPE	ResB	1	; Node Type, described below
LN_PRI	ResB	1	; Node Priority
LN_NAME	ResD	1	; Ptr to name of node
LN_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc MINNODE	; Minimal List Node
MLN_SUCC	ResD	1	; Ptr to next node
MLN_PRED	ResD	1	; Ptr to previous node
MLN_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
NT_UNKNOWN	Equ	0
NT_PROCESS	Equ	1
NT_INTERRUPT	Equ	2
NT_DEVICE	Equ	3
NT_LIBRARY	Equ	4
NT_MSGPORT	Equ	5
NT_MESSAGE	Equ	6
NT_FREEMSG	Equ	7
NT_REPLYMSG	Equ	8
NT_RESOURCE	Equ	9
NT_MEMORY	Equ	10
NT_THREAD	Equ	11	; Process thread
NT_SEMAPHORE	Equ	12
NT_SIGNALSEM	Equ	13
NT_FONT	Equ	14
NT_SOFTINT	Equ	15
NT_GRAPHICS	Equ	16
NT_DRIVER	Equ	17

%endif
