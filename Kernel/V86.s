;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; (C) Copyright 1999-2001 Mindkiller Systems, inc.
;     All rights reserved.
;
;     V86.s V1.0.0
;
;     V86 (Virtual 8086) mode support.
;
;
;	Struc V86
;.AX
;.AL	ResB	1
;.AH	ResB	1
;.BX
;.BL	ResB	1
;.BH	ResB	1
;.CX
;.CL	ResB	1
;.CH	ResB	1
;.DX
;.DL	ResB	1
;.DH	ResB	1
;.SI	ResW	1
;.DI	ResW	1
;.BP	ResW	1
;.DS	ResW	1
;.ES	ResW	1
;.Flags	ResW	1
;;	;
;;.Eip	ResD	1	; Process Instruction pointer
;;.CS	ResD	1	; Process Codesegment selector
;;.EFlags	ResD	1	; Process EFlags, should be set to 0x200 to keep interrupts
;;.Esp	ResD	1	; Process Stack pointer
;;.SS	ResD	1	; Process Stacksegment selector
;.SIZE	EndStruc

tsk_back	EQU	0
tsk_esp0        EQU	4
tsk_sp0         EQU	8
tsk_esp1        EQU	12
tsk_sp1         EQU	16
tsk_esp2        EQU	20
tsk_sp2         EQU	24
tsk_ocr3        EQU	28
tsk_oeip        EQU	32
tsk_oeflags     EQU	36
tsk_oeax        EQU	40
tsk_oecx        EQU	44
tsk_oedx        EQU	48
tsk_oebx        EQU	52
tsk_oesp        EQU	56
tsk_oebp        EQU	60
tsk_oesi        EQU	64
tsk_oedi        EQU	68
tsk_oes         EQU	72
tsk_ocs         EQU	76
tsk_oss         EQU	80
tsk_ods         EQU	84
tsk_ofs         EQU	88
tsk_ogs         EQU	92
tsk_oldtr       EQU	96
tsk_iomap       EQU	100


V86TASK	Equ	0x7200
V86STACK	Equ	0x9268

;
; - eflags
; - cs
; - eip

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Initialize V86 descriptor
;
SetupV86	Mov	eax,V86TASK		; Address of V86-task buffer
	Mov	[V86TSS_DESC+2],ax	; Base 0-15
	Shr	eax,8
	Mov	[V86TSS_DESC+4],ah	; Base 16-23
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
V86Handler	Mov	eax,SYSDATA_SEL
	Mov	ds,ax
	PushAD
	Mov	esi,V86System
	Mov	edi,0x7000
	Mov	ecx,2500
	Cld
	Rep Movsd
	PopAD			; Remove this later on..
	;;
	PushAD
	Push	ds
	Push	es
	Push	fs
	Push	gs
	;
	Push	ebx		; Pointer to parameter block
	Mov	dl,al		; Save interrupt number
	;
	XOr	ecx,ecx
	Mov	cx,ss
	Push dword	[V86TASK+tsk_sp0]
	Push dword	[V86TASK+tsk_esp0]
	Mov	[V86TASK+tsk_sp0],ecx
	Mov	[V86TASK+tsk_esp0],esp	; adress of stack when a exception occures
	Mov	ecx,V86STACK		; ESP pointer
	XOr	eax,eax
	Push	eax		; GS
	Push	eax		; FS
	Push	eax		; DS
	Push	eax		; ES
	;
	Push dword	0x0		; SS
	Push	ecx		; ESP
	Mov	[ecx],edx		; INT#
	Add	ecx,4
	;
	PushFD
	Pop	eax
	Or	eax,0x20000		; Set VM (virtual-mode) flag
	Push 	eax		; EFlags
	Push dword	0x0		; CS
	Push dword	0x7000		; EIP
	IRetd



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
V86System	Incbin	"Kernel\V86System.bin"


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
V86Exception	Test byte	[esp+14],2	; Check VM flag
	Jz near	Except13	; If not set, jump to standard #GP handler
	;
	Add	esp,4		; remove error code
	PushAD

	Mov	ax,SYSDATA_SEL
	Mov	ds,ax		; data selector
	Movzx	ebx,word [esp+36]		; old CS
	Shl	ebx,4
	Add	ebx,[esp+32]		; old EIP
	Inc	word [esp+32]
	Mov	al,[ebx]		; fetch instruction that caused the exception

	Mov	dl,3		; int vect 3

	Cmp	al,0xcc		; int 3
	Je short	v86int
	Cmp	al,0xce		; into
	Ja near	Except86		; V86 exception
	Je short	v86genv86ni
	Inc	word [esp+32]
	Mov	dl,[ebx+1]		; fetch interrupt number (after 'int' instruction)
	Cmp	dl,0xfd		; int 0xfd is used for return from real int simulation
	Jne short	v86int
	Jmp	V86Return

v86genv86ni	Mov	dl,4		; int vect 4
v86int	Mov	dl,0x10
				; Do interrupt for V86 task
	Mov	ax,SYSDATA_SEL
	Mov	ds,ax		; set data selector

	Movzx	ebx,dl
	Shl	ebx,2
	Movzx	edx,word [esp+48]		; old ss
	Shl	edx,4
	Sub word	[esp+44],6		; increment old esp
	Add	edx,[esp+44]		; edx = physical stack address - 6

	Mov	ax,[esp+40]		; old flags
	Mov	[edx+4],ax		; make sure old flags get loaded before entering int handler
	Mov 	ax,[esp+36]		; old cs
	Mov 	[edx+2],ax		; set return segment (from int handler to v86 routine)
	Mov 	ax,[esp+32]		; old eip
	Mov 	[edx],ax		; set return address (from int handler to v86 routine)
	And word	[esp+40],0xfcff		; old flags (clear RESUME flag)
	Mov 	eax,[ds:ebx]		; fetch interrupt vector
	Mov 	[esp+32],ax		; old eip
	Shr 	eax,16
	Mov 	[esp+36],ax		; old cs
	PopAD
	;

	Mov	ax,0x13	; **remove me!!**
	IRetD


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
V86Return	Add	esp,36+32
	Mov	ax,SYSDATA_SEL
	Mov	ds,ax
	Pop dword	[V86TASK+tsk_esp0]
	Pop dword	[V86TASK+tsk_sp0]
	Pop	ebx		; pointer to parameter block
	Pop	gs
	Pop 	fs
	Pop 	es
	Pop	ds
	PopAD

	Jmp	$

	IretD








;	;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;.Dummy	Inc byte	[.KeybMo]
;	Call	.Wait
;	Mov	al,KCMD_SetMI		; Set mode indicators
;	Out	KEYBP_DATA,al
;	Call	.Wait
;	Mov	al,[.KeybMo]
;	And	al,0x7		; Mask led status
;	Out	KEYBP_DATA,al
;	Jmp	.Dummy
;.Wait	In	al,KEYBP_CTRL
;	Test	al,2
;	Jne	.Wait
;	Ret
;.KeybMo	Dd	0
;	;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;



;	Jmp	$
;


;;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;; Here we exit back to the user
;;
;V86Done
;	Ret
;
;
;;MEM 0000h:0000h R - INTERRUPT VECTOR TABLE
;;1024 BYTEs
;;
;; int 10,13,16
;
;
;
;
;
