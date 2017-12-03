;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     InitIFF.S V1.0.0
;
;     InitIFF.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; InitIFF(IFF (eax), Flags (ebx), StreamHook (ecx));
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IFF_InitIFF	Mov	[eax+IFF_STREAMHOOK],ecx
	Mov	[eax+IFF_FLAGS],ebx
	Ret

