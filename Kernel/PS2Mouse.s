;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     PS2Mouse.I V1.0.0
;
;     PS/2 mouse supportcode.
;
;


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PS2MouseIRQ	PushAD
	PushFD
	PUSHX	ds,es
	Mov	eax,SYSDATA_SEL
	Mov	ds,ax
	Mov	es,ax
	;
	Mov	bl,KCMD_DisableKeyb
	Call	PS2Command
	;
	Cld
	Mov	ebx,[PS2FifoIndex]
	Lea	edi,[PS2FifoBuffer+ebx]
	Cmp dword	[PS2FifoIndex],2*5
	Jne	.NoDiscard
	Mov dword	[PS2FifoIndex],0

.NoDiscard	Add dword	[PS2FifoIndex],5		; 5 byte packs
	Call	PS2Read
	And	al,0x7		; We only need lmb, rmb and mmb bits
	Stosb			; Store status byte
	Call	PS2Read
	Stosb			; Store delta x byte
	Call	PS2Read
	Stosb			; Store delta y byte
	XOr	ax,ax
	Stosw			; Account for 5 byte protocol
	;
	Mov	bl,KCMD_EnableKeyb
	Call	PS2Command
	;--
	Mov	eax,[PS2Process]
	Test	eax,eax
	Jz	.Failure
	LIBCALL	Awake,ExecBase
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.Failure	Mov	al,PIC_EOI
	Out	PIC_M,al
	Out	PIC_S,al
	POPX	ds,es
	PopFD
	PopAD
	IRetd


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc PS2MHandler
PS2M_UIPort	ResD	1	; Inputhandler messageport
PS2M_Port	ResD	1	; Mousehandler messageport
PS2M_SIZE	EndStruc

	Struc PS2Packet
	ResB	MN_SIZE
PS2P_COMMAND	ResD	1	; Packet command
PS2P_DATA	ResD	1	; Packet data
PS2P_LENGTH	ResD	1	; Packet length, optional
PS2P_BUFFER	ResB	6	; 3 to 6 bytes protocol data
PS2P_SIZE	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PS2MouseHandler	LINK	PS2M_SIZE
	Lea	eax,[UIHandlerPortN]
	LIBCALL	FindPort,ExecBase
	Mov	[ebp+PS2M_UIPort],eax
	LIBCALL	CreateMsgPort,ExecBase
	Mov	[ebp+PS2M_Port],eax
	;--
	Cld
.Main	Mov dword	[PS2FifoIndex],0
	LIBCALL	Sleep,ExecBase
	XOr	ecx,ecx
.Loop	Cmp	[PS2FifoIndex],ecx
	Jbe	.Main
	Lea	esi,[PS2FifoBuffer+ecx]
	Push	ecx
	Call	.SendPacket
	Pop	ecx
	Add	ecx,5		; 5 bytes packet
	Jmp	.Loop


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
.SendPacket	Mov	eax,PS2M_SIZE
	Mov	ebx,MEMF_NOKEY
	LIBCALL	AllocMem,ExecBase
	Mov	ebx,eax
	;
	Lea	edi,[ebx+PS2P_BUFFER]	; Store status and delta values in the packet
	Movsd
	Movsb
	;
.Port	Mov	eax,[ebp+PS2M_UIPort]
	Test	eax,eax
	Jz	.GrepPort
	Mov dword	[ebx+PS2P_COMMAND],UIPKTCMD_RAWMOUSE
	Lea	ecx,[ebx+PS2P_BUFFER]
	Mov dword	[ebx+PS2P_DATA],ecx
	Mov byte	[ebx+MN_NODE+LN_TYPE],NT_FREEMSG
	LIBCALL	PutMsg,ExecBase
	Ret


.GrepPort	Lea	eax,[UIHandlerPortN]
	LIBCALL	FindPort,ExecBase
	Mov	[ebp+PS2M_UIPort],eax
	Jmp	.Port




;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Enables and initializes the Ps/2 mouse with stream mode.
;
PS2MouseInit	Mov	eax,[SysBase+SB_BIOSEquipment]
	Test	al,SBBEF_PS2Mouse
	Jz near	.NoMouse

	Mov	bl,0xa8	; Enable mouseport
	Call	PS2Command
	Call	PS2Read	; Read status
	Mov	bl,0x20	; get command byte
	Call	PS2Command
	Call	PS2Read
	Or	al,3	; enable keyb. and mouse interrupt
	Mov	bl,0x60	; write back command byte
	Push	eax
	Call	PS2Command
	Pop	eax
	Call	PS2Write

	Mov	bl,0xd4	; Mouse command
	Call	PS2Command
	Mov	al,0xf4	; Enablemouse
	Call	PS2Write
	Call	PS2Read	; Statusreturn
	;---
