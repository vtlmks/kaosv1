;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Button_Event.s V1.0.0
;
;     Button.class V1.0.0
;
;

ClassEvent	Mov	ebx,[ecx+WMIE_MouseButton]

	Mov	ecx,RENDER_OVER

	Bt	ebx,WMIEMBB_LEFT
	Jnc	.NoLeftPressed
	Bt dword	[eax+CD_MouseState],WMIEMBB_LEFT
	Jc	.NoLeft
	Or dword	[eax+CD_ReturnEvents],CREF_GADGET_DOWN
	Mov	ecx,RENDER_PRESSED
	Jmp	.NoLeft

.NoLeftPressed	Bt dword	[eax+CD_MouseState],WMIEMBB_LEFT
	Jnc	.NoLeftReleased
	Or dword	[eax+CD_ReturnEvents],CREF_GADGET_UP
	Mov	ecx,RENDER_NORMAL
	Jmp	.NoLeft

.NoLeftReleased:
.NoLeft:

.Render	PushAD
	Call	ClassRender
	PopAD

.Exit	Mov	[eax+CD_MouseState],ebx
	Ret

