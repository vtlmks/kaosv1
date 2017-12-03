;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Raw Mouse.s V1.0.0
;
;     Input-handler Raw mouse
;
;     Here's where all the mouse magic happends..
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
IH_RawMouse	; ecx = packetdata, edi = mem
	;
	Call	IHRM_CopyPacket		; Start with this one
	Call	IHRM_Position

	Call	IHRM_FindWindow
	Call	IHRM_CheckMisc
	Jc	.Done
	Call	IHRM_SendPacket
.Done	Call	RenderMousePtr
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Check miscellaneous
;
; - Send press/release button events
; - Activate/deactivate windows
; - Update focuswindow
;

IHRM_CheckMisc	Mov	ecx,WMIEMBF_LEFT
	Call	IHRM_CheckButton
	Test	eax,eax
	Jnz	.Changed
.Done	Clc
	Ret
.Changed	Cmp	eax,1
	Jne	.Release

	Mov	eax,[edi+IH_Window]
	Cmp	[SysBase+SB_FocusWindow],eax		; Check if window == focuswindow
	Je	.Done
	Call	IHRM_SendActivate			; Activate new window

	Push dword	[edi+IH_Window]
	Mov	eax,[SysBase+SB_FocusWindow]
	Mov	[edi+IH_Window],eax
	Call	IHRM_SendDeActivate		; Deactivate old window
	Pop dword	[SysBase+SB_FocusWindow]		; Set new window to focuswindow
	Stc
	Ret

.Release	Call	IHRM_SendPacket.ForcePacket		; Send release to window proc
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

IHRM_CheckButton	Mov	eax,[edi+IH_ButtonStatus]
	And	eax,ecx
	Mov	ebx,[edi+IH_OldButtons]
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
IHRM_CopyPacket	Mov	esi,[ecx+IHPKT_DATA]
	XOr	eax,eax
	Lodsb			; Get buttons
	Movzx	eax,al

;	Cmp	[edi+IH_ButtonStatus],eax
;	Je	.NoButtons

	Mov	ebx,[edi+IH_ButtonStatus]
	Mov	[edi+IH_OldButtons],ebx
	Mov	[edi+IH_ButtonStatus],eax
	;
.NoButtons	Lodsb			; Get mouse delta x
	Movsx	eax,al
	Cmp	[edi+IH_DeltaX],eax
	Je	.NoDeltaX
	Mov	[edi+IH_DeltaX],eax
	;
.NoDeltaX	Lodsb			; Get mouse delta y
	Movsx	eax,al
	Neg	eax
	Cmp	[edi+IH_DeltaY],eax
	Je	.NoDeltaY
	Mov	[edi+IH_DeltaY],eax
	;
.NoDeltaY	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Boundary check mouse against screen coordinates, since we don't want the
; mouse outside our screen.
;
IHRM_Position	Mov	eax,[edi+IH_DeltaX]
	Add	eax,[edi+IH_MouseX]
	Cmp	eax,[edi+IH_ScreenX]
	Jbe	.NoMaxX
	Push dword	[edi+IH_ScreenX]
	Pop dword	[edi+IH_MouseX]
	Jmp	.MaxX
.NoMaxX	Mov	[edi+IH_MouseX],eax
.MaxX	Mov	eax,[edi+IH_DeltaY]
	Add	eax,[edi+IH_MouseY]
	Cmp	eax,[edi+IH_ScreenY]
	Jbe	.NoMaxY
	Push dword	[edi+IH_ScreenY]
	Pop dword	[edi+IH_MouseY]
	Jmp	.MaxY
.NoMaxY	Mov	[edi+IH_MouseY],eax
.MaxY	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Seek for the frontmost window under the mouse pointer
;
IHRM_FindWindow	Lea	esi,[SysBase+SB_ScreenList]
	SUCC	esi
	Lea	esi,[esi+SC_WindowList]
	Mov	esi,[esi+LH_TAILPRED]
	SUCC	esi
