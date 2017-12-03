;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Window_Event.s V1.0.0
;
;     Window.class V1.0.0
;
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassEvent	PushAD
	Lea	eax,[WindowEventN]
	Int	0xfe
	PopAD
	Ret

WindowEventN	Db	"Window got an event!",0xa,0
