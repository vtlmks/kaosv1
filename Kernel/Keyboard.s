;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     Keyboard.I V1.0.0
;
;     Keyboard supportcode.
;
;


KEYB_CTRL	Equ	0x1d	; Control (ctrl) key
KEYB_LShift	Equ	0x2a	; Left shift key
KEYB_RShift	Equ	0x36	; Right shift key
KEYB_Alt	Equ	0x38	; Alt key
KEYB_Caps	Equ	0x3a	; Capslock key
KEYB_NumL	Equ	0x45	; Numlock key
KEYB_Scroll	Equ	0x46	; Scrollock key

	;
	; Qualifier masks
	;

	BITDEF	KB,ScrollLock,0
	BITDEF	KB,NumLock,1
	BITDEF	KB,CapsLock,2
	BITDEF	KB,RAlt,3
	BITDEF	KB,LAlt,4
	BITDEF	KB,CTRL,5
	BITDEF	KB,RShift,6
	BITDEF	KB,LShift,7


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
KeyboardIRQ	PushAD
	PushFD
	PUSHX	ds,es
	Mov	eax,SYSDATA_SEL
	Mov	ds,ax
	Mov	es,ax
	;
	Call	KeybRead
	Cmp	al,0xe0	; Control, Alt
	Je	.NoExtend
	Call	KeybRead
.NoExtend	Call	ChkQualifiers

	Test	al,0x80	; Qualifier release
	Jz	.NoQualRelease
	And	al,0x7f
	Call	ChkQualifiers
	Jmp	.Skip

.NoQualRelease	Mov	ah,[KeybStatus]
	Mov	ebx,[KeybFifoIndex]
	Mov	[KeybFifoBuffer+ebx],ax
	Add dword	[KeybFifoIndex],2		; Word packets
	Mov	eax,[KeybProcess]
	Test	eax,eax
	Jz	.Skip
	LIBCALL	Awake,ExecBase
	;
.Skip	Mov	al,PIC_EOI
	Out	PIC_M,al
	POPX	ds,es
	PopFD
	PopAD
	IRetD



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Struc KHandler
KH_UIHandlerPort	ResD	1	; UIHandler messageport
KH_Port	ResD	1	; KeyboardHandler messageport
KH_SIZE	EndStruc

KeyboardHandler	LINK	KH_SIZE
	Lea	eax,[UIHandlerPortN]
	LIBCALL	FindPort,ExecBase
	Mov	[ebp+KH_UIHandlerPort],eax
	LIBCALL	CreateMsgPort,ExecBase
	Mov	[ebp+KH_Port],eax
	Mov	[KeybPort],eax

.Main	Mov dword	[KeybFifoIndex],0
	LIBCALL	Sleep,ExecBase
	XOr	esi,esi
.Loop	Cmp	[KeybFifoIndex],esi
	Jbe	.Main
	Movzx	edx,word [KeybFifoBuffer+ecx]
	Call	.SendPacket
	Add	esi,2
	Jmp	.Loop


.SendPacket	Mov	eax,UIPKT_SIZE
	Mov	ebx,MEMF_NOKEY
	LIBCALL	AllocMem,ExecBase
	Mov	ebx,eax
.Port	Mov	eax,[ebp+KH_UIHandlerPort]
	Test	eax,eax
	Jz	.GrepPort
	Mov dword	[ebx+UIPKT_COMMAND],UIPKTCMD_RAWKEY
	Mov dword	[ebx+UIPKT_DATA],edx
	Mov byte	[ebx+MN_NODE+LN_TYPE],NT_FREEMSG
	LIBCALL	PutMsg,ExecBase
	Ret

.GrepPort	Lea	eax,[UIHandlerPortN]
	LIBCALL	FindPort,ExecBase
	Mov	[ebp+KH_UIHandlerPort],eax
	Jmp	.Port

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ChkQualifiers	Lea	esi,[QualTable]
.L	Mov	ebx,[esi]
	Test	ebx,ebx
	Jz	.Exit
	Cmp	al,bl
	Jne	.NoMatch
	Call	[esi+4]
.NoMatch	Add	esi,8
	Jmp	.L
.Exit	Ret


Qual_CTRL	XOr byte	[KeybStatus],KBF_CTRL
	Ret

Qual_LeftShift	XOr byte	[KeybStatus],KBF_LShift
	Ret

Qual_RightShift	XOr byte	[KeybStatus],KBF_RShift
	Ret

Qual_Alt	XOr byte	[KeybStatus],KBF_RAlt+KBF_LAlt
	Ret

Qual_Capslock	XOr byte	[KeybStatus],KBF_CapsLock
	Call	KeybSetLed
	Ret

Qual_Numlock	XOr byte	[KeybStatus],KBF_NumLock
	Call	KeybSetLed
	Ret

Qual_Scrollock	XOr byte	[KeybStatus],KBF_ScrollLock
	Call	KeybSetLed
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Initialize keyboard leds and unmask the keyboard IRQ.
;
KeybInit	XOr	eax,eax
	Mov byte	[KeybStatus],0		; Update led status
	Mov	al,KCMD_SetMI		; Set mode indicators
	Out	KEYBP_DATA,al
.L	In	al,KEYBP_DATA
	Cmp	al,KCMD_WaitAck
	Jne	.L
	XOr	eax,eax		; Clear all keyboard leds
	Out	KEYBP_DATA,al
	;
	Mov	eax,IRQ_KEYBOARD
	CALL	UnMaskIRQ		; Enable the keyboard IRQ
	;
	Lea	ecx,[KeybProcTags]
	LIBCALL	AddProcess,ExecBase
	Mov	[KeybProcess],eax
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; SetLed() -- As easy as it sounds...
;
KeybSetLed	Push	eax
	Call	KeybWait
	Mov	al,KCMD_SetMI		; Set mode indicators
	Out	KEYBP_DATA,al
	Call	KeybWait
	Mov	al,[KeybStatus]
	And	al,0x7		; Mask led status
	Out	KEYBP_DATA,al
	Pop	eax
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; KeybWait() - Wait for keyboard controller to be empty
;
KeybWait	Push	eax
.L	In	al,KEYBP_CTRL
	Test	al,2
	Jne	.L
	Pop	eax
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; KeybRead() -- Read next scancode from the keyboard.
; Returns scancode in AX.
;
KeybRead	In	al,KEYBP_DATA
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

KeybProcess	Dd	0
KeybPort	Dd	0

KeybFifoBuffer	Times 256 Db	0
KeybFifoIndex	Dd	0

QualTable	Dd	KEYB_CTRL,Qual_CTRL
	Dd	KEYB_LShift,Qual_LeftShift
	Dd	KEYB_RShift,Qual_RightShift
	Dd	KEYB_Alt,Qual_Alt
	Dd	KEYB_Caps,Qual_Capslock
	Dd	KEYB_NumL,Qual_Numlock
	Dd	KEYB_Scroll,Qual_Scrollock
	Dd	0

KeybProcTags	Dd	AP_PROCESSPOINTER,KeyboardHandler
	Dd	AP_PRIORITY,20
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,4000
	Dd	AP_RING,1
	Dd	AP_QUANTUM,1
	Dd	AP_NAME,KeybProcN
	Dd	TAG_DONE

KeybProcN	Db	"KeyboardHandler",0
KeybStatus	Db	0