.Next	PREDNODE	esi,.NoWindow		; Find window, start with frontmost
	;
	Mov	ebx,[esi+CD_TopEdge]
	Cmp	[edi+IH_MouseY],ebx
	Jb	.Next
	Add	ebx,[esi+CD_Height]
	Cmp	[edi+IH_MouseY],ebx
	Ja	.Next
	Mov	ebx,[esi+CD_LeftEdge]
	Cmp	[edi+IH_MouseX],ebx
	Jb	.Next
	Add	ebx,[esi+CD_Width]
	Cmp	[edi+IH_MouseX],ebx
	Ja	.Next
	;
	Mov	[edi+IH_Window],esi
	Ret
	;
.NoWindow	Mov dword	[edi+IH_Window],0
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Send WMIE packet to the Window process
;
IHRM_SendPacket	Bt dword	[edi+IH_ButtonStatus],WMIEMBB_LEFT		; Check if button is pressed
	Jnc	.NoWindow
	;
.ForcePacket	Mov	edx,[SysBase+SB_FocusWindow]
	Mov	edx,[edx+WC_WindowPort]
	Test	edx,edx
	Jz	.NoWindow
	;
	Lea	ecx,[IHRMMemTags]
	LIBCALL	AllocMem,ExecBase
	Mov	ebx,eax
	Mov byte	[ebx+LN_TYPE],NT_FREEMSG
	Mov dword	[ebx+MN_LENGTH],WMIE_SIZE
	Mov dword	[ebx+WMIE_Type],WMIET_MOUSE
	PUSHRS	edi,IH_DeltaX,IH_DeltaY,IH_MouseX,IH_MouseY,IH_ButtonStatus	; Fill her up good..
	POPRS	ebx,WMIE_MouseDeltaX,WMIE_MouseDeltaY,WMIE_MouseX,WMIE_MouseY,WMIE_MouseButton
	Mov	eax,edx
	LIBCALL	PutMsg,ExecBase
.NoWindow	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Send ActivateWindow event to the window in IH_Window
;
IHRM_SendActivate	Cmp dword	[edi+IH_Window],0
	Je	.NoWindow
	;
	Mov	edx,[edi+IH_Window]
	Mov	edx,[edx+WC_WindowPort]
	Test	edx,edx
	Jz	.NoWindow
	;
	Lea	ecx,[IHRMMemTags]
	LIBCALL	AllocMem,ExecBase
	Mov	ebx,eax
	Mov byte	[ebx+LN_TYPE],NT_FREEMSG
	Mov dword	[ebx+MN_LENGTH],WMIE_SIZE
	Mov dword	[ebx+WMIE_Type],WMIET_ACTIVATEWINDOW
	Mov	eax,edx
	LIBCALL	PutMsg,ExecBase
.NoWindow	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Send DeactivateWindow event tot the window in IH_Window
;
IHRM_SendDeActivate Cmp dword	[edi+IH_Window],0
	Je	.NoWindow
	;
	Mov	edx,[edi+IH_Window]
	Mov	edx,[edx+WC_WindowPort]
	Test	edx,edx
	Jz	.NoWindow
	;
	Lea	ecx,[IHRMMemTags]
	LIBCALL	AllocMem,ExecBase
	Mov	ebx,eax
	Mov byte	[ebx+LN_TYPE],NT_FREEMSG
	Mov dword	[ebx+MN_LENGTH],WMIE_SIZE
	Mov dword	[ebx+WMIE_Type],WMIET_INACTIVATEWINDOW
	Mov	eax,edx
	LIBCALL	PutMsg,ExecBase
.NoWindow	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
RenderMousePtr
	;
	; Test..
	;

	Mov	edx,edi

	Cmp dword	[OldCoordY],-1
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
	Add	esi,[edx+IH_MouseX]
	Mov	ecx,[edx+IH_MouseY]
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
	Mov	ecx,[edx+IH_MouseX]
	Mov	[OldCoordX],ecx
	Add	edi,ecx
	Mov	ecx,[edx+IH_MouseY]
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

OldCoordX	Dd	-1
OldCoordY	Dd	-1
MouseBackBuffer	times 12*11 Db	0


IHRMMemTags	Dd	MMA_SIZE,WMIE_SIZE
	Dd	TAG_DONE
