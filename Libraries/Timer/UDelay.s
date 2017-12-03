;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     UDelay.s V1.0.0
;
;
;     Delays the given number of useconds. This will only guarantee the process
;     to be busy for atleast the given time.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; Inputs:
;
;  eax = Number of useconds to wait.
;
; Output:
;
;  eax = None.
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
TMR_UDelay	PushFD
	PUSHX	eax,ebx,ecx,edx
	Test	eax,eax
	Jz	.Done
	Mov	ecx,eax
	;
	RDTSC
	Mov	ebx,edx	; now
.L	RDTSC
	Mov	eax,ebx
	Sub	eax,edx
	Cmp	eax,ecx
	Jb	.L
	;
.Done	POPX	eax,ebx,ecx,edx
	PopFD
	Ret

