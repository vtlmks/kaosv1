;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     ClipPixel.s V1.0.0
;
;     Clip one pixel.
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; ClipPixel.
;
; Inputs:
;
; Output:
;  eax = bool; null if pixel is invisible
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
CLIP_ClipPixel	PushFD
	PushAD

	PopAD
	PopFD
	Ret

