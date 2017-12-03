%ifndef Includes_Devices_IDE_I
%define Includes_Devices_IDE_I

;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Ide.I V1.0.0
;
;     IDE device includes.
;


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -

IDEIOERR_BASE	Equ	0xb0000000

IDEIOERR_ERROR	Equ	IDEIOERR_BASE+1	; Drive general error
IDEIOERR_BUSY	Equ	IDEIOERR_BASE+2	; Drive busy
IDEIOERR_DRQ	Equ	IDEIOERR_BASE+3	; Drive DRQ


;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%endif


