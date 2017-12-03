%ifndef Includes_Lists_I
%define Includes_Lists_I

;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Includes release V1.0.0
;
;     Lists.I V1.0.0
;
;     List structures and macros.
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc LIST	; List Header
LH_HEAD	ResD	1	; Ptr to first node in list
LH_TAIL	ResD	1	; End
LH_TAILPRED	ResD	1	; Ptr to last node in list
LH_FLAGS	ResD	1	; Flags
LH_TYPE	ResB	1	; Type of list, described below
LH_PAD	ResB	1	;
LH_SIZE	EndStruc

	Struc MINLIST	; Minimal List Header
MLH_HEAD	ResD	1	; Ptr to first node in list
MLH_TAIL	ResD	1	; End
MLH_TAILPRED	ResD	1	; Ptr to last node in list
MLH_FLAGS	ResD	1	; Flags
MLH_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	ADDHEAD 0	; eax=list, ebx=node
	Mov	ecx,[eax+LH_HEAD]
	Mov	[eax+LH_HEAD],ebx
	Mov	[ebx+LN_SUCC],ecx
	Mov	[ebx+LN_PRED],eax
	Mov	eax,ecx
	Mov	[eax+LN_PRED],ebx
%EndMacro

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	ADDTAIL 0	; eax=list, ebx=node
	Lea	eax,[eax+LH_TAIL]
	Mov	ecx,[eax+LN_PRED]
	Mov	[eax+LN_PRED],ebx
	Mov	[ebx],eax
	Mov	[ebx+4],ecx
	Mov	[ecx],ebx
%EndMacro

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	IFEMPTY 2	; list, label
	Cmp	%1,[%1+LH_TAILPRED]
	Je	%2
%EndMacro

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	IFNOTEMPTY 2	; list, label
	Cmp	%1,[%1+LH_TAILPRED]
	Jne	%2
%EndMacro

;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
%Macro	INITLIST 1	; ptr to list
	Lea	eax,%1
	NEWLIST	eax
%EndMacro

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	NEWLIST 1	; list
	Mov	[%1+LH_TAILPRED],%1
	Lea	%1,[%1+4]
	Mov dword	[%1],0
	Mov	[%1-4],%1
%EndMacro

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	NEXTNODE 2	; =node, exit_label
	Mov	%1,[%1+LN_SUCC]
	Cmp dword	[%1+LN_SUCC],0
	Je	%2
%EndMacro


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	PRED 1	; node
	Mov	%1,[%1+LN_PRED]
%EndMacro

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	PREDNODE 2	; =node, exit_label
	Cmp dword	[%1+LN_PRED],0
	Je	%2
	Mov	%1,[%1+LN_PRED]
%EndMacro

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	REMHEAD 0	; eax=list
	Mov	ebx,[eax]
	Mov	ecx,[ebx]
	Test	ecx,ecx
	Jz	%%.RemHead
	Mov	[eax],ecx
	Mov	[ecx+LN_PRED],eax
%%.RemHead:
%EndMacro

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	REMOVE 0	; eax=node
	Mov	ebx,[eax]
	Mov	eax,[eax+LN_PRED]
	Mov	[eax],ebx
	Mov	[ebx+LN_PRED],eax
%EndM

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	REMTAIL 0	; eax=list
	Mov	ebx,[eax+LH_TAILPRED]
	Mov	ecx,[ebx+LN_PRED]
	Test	ecx,ecx
	Jz	%%.RemTail
	Mov	[eax+LH_TAILPRED],ecx
	Mov	[ecx],eax
	Add dword	[ecx],4
%%.RemTail:
%EndM

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	SUCC 1	; node
	Mov	%1,[%1+LN_SUCC]
%EndM

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	TESTLIST 2	; list, ifempty routine
	Cmp dword	[%1+LH_TAILPRED],0
	Je	%2
%EndM

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
%Macro	TESTNODE 1	; node
	Mov	%1,[%1]
%EndM

%endif
