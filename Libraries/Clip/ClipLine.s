;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     ClipLine.s V1.0.0
;
;     Clip a line.
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; ClipLine.
;
; Inputs:
;
; Output:
;  eax =
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
CLIP_ClipLine	PushFD
	PushAD

	PopAD
	PopFD
	Ret

