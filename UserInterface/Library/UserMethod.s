;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     UserMethod.s V1.0.0
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Invoke a method through a windowobject
;
;  Inputs:
;   eax = Class returned by OpenClass
;   ebx = Class method
;   ecx = Taglist (or other data, method dependant)
;
;  Output:
;   eax = return data or null
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UI_UserMethod	PushFD
	PushAD

	PUSHX	eax,ebx,ecx
	Mov	eax,WMCL_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	ebp,eax
	POPX	eax,ebx,ecx

	Mov dword	[ebp+WM_Command],WMCMD_USERMETHOD
	Mov	[ebp+WM_Object],eax
	Mov	[ebp+WMCL_Method],ebx
	Mov	[ebp+WMCL_MethodData],ecx

	XOr	eax,eax
	LIBCALL	FindProcess,ExecBase
	Mov	[ebp+WMCL_Process],eax

	Mov	eax,[ebp+WM_Object]
	Cmp dword	[eax+CD_Root],0
	Je	.IsRoot
	Mov	eax,[eax+CD_Root]
.IsRoot	Mov	eax,[eax+WC_WindowPort]
	Mov byte	[ebp+LN_TYPE],NT_FREEMSG
	Mov	ebx,ebp
	LIBCALL	PutMsg,ExecBase

	LIBCALL	Sleep,ExecBase

	Mov	eax,[ebp+WMCL_ReturnData]
	RETURN	eax

	Mov	eax,ebp
	LIBCALL	FreeMem,ExecBase

	PopAD
	PopFD
	Ret
