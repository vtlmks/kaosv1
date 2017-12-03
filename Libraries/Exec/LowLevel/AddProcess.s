;
; (C) Copyright 1999-2000 Mindkiller Systems, inc.
;     All rights reserved.
;
;     AddProcess.s V1.0.0
;
;     Add a new process.
;

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
; Input:
;  ecx = Taglist
;
; Output:
;  eax = Pointer to newly created process, or zero for failure.
;
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
;
; TODO:
;	Allocate the APS structure and free it..........  and remove all the Lea ecx,[esp] sheit..
;
;

	STRUC AddProc
aps_TagListPtr	ResD	1
aps_ProcPtr	ResD	1
aps_PCPtr	ResD	1
aps_Priority	ResD	1
aps_StackSize	ResD	1
aps_StackPtr	ResD	1	; pointer to memory allocated for this process stack.
aps_Flags	ResD	1
aps_Ring	ResD	1
aps_UserData	ResD	1
aps_Quantum	ResD	1
aps_Name	ResD	1	; Process name
aps_SIZE	ENDSTRUC

;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	16
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
EXEC_AddProcess	PushFD
	PushAD
	;-
	LINK	aps_SIZE
	Mov	[ebp+aps_TagListPtr],ecx
	;-
	Call	ap_FetchTags
	Jc	.Fail
	Call	ap_AllocMemory
	Jc	.Fail
	Call	ap_InitPCNode

	;-
	Mov	eax,[SysBase+SB_ProcReadyList]
	SPINLOCK	eax
	Push	eax

	Mov	ebx,[ebp+aps_PCPtr]
	ADDTAIL
	;--
	Inc dword	[SysBase+SB_PIDCount]
	Inc dword	[SysBase+SB_ProcessCount]
	;-
	Pop	eax
	SPINUNLOCK	eax

	Mov	eax,[ebp+aps_PCPtr]
	UNLINK	aps_SIZE
	RETURN	eax
	PopAD
	PopFD
	Ret

.Fail	UNLINK	aps_SIZE
	RETURN	0
	PopAD
	PopFD
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ap_FetchTags	Lea	eax,[AddProcTaglist]
	Mov	ebx,ebp
	Mov	ecx,[ebp+aps_TagListPtr]
	LIBCALL	FetchTags,UteBase
	Test	eax,eax
	Jnz	.Fail
	;

	Cmp dword	[ebp+aps_Ring],-1
	Je	.Ring0		; If Ring = -1, set Ring 0
	Cmp dword	[ebp+aps_Ring],0
	Jne	.RingOk
.Ring0	Inc dword	[ebp+aps_Ring]		; Only ring 1-3

.RingOk	Mov	eax,[ebp+aps_StackSize]
	Test	eax,eax
	Jnz	.StackOk
	Mov	eax,0x1000
.StackOk	Lea	eax,[eax+1023]
	And	eax,0xfffffc00
	Mov	[ebp+aps_StackSize],eax
	;
	Mov	eax,[ebp+aps_Quantum]
	Test	eax,eax
	Jnz	.Quantum
	Inc	eax
.Quantum	Mov	[ebp+aps_Quantum],eax
	Clc
	Ret
	;
.Fail	Stc
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ap_AllocMemory	Mov	eax,PC_SIZE
	XOr	ebx,ebx
	LIBCALL	AllocMem,ExecBase		; allocate Process Control Structure
	Test	eax,eax
	Jz	.NoProcMem
	Mov	[ebp+aps_PCPtr],eax
	;-
	Mov	eax,[ebp+aps_StackSize]	; allocate process stack.
	Mov	ebx,MEMF_NOCLEAR		; don't clear stack memory
	LIBCALL	AllocMem,ExecBase
	Test	eax,eax
	Jz	.NoStackMem
	Mov	[ebp+aps_StackPtr],eax
	Clc
	Ret

.NoStackMem	Mov	eax,[ebp+aps_PCPtr]
	LIBCALL	FreeMem,ExecBase
.NoProcMem	Stc
	Ret



;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
ap_InitPCNode	Mov	eax,[ebp+aps_PCPtr]

	Mov	ebx,[ebp+aps_StackSize]
	Mov	ecx,[ebp+aps_StackPtr]
	Lea	ebx,[ecx+ebx-4]
	Mov	[eax+PC_StackHead],ebx
	Mov dword	[ebx],ProcessKiller
	;-
	Mov	ebx,[SysBase+SB_PIDCount]
	Mov	[eax+PC_Pid],ebx
	;-
	Mov	ebx,[ebp+aps_StackSize]
	Mov	[eax+PC_StackSize],ebx
	;-
	Mov	esi,[ebp+aps_Name]
	Lea	edi,[eax+PC_Name]		; Set Process name buffer, LN_NAME ptr
	Mov	[eax+LN_NAME],edi
	Push	eax
