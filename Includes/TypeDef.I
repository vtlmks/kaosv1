%ifndef Includes_TypeDef_I
%define Includes_TypeDef_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     TypeDef.I V1.0.0
;
;     Data storage macros.
;


%Macro	BITDEF 3	; prefix, name, bitnumber
%1B_%2	EQU	%3
%1F_%2	EQU	1<<%3
%EndM

TRUE	Equ	1
FALSE	Equ	0



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%MACRO	EITEM	1
%1	Equ	E_COUNT
%ASSIGN	E_COUNT	E_COUNT+1
%ENDMACRO

%MACRO	ENUMERATE	0
%DEFINE	E_COUNT	0
%ENDMACRO


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%endif
