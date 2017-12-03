;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     RawMouse.s V1.0.0
;



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
UIH_RawMouse	PushFD
	PushAD
	Call	UIRM_CopyPacket		; Start with this one
	Call	UIRM_Position
	Call	UIRM_FindWindow
	Call	UIRM_CheckMisc
	Jc	.Done
	Call	UIRM_SendPacket
.Done	Call	RenderMousePtr
	PopAD
	PopFD
	Ret




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Check miscellaneous
;
; - Send press/release button events
; - Activate/deactivate windows
; - Update focuswindow
;

UIRM_CheckMisc	Mov	ecx,WMIEMBF_LEFT
	Call	UIRM_CheckButton
	Test	eax,eax
	Jnz	.Changed
.Done	Clc
	Ret
.Changed	Cmp	eax,1
	Jne	.Release

	Mov	eax,[ebp+UIH_Window]
	Cmp	[SysBase+SB_FocusWindow],eax		; Check if window == focuswindow
	Je	.Done
	Call	UIRM_SendActivate			; Activate new window

	Push dword	[ebp+UIH_Window]
	Mov	eax,[SysBase+SB_FocusWindow]
	Mov	[ebp+UIH_Window],eax
	Call	UIRM_SendDeActivate		; Deactivate old window
	Pop dword	[SysBase+SB_FocusWindow]		; Set new window to focuswindow
	Stc
	Ret

.Release	Call	UIRM_SendPacket.ForcePacket		; Send release to window proc
	Stc
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Check mouse button against old mouse button status
;
; Inputs:
;  ecx = button bit<<2
;
; Output:
;  eax = 1 : Press
;  eax =-1 : Release
;  eax = 0 : No change
;

UIRM_CheckButton	Mov	eax,[ebp+UIH_ButtonStatus]
	And	eax,ecx
	Mov	ebx,[ebp+UIH_OldButtons]
	And	ebx,ecx
	Cmp	eax,ebx
	Je	.NoChange
	Ja	.Press
	Dec	eax		; -1 = release
	Ret
.Press	Mov	eax,1		; 1 = press
	Ret
.NoChange	XOr	eax,eax		; 0 = no change
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Copy incoming packetdata for later usage
;
UIRM_CopyPacket	Mov	esi,[eax+UIPKT_DATA]
	XOr	eax,eax
	Lodsb			; Get buttons
	Movzx	eax,al

;	Cmp	[ebp+UIH_ButtonStatus],eax
;	Je	.NoButtons

	Mov	ebx,[ebp+UIH_ButtonStatus]
	Mov	[ebp+UIH_OldButtons],ebx
	Mov	[ebp+UIH_ButtonStatus],eax
	;
.NoButtons	Lodsb			; Get mouse delta x
	Movsx	eax,al
	Cmp	[ebp+UIH_DeltaX],eax
	Je	.NoDeltaX
	Mov	[ebp+UIH_DeltaX],eax
	;
.NoDeltaX	Lodsb			; Get mouse delta y
	Movsx	eax,al
	Neg	eax
	Cmp	[ebp+UIH_DeltaY],eax
	Je	.NoDeltaY
	Mov	[ebp+UIH_DeltaY],eax
	;
.NoDeltaY	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Boundary check mouse against screen coordinates, since we don't want the
; mouse outside our screen.
;
UIRM_Position	Mov	eax,[ebp+UIH_DeltaX]
	Add	eax,[ebp+UIH_MouseX]
	Cmp	eax,[ebp+UIH_ScreenX]
	Jbe	.NoMaxX
	Push dword	[ebp+UIH_ScreenX]
	Pop dword	[ebp+UIH_MouseX]
	Jmp	.MaxX
.NoMaxX	Mov	[ebp+UIH_MouseX],eax
.MaxX	Mov	eax,[ebp+UIH_DeltaY]
	Add	eax,[ebp+UIH_MouseY]
	Cmp	eax,[ebp+UIH_ScreenY]
	Jbe	.NoMaxY
	Push dword	[ebp+UIH_ScreenY]
	Pop dword	[ebp+UIH_MouseY]
	Jmp	.MaxY
.NoMaxY	Mov	[ebp+UIH_MouseY],eax
.MaxY	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Seek for the frontmost window under the mouse pointer
;
UIRM_FindWindow	Lea	esi,[SysBase+SB_ScreenList]
	SUCC	esi
	Lea	esi,[esi+SC_WindowList]
	Mov	esi,[esi+LH_TAILPRED]
	SUCC	esi
.Next	PREDNODE	esi,.NoWindow		; Find window, start with frontmost
	;
	Mov	ebx,[esi+CD_TopEdge]
	Cmp	[ebp+UIH_MouseY],ebx
	Jb	.Next
	Add	ebx,[esi+CD_Height]
	Cmp	[ebp+UIH_MouseY],ebx
	Ja	.Next
	Mov	ebx,[esi+CD_LeftEdge]
	Cmp	[ebp+UIH_MouseX],ebx
	Jb	.Next
	Add	ebx,[esi+CD_Width]
	Cmp	[ebp+UIH_MouseX],ebx
	Ja	.Next
	;
	Mov	[ebp+UIH_Window],esi
	Ret
	;
.NoWindow	Mov dword	[ebp+UIH_Window],0
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Send WMIE packet to the Window process
;
UIRM_SendPacket	Bt dword	[ebp+UIH_ButtonStatus],WMIEMBB_LEFT		; Check if button is pressed
	Jnc	.NoWindow
	;