.L	Lodsb
	Stosb
	Test	al,al
	Jnz	.L
	Pop	eax
	;
	Mov	ebx,[ebp+aps_Priority]	; Set LN_PRI
	Mov	[eax+LN_PRI],bl
	;-
	Mov	ebx,[ebp+aps_Quantum]
	Mov dword	[eax+PC_Quantum],2	; CHANGE THIS!
	;-
	Mov	ebx,[ebp+aps_ProcPtr]
	Mov	[eax+PC_ProcessPtr],ebx
	;-
	Push	eax
	INITLIST	[eax+PC_PortList]		; Initialize Portlist.
	Pop	eax
	;-
	Lea	ebx,[eax+PC_NullPort]	; Initialize NullPort
	Mov byte	[ebx+LN_TYPE],NT_MSGPORT
	Push	eax
	INITLIST	[ebx+MP_MSGLIST]		; Initialize the messagelist
	Pop	eax
	Mov	[ebx+MP_SIGPROC],eax
	Or dword	[ebx+MP_FLAGS],MPF_SELECTED
	Push	eax
	Mov	eax,[esp]
	Lea	eax,[eax+PC_PortList]
	SPINLOCK	eax
	Push	eax
	ADDTAIL			;ADDTAIL to current proc. portlist
	Pop	eax
	SPINUNLOCK	eax
	Pop	eax

	;-
	Lea	ebx,[eax+PC_Registers]	; Setup init registers...
	;-
	Mov	ecx,[eax+PC_StackHead]	; User stack beginning
	Sub	ecx,4
	Mov	[ebx+RS_Esp],ecx
	Mov dword	[ecx],ProcessKiller
	;-

;	0011000000000000 - ring 3	+0x3000
;	0010000000000000 - ring 2	+0x2000
;	0001000000000000 - ring 1	+0x1000
;	0000000000000000 - ring 0	+0

	Mov	eax,[ebp+aps_Ring]
	Rol	eax,12
;	Mov dword	[ebx+RS_EFlags],0x2200	; IOPL, #IF
	Mov dword	[ebx+RS_EFlags],0x200	; IF
	Add dword	[ebx+RS_EFlags],eax	; IOPL = aps_ring << 12
	;-
	Mov	ecx,[ebp+aps_ProcPtr]
	Mov	[ebx+RS_Eip],ecx
	;-
	Mov	ecx,[ebp+aps_UserData]
	Mov	[ebx+RS_Edx],ecx
	;-
	Mov dword	[ebx+RS_Eax],ExecBase
	;-
	Mov	eax,[ebp+aps_Ring]
	Mov	ecx,[AddProcRingTable+eax*8]
	Mov	eax,[AddProcRingTable+4+eax*8]
	Mov dword	[ebx+RS_CS],ecx
	Mov dword	[ebx+RS_SS],eax
	Mov dword	[ebx+RS_DS],eax
	Mov dword	[ebx+RS_ES],eax
	Mov dword	[ebx+RS_FS],eax
	Mov dword	[ebx+RS_GS],eax
	Ret


;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
	Align	4
;-   -  - -- ---=--=-==-===-====-==============-====-===-==-=--=--- -- -  -   -
AddProcTaglist	Dd	AP_PROCESSPOINTER,aps_ProcPtr,TRUE
	Dd	AP_NAME,aps_Name,FALSE
	Dd	AP_PRIORITY,aps_Priority,FALSE
	Dd	AP_FLAGS,aps_Flags,FALSE
	Dd	AP_USERDATA,aps_UserData,FALSE
	Dd	AP_STACKSIZE,aps_StackSize,FALSE
	Dd	AP_RING,aps_Ring,FALSE
	Dd	AP_QUANTUM,aps_Quantum,FALSE
	Dd	TAG_DONE

AddProcRingTable	Dd	SYSCODE_SEL,SYSDATA_SEL
	Dd	SYSCODE1_SEL,SYSDATA1_SEL
	Dd	SYSCODE2_SEL,SYSDATA2_SEL
	Dd	SYSCODE3_SEL,SYSDATA3_SEL
