;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     GetMouseState.s V1.0.0
;
;     Input-handler GetMouseState()
;
;     Returns the current mouse state.
;
;
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; GetMouseState
;
;  Input:
;
;   -
;
;  Output:
;
;   eax = Mousestate
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IHGetMouseState	Mov	eax,[edx]
	Mov	eax,[eax+IH_ButtonStatus]
	Ret