.ForcePacket	Mov	edx,[SysBase+SB_FocusWindow]
	Mov	edx,[edx+WC_WindowPort]
	Test	edx,edx
	Jz	.NoWindow
	;
	Mov	eax,WMIE_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	ebx,eax
	Mov byte	[ebx+LN_TYPE],NT_FREEMSG
	Mov dword	[ebx+MN_LENGTH],WMIE_SIZE
	Mov dword	[ebx+WMIE_Type],WMIET_MOUSE
	PUSHRS	ebp,UIH_DeltaX,UIH_DeltaY,UIH_MouseX,UIH_MouseY,UIH_ButtonStatus	; Fill her up good..
	POPRS	ebx,WMIE_MouseDeltaX,WMIE_MouseDeltaY,WMIE_MouseX,WMIE_MouseY,WMIE_MouseButton
	Mov	eax,edx
	LIBCALL	PutMsg,ExecBase
.NoWindow	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Send ActivateWindow event to the window in UIH_Window
;
UIRM_SendActivate	Cmp dword	[ebp+UIH_Window],0
	Je	.NoWindow
	;
	Mov	edx,[ebp+UIH_Window]
	Mov	edx,[edx+WC_WindowPort]
	Test	edx,edx
	Jz	.NoWindow
	;
	Mov	eax,WMIE_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	ebx,eax
	Mov byte	[ebx+LN_TYPE],NT_FREEMSG
	Mov dword	[ebx+MN_LENGTH],WMIE_SIZE
	Mov dword	[ebx+WMIE_Type],WMIET_ACTIVATEWINDOW
	Mov	eax,edx
	LIBCALL	PutMsg,ExecBase
.NoWindow	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Send DeactivateWindow event tot the window in UIH_Window
;
UIRM_SendDeActivate Cmp dword	[ebp+UIH_Window],0
	Je	.NoWindow
	;
	Mov	edx,[ebp+UIH_Window]
	Mov	edx,[edx+WC_WindowPort]
	Test	edx,edx
	Jz	.NoWindow
	;
	Mov	eax,WMIE_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Mov	ebx,eax
	Mov byte	[ebx+LN_TYPE],NT_FREEMSG
	Mov dword	[ebx+MN_LENGTH],WMIE_SIZE
	Mov dword	[ebx+WMIE_Type],WMIET_INACTIVATEWINDOW
	Mov	eax,edx
	LIBCALL	PutMsg,ExecBase
.NoWindow	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	;
	; Test..
	;

RenderMousePtr	Cmp dword	[OldCoordY],-1
	Je	.NoRestore
	Lea	esi,[MouseBackBuffer]	; Restore
	Mov	edi,[SysBase+SB_VESA+VESA_MEMPTR]
	Add	edi,[OldCoordX]
	Mov	ecx,[OldCoordY]
	Shl	ecx,10
	Add	edi,ecx
	Lea	esi,[MouseBackBuffer]
	Mov	ecx,11
.RLoop	Movsd
	Movsd
	Movsd
	Lea	edi,[edi+1012]
	Dec	ecx
	Jnz	.RLoop

.NoRestore	Mov	esi,[SysBase+SB_VESA+VESA_MEMPTR]
	Lea	edi,[MouseBackBuffer]	; Backup
	Add	esi,[ebp+UIH_MouseX]
	Mov	ecx,[ebp+UIH_MouseY]
	Shl	ecx,10
	Add	esi,ecx
	Mov	ecx,11
.BLoop	Movsd
	Movsd
	Movsd
	Lea	esi,[esi+1012]
	Dec	ecx
	Jnz	.BLoop

	Lea	esi,[MouseShape]
	Mov	edi,[SysBase+SB_VESA+VESA_MEMPTR]
	Mov	ecx,[ebp+UIH_MouseX]
	Mov	[OldCoordX],ecx
	Add	edi,ecx
	Mov	ecx,[ebp+UIH_MouseY]
	Mov	[OldCoordY],ecx
	Shl	ecx,10
	Add	edi,ecx
	Mov	ecx,11
.MLoop	Mov	ebx,12
.MILoop	Lodsb
	Test	al,al
	jz	.NoRender
	Mov	[edi],al
.NoRender	Inc	edi
	Dec	ebx
	Jnz	.MILoop
	Lea	edi,[edi+1012]
	Dec	ecx
	Jnz	.MLoop
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
OldCoordX	Dd	-1
OldCoordY	Dd	-1
MouseBackBuffer	times 12*11 Db	0

MouseShape	Db	0xaa,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	Db	0x22,0xaa,0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	Db	0x00,0x22,0xaa,0xaa,0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00
	Db	0x00,0x22,0xaa,0xaa,0xaa,0xaa,0xff,0xff,0x00,0x00,0x00,0x00
	Db	0x00,0x00,0x22,0xaa,0xaa,0xaa,0xaa,0xaa,0xff,0xff,0x00,0x00
	Db	0x00,0x00,0x22,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0xaa,0x00,0x00
	Db	0x00,0x00,0x00,0x22,0xaa,0xaa,0xaa,0xff,0x00,0x00,0x00,0x00
	Db	0x00,0x00,0x00,0x22,0xaa,0xaa,0x22,0xaa,0xff,0x00,0x00,0x00
	Db	0x00,0x00,0x00,0x00,0x22,0xaa,0x00,0x22,0xaa,0xff,0x00,0x00
	Db	0x00,0x00,0x00,0x00,0x22,0xaa,0x00,0x00,0x22,0xaa,0xff,0x00
	Db	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x22,0xaa,0x00


