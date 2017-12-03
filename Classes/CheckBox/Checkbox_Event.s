;
; (C) Copyright 1999-2002 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Checkbox_Event.s V1.0.0
;
;     Checkbox.class V1.0.0
;
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ClassEvent	Mov	ebx,[ecx+WMIE_MouseButton]

	Bt	ebx,WMIEMBB_LEFT
	Jnc	.NoLeftPressed
	Bt dword	[eax+CD_MouseState],WMIEMBB_LEFT
	Jc	.NoLeft
	Or dword	[eax+CD_ReturnEvents],CREF_GADGET_DOWN
	Jmp	.NoLeft

.NoLeftPressed	Bt dword	[eax+CD_MouseState],WMIEMBB_LEFT
	Jnc	.NoLeftReleased
	Or dword	[eax+CD_ReturnEvents],CREF_GADGET_UP
	XOr dword	[eax+CB_State],1
	Jmp	.NoLeft

.NoLeftReleased:
.NoLeft:

.Render	PushAD
	Call	ClassRender
	PopAD

.Exit	Mov	[eax+CD_MouseState],ebx
	Ret

