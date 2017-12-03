;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Wait.s V1.0.0
;
;     Wait for process to get ready.
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Input:
;  eax - Port to wait for, or zero to check them all...
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_Wait	PushFD
	Push	ebx
	;
	Call	CheckMsg
	Jc	.NoWait
	;
.Wait	Int	0x61		; call waitstub with a fallthrough to UserSwitch()
	;			; to protect the bit set for PCB_WAIT
	;			; NOTE: Waitstub clears PCB_NOSWITCH ..
.NoWait	Pop	ebx
	PopFD
	Ret