;;	Call	InitMouse

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;	Mov	bl,0xd4	; Mouse command
;	Call	PS2Command
;	Mov	al,PS2_SetMSR	; Set samplerate
;	Call	PS2Write
;	Call	PS2Read
;	Mov	bl,0xd4
;	Call	PS2Command
;	Mov	al,0xc8	; 200hz
;	Call	PS2Write
;	Call	PS2Read
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -




	;
	Lea	ecx,[PS2MouseProcTags]
	LIBCALL	AddProcess,ExecBase
	Mov	[PS2Process],eax
	;
	Mov	eax,IRQ_PS2MOUSE
	Call	UnMaskIRQ
.NoMouse	Ret
;                 		f3               f3              f3
PS2CfgTable1	Db	243, 200, 243, 100, 243, 80, 0
PS2CfgTable2	Db	246, 230, 244, 243, 100, 232, 3, 0
;                                                                                  f6             f4      f3               f3
;-   -  - -- ---=--=-==-===-====-=====-====-===-==-=--=--- -- -  -   -
InitMouse	Cld
	Lea	esi,[MouseInitTable]
.L	Lodsb
	Cmp	al,-1
	Je	.Mo
	Call	PS2Write
	Jmp	.L
.Mo	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PS2Read	PUSHX	ecx,edx
	Mov	ecx,0xffff
.L	In	al,0x64
	Test	al,1
	Jnz	.L1
	Dec	ecx
	Jnz	.L
	Mov	ah,1
	Jmp	.Failure
	;
.L1	Push	ecx
	Mov	ecx,32
.L2	Dec	ecx
	Jnz	.L2
	Pop	ecx
	In	al,0x60
	XOr	ah,ah
.Failure	POPX	ecx,edx
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PS2Command	Mov	ecx,0xffff
.L	In	al,0x64		; Keyboard not ready
	Test	al,2
	Jz	.L1
	Dec	ecx
	Jnz	.L
	Jmp	.Failed
.L1	Mov	al,bl		; Send command
	Out	0x64,al
	Mov	ecx,0xffff
.L2	In	al,0x64		; Wait for ack
	Test	al,2
	Jz	.Done
	Dec	ecx
	Jnz	.L2
.Failed	Mov	ah,1
	Ret
.Done	XOr	ah,ah
	Ret

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Write to the keyboard port. Prefix the port with the PS2MouseCmd() call to route
; the command to the mouseport instead.
;
PS2Write	PUSHX	ecx,edx
	Mov	dl,al
	Mov	ecx,0xffff
.L	In	al,0x64
	Test	al,0x20
	Jz	.NoMore
	Dec	ecx
	Jnz	.L
	Mov	ah,1
	Jmp	.Failed
	;
.NoMore	In	al,0x60
	Mov	ecx,0xffff
.L1	In	al,0x64
	Test	al,2
	Jz	.NoMore2
	Dec	ecx
	Jnz	.L1
	Mov	ah,1
	Jmp	.Failed
	;
.NoMore2	Mov	al,dl
	Out	0x60,al
	Mov	ecx,0xffff
.L2	In	al,0x64
	Test	al,2
	Jz	.NoMore3
	Dec	ecx
	Jnz	.L2
	Mov	ah,1
	Jmp	.Failed
	;
.NoMore3	Mov	ah,8
.L3	Mov	ecx,0xffff
.L4	In	al,0x64
	Test	al,1
	Jnz	.Done
	Dec	ecx
	Jnz	.L4
	Dec	ah
	Jnz	.L3
.Done	XOr	ah,ah
.Failed	POPX	ecx,edx
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
PS2MouseProcTags	Dd	AP_PROCESSPOINTER,PS2MouseHandler
	Dd	AP_PRIORITY,20
	Dd	AP_FLAGS,0
	Dd	AP_STACKSIZE,1000
	Dd	AP_RING,1
	Dd	AP_QUANTUM,1
	Dd	AP_NAME,PS2MouseProcN
	Dd	TAG_DONE

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
MouseInitTable	Db	230, 232, 0, 232, 3, 232, 2, 232, 1, 230, 232, 3, 232, 1, 232, 2, 232, 3
	Db	-1


PS2MouseProcN	Db	"PS2MouseHandler",0

PS2FifoBuffer	Times 256*5 Db	0
PS2FifoIndex	Dd	0
PS2Process	Dd	0

