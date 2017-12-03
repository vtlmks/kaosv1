;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;CreateMsgPort()
;
; Obs, when a new port is created it will automatically have the Select bit set..
;
;Output:
; eax - pointer to the newly created port or NULL for error.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -

	Struc CreateMsgPortStructure
Cmp_NewPort	ResD	1	; The allocated Port structure, which will be returned to the user.
Cmp_PortNumber	ResD	1	; The number assigned for the port, excluding 'zero' and '-1'
Cmp_Size	EndStruc

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_CreateMsgPort	PushFD
	PushAD
	LINK	Cmp_Size
	;-
	Mov	eax,MP_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase
	Test	eax,eax
	Jz near	.NoMemAvailable
	Mov	[ebp+Cmp_NewPort],eax
	;-
	Mov byte	[eax+LN_TYPE],NT_MSGPORT
	Or dword	[eax+MP_FLAGS],MPF_SELECTED
	INITLIST	[eax+MP_MSGLIST]
	;-
	Mov	eax,[SysBase+SB_CurrentProcess]
	Lea	ebx,[eax+PC_PortList]
	SPINLOCK	ebx
	;--
	Push	ebx
	Mov	ecx,2
.Loop	NEXTNODE	ebx,.NoMoreNodes
	Cmp	[ebx+MP_ID],ecx
	Jne	.Loop
	Inc	ecx
	Jmp	.Loop
.NoMoreNodes	Pop	ebx
	SPINUNLOCK	ebx
	;-
	Mov	ebx,[ebp+Cmp_NewPort]
	Mov	[ebx+MP_ID],ecx
	;-
	Mov	eax,[SysBase+SB_CurrentProcess]
	Mov	[ebx+MP_SIGPROC],eax
	Lea	eax,[eax+PC_PortList]

	SPINLOCK	eax
	Push	eax
	ADDTAIL			;ADDTAIL to current proc. portlist
	Pop	eax
	SPINUNLOCK	eax

	Mov	eax,ebx
	;-
.Exit	UNLINK	Cmp_Size
	RETURN	eax
	PopAD
	PopFD
	Ret

.NoMemAvailable	XOr	eax,eax
	Jmp	.Exit

