;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     CurrentChunk.S V1.0.0
;
;     CurrentChunk.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Input:
;  eax = IFF
;
IFF_CurrentChunk	Lea	eax,[eax+IFF_CONTEXTLIST]
	SUCC	eax
	Ret

